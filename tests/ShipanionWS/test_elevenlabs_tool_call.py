#!/usr/bin/env python3
"""
Test ElevenLabs Tool Call

This script simulates an ElevenLabs client tool call to the WebSocket server.
"""
import asyncio
import json
import logging
import websockets
import httpx
import sys
import uuid
from typing import Dict, Any, List, Optional

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# WebSocket server URL
WS_SERVER_URL = "ws://localhost:8001/ws"

async def get_test_token():
    """Get a test token from the WebSocket server."""
    async with httpx.AsyncClient() as client:
        response = await client.get("http://localhost:8001/test-token")
        response.raise_for_status()
        return response.json()["test_token"]

async def test_elevenlabs_tool_call():
    """Test the ElevenLabs client tool call."""
    # Generate a session ID
    session_id = str(uuid.uuid4())
    logger.info(f"Using session ID: {session_id}")

    # Get a test token
    token = await get_test_token()
    logger.info(f"Got test token: {token[:10]}...")

    # Connect to the WebSocket server
    websocket_url = f"{WS_SERVER_URL}?token={token}&session_id={session_id}"
    logger.info(f"Connecting to WebSocket server at {websocket_url}")

    try:
        websocket = await websockets.connect(websocket_url)
        logger.info("Connected to WebSocket server")

        # Send a client_tool_call for get_shipping_quotes
        client_tool_call = {
            "type": "client_tool_call",
            "client_tool_call": {
                "tool_name": "get_shipping_quotes",
                "tool_call_id": "elevenlabs-test-123",
                "parameters": {
                    "from_zip": "90210",
                    "to_zip": "10001",
                    "weight": 5.0
                }
            },
            "broadcast": True,
            "session_id": session_id
        }

        logger.info(f"Sending client_tool_call: {client_tool_call}")
        await websocket.send(json.dumps(client_tool_call))

        # Wait for responses
        logger.info("Waiting for responses...")
        received_tool_result = False
        received_contextual_update = False

        # Wait until we receive both a client_tool_result and a contextual_update
        # or until we've received 10 messages (to prevent infinite loops)
        for _ in range(10):  # Wait for up to 10 messages
            try:
                response = await asyncio.wait_for(websocket.recv(), timeout=15.0)
                response_data = json.loads(response)
                logger.info(f"Received message type: {response_data.get('type')}")
                logger.info(f"Message: {json.dumps(response_data, indent=2)}")

                # If this is the client_tool_result, print the result
                if response_data.get("type") == "client_tool_result":
                    logger.info(f"Tool result: {response_data.get('result')}")
                    received_tool_result = True

                # If this is a contextual_update, print the data
                if response_data.get("type") == "contextual_update":
                    logger.info(f"Contextual update data: {response_data.get('data')}")
                    received_contextual_update = True

                # If we've received both types of messages, we can stop waiting
                if received_tool_result and received_contextual_update:
                    logger.info("Received both client_tool_result and contextual_update!")
                    break
            except asyncio.TimeoutError:
                logger.info("No more messages received after 15 seconds")
                break

        # Log what we received
        if received_tool_result:
            logger.info("✅ Received client_tool_result")
        else:
            logger.info("❌ Did NOT receive client_tool_result")

        if received_contextual_update:
            logger.info("✅ Received contextual_update")
        else:
            logger.info("❌ Did NOT receive contextual_update")

        logger.info("Test completed successfully!")
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        sys.exit(1)
    finally:
        # Close the WebSocket connection
        if 'websocket' in locals():
            await websocket.close()

if __name__ == "__main__":
    asyncio.run(test_elevenlabs_tool_call())
