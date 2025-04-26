#!/usr/bin/env python3
"""
WebSocket client for testing the WebSocket server.
"""
import asyncio
import json
import logging
import websockets
import httpx
import sys

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

async def test_websocket_connection():
    """Test the WebSocket connection."""
    # Get a test token
    token = await get_test_token()
    logger.info(f"Got test token: {token[:10]}...")

    # Connect to the WebSocket server
    websocket_url = f"{WS_SERVER_URL}?token={token}"
    logger.info(f"Connecting to WebSocket server at {websocket_url}")
    
    try:
        async with websockets.connect(websocket_url) as websocket:
            logger.info("Connected to WebSocket server")
            
            # Send a test message
            test_message = {
                "type": "test",
                "payload": {"message": "Hello, WebSocket server!"}
            }
            logger.info(f"Sending message: {test_message}")
            await websocket.send(json.dumps(test_message))
            
            # Wait for a response
            logger.info("Waiting for response...")
            response = await websocket.recv()
            logger.info(f"Received response: {response}")
            
            # Parse the response
            response_data = json.loads(response)
            logger.info(f"Response type: {response_data.get('type')}")
            logger.info(f"Response payload: {response_data.get('payload')}")
            
            # Send a rate request
            rate_request = {
                "type": "get_rates",
                "payload": {
                    "origin_zip": "90210",
                    "destination_zip": "10001",
                    "weight": 5.0
                }
            }
            logger.info(f"Sending rate request: {rate_request}")
            await websocket.send(json.dumps(rate_request))
            
            # Wait for a response
            logger.info("Waiting for rate response...")
            rate_response = await websocket.recv()
            logger.info(f"Received rate response: {rate_response}")
            
            # Parse the response
            rate_response_data = json.loads(rate_response)
            logger.info(f"Rate response type: {rate_response_data.get('type')}")
            logger.info(f"Rate response payload: {rate_response_data.get('payload')}")
            
            # Send a client tool call
            client_tool_call = {
                "type": "client_tool_call",
                "client_tool_call": {
                    "tool_name": "get_shipping_quotes",
                    "tool_call_id": "test-123",
                    "parameters": {
                        "from_zip": "90210",
                        "to_zip": "10001",
                        "weight": 5.0
                    }
                },
                "broadcast": True
            }
            logger.info(f"Sending client tool call: {client_tool_call}")
            await websocket.send(json.dumps(client_tool_call))
            
            # Wait for responses (client_tool_result and contextual_update)
            logger.info("Waiting for client tool result...")
            for _ in range(3):  # Wait for up to 3 messages
                try:
                    tool_response = await asyncio.wait_for(websocket.recv(), timeout=5.0)
                    logger.info(f"Received message: {tool_response}")
                    
                    # Parse the response
                    tool_response_data = json.loads(tool_response)
                    logger.info(f"Message type: {tool_response_data.get('type')}")
                    
                    # If this is the client_tool_result, print the result
                    if tool_response_data.get("type") == "client_tool_result":
                        logger.info(f"Tool result: {tool_response_data.get('result')}")
                    
                    # If this is a contextual_update, print the data
                    if tool_response_data.get("type") == "contextual_update":
                        logger.info(f"Contextual update data: {tool_response_data.get('data')}")
                except asyncio.TimeoutError:
                    logger.info("No more messages received")
                    break
            
            logger.info("Test completed successfully!")
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(test_websocket_connection())
