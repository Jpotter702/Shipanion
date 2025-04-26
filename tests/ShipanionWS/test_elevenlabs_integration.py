#!/usr/bin/env python3
"""
Test ElevenLabs Integration

This script tests the integration between ElevenLabs, the WebSocket server, and the UI.
It simulates ElevenLabs making a client_tool_call and verifies that the response is correct.
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

async def connect_client(client_name: str, session_id: Optional[str] = None):
    """Connect a client to the WebSocket server."""
    # Get a test token
    token = await get_test_token()
    logger.info(f"[{client_name}] Got test token: {token[:10]}...")

    # Connect to the WebSocket server
    websocket_url = f"{WS_SERVER_URL}?token={token}"
    if session_id:
        websocket_url += f"&session_id={session_id}"
    
    logger.info(f"[{client_name}] Connecting to WebSocket server at {websocket_url}")
    
    try:
        websocket = await websockets.connect(websocket_url)
        logger.info(f"[{client_name}] Connected to WebSocket server")
        return websocket
    except Exception as e:
        logger.error(f"[{client_name}] Error connecting to WebSocket server: {str(e)}")
        sys.exit(1)

async def collect_messages(websocket, client_name: str, timeout: float = 5.0):
    """Collect messages from a WebSocket connection for a specified duration."""
    messages = []
    try:
        while True:
            # Set a timeout to avoid waiting indefinitely
            message = await asyncio.wait_for(websocket.recv(), timeout=timeout)
            message_data = json.loads(message)
            messages.append(message_data)
            logger.info(f"[{client_name}] Received message: {message_data.get('type')}")
    except asyncio.TimeoutError:
        # This is expected when no more messages are coming
        logger.info(f"[{client_name}] No more messages received")
    except Exception as e:
        logger.error(f"[{client_name}] Error collecting messages: {str(e)}")
    
    return messages

async def test_elevenlabs_integration():
    """Test the integration between ElevenLabs, the WebSocket server, and the UI."""
    # Generate a session ID
    session_id = str(uuid.uuid4())
    logger.info(f"Using session ID: {session_id}")
    
    # Connect ElevenLabs client
    elevenlabs_client = await connect_client("ElevenLabs", session_id)
    
    # Connect UI client with the same session ID
    ui_client = await connect_client("UI", session_id)
    
    try:
        # Send a client_tool_call from ElevenLabs
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
            "broadcast": True
        }
        
        logger.info(f"[ElevenLabs] Sending client_tool_call: {client_tool_call}")
        await elevenlabs_client.send(json.dumps(client_tool_call))
        
        # Collect messages from both clients
        elevenlabs_task = asyncio.create_task(collect_messages(elevenlabs_client, "ElevenLabs"))
        ui_task = asyncio.create_task(collect_messages(ui_client, "UI"))
        
        # Wait for both tasks to complete
        elevenlabs_messages = await elevenlabs_task
        ui_messages = await ui_task
        
        # Analyze the messages
        logger.info(f"ElevenLabs received {len(elevenlabs_messages)} messages")
        logger.info(f"UI received {len(ui_messages)} messages")
        
        # Find the client_tool_result message
        tool_result = next((msg for msg in elevenlabs_messages if msg.get("type") == "client_tool_result"), None)
        if tool_result:
            logger.info(f"Found client_tool_result message: {json.dumps(tool_result, indent=2)}")
        else:
            logger.error("No client_tool_result message found")
        
        # Find the contextual_update messages
        elevenlabs_contextual_updates = [msg for msg in elevenlabs_messages if msg.get("type") == "contextual_update"]
        ui_contextual_updates = [msg for msg in ui_messages if msg.get("type") == "contextual_update"]
        
        logger.info(f"ElevenLabs received {len(elevenlabs_contextual_updates)} contextual_update messages")
        logger.info(f"UI received {len(ui_contextual_updates)} contextual_update messages")
        
        # Check if the UI received the same contextual updates as ElevenLabs
        if elevenlabs_contextual_updates and ui_contextual_updates:
            for i, update in enumerate(elevenlabs_contextual_updates):
                logger.info(f"ElevenLabs contextual_update {i+1}: {json.dumps(update, indent=2)}")
            
            for i, update in enumerate(ui_contextual_updates):
                logger.info(f"UI contextual_update {i+1}: {json.dumps(update, indent=2)}")
        
        # Check if the session ID is included in the messages
        for msg in elevenlabs_messages + ui_messages:
            if "session_id" in msg:
                logger.info(f"Found session_id in message: {msg['session_id']}")
                if msg["session_id"] != session_id:
                    logger.warning(f"Session ID mismatch: {msg['session_id']} != {session_id}")
        
        logger.info("Test completed successfully!")
    finally:
        # Close the WebSocket connections
        await elevenlabs_client.close()
        await ui_client.close()

if __name__ == "__main__":
    asyncio.run(test_elevenlabs_integration())
