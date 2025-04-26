"""
Test ElevenLabs Tool Integration

This script tests the integration with ElevenLabs by sending a client_tool_call
message to the WebSocket server and checking the response.
"""
import asyncio
import json
import websockets
import requests
import logging
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# WebSocket server URL
WS_SERVER_URL = "ws://localhost:8001/ws"
API_SERVER_URL = "http://localhost:8001"

# Test data for get_shipping_quotes tool
QUOTES_TOOL_CALL = {
    "type": "client_tool_call",
    "client_tool_call": {
        "tool_name": "get_shipping_quotes",
        "tool_call_id": "test-quotes-123",
        "parameters": {
            "from_zip": "90210",
            "to_zip": "10001",
            "weight": 5.0,
            "dimensions": "12x10x8",
            "pickup_requested": False
        }
    }
}

def get_auth_token():
    """Get an authentication token for testing."""
    try:
        response = requests.get(f"{API_SERVER_URL}/test-token")
        response.raise_for_status()
        return response.json()["test_token"]
    except Exception as e:
        logger.error(f"Failed to get auth token: {str(e)}")
        raise

async def test_get_shipping_quotes():
    """Test the get_shipping_quotes tool."""
    try:
        # Get authentication token
        token = get_auth_token()
        logger.info(f"Obtained auth token: {token[:10]}...")

        # Connect to WebSocket server
        logger.info(f"Connecting to WebSocket server at {WS_SERVER_URL}")
        async with websockets.connect(f"{WS_SERVER_URL}?token={token}") as websocket:
            logger.info("Connected to WebSocket server")

            # Send the client_tool_call
            logger.info(f"Sending client_tool_call: {json.dumps(QUOTES_TOOL_CALL)}")
            await websocket.send(json.dumps(QUOTES_TOOL_CALL))

            # Wait for responses with timeout
            logger.info("Waiting for responses...")
            start_time = asyncio.get_event_loop().time()
            timeout = 30  # 30 seconds timeout

            # Track received messages
            client_tool_result_received = False
            contextual_updates_received = []

            while asyncio.get_event_loop().time() - start_time < timeout and (not client_tool_result_received or len(contextual_updates_received) < 2):
                try:
                    # Set a shorter timeout for each receive attempt
                    response = await asyncio.wait_for(websocket.recv(), timeout=2.0)
                    response_data = json.loads(response)

                    # Log all messages for debugging
                    logger.info(f"Received message: {json.dumps(response_data)}")

                    # Check message type
                    if response_data.get("type") == "client_tool_result":
                        logger.info("Received client_tool_result response!")
                        client_tool_result_received = True
                    elif response_data.get("type") == "contextual_update":
                        logger.info(f"Received contextual_update: {response_data.get('text')}")
                        contextual_updates_received.append(response_data)

                except asyncio.TimeoutError:
                    # This is expected, we'll try again until the overall timeout
                    continue
                except Exception as e:
                    logger.error(f"Error processing response: {str(e)}")
                    raise

            # Verify that we received the expected messages
            if not client_tool_result_received:
                logger.error("Did not receive client_tool_result response")
                return False

            if len(contextual_updates_received) < 1:
                logger.warning("Did not receive any contextual_update messages")

            # Check if we received both types of contextual updates
            ui_update = None
            elevenlabs_update = None

            for update in contextual_updates_received:
                if update.get("text") == "quote_ready":
                    ui_update = update
                elif update.get("text") == "get_shipping_quotes_result":
                    elevenlabs_update = update

            # Verify UI update
            if ui_update:
                logger.info("Received UI contextual update!")
            else:
                logger.warning("Did not receive UI contextual update")

            # Verify ElevenLabs update
            if elevenlabs_update:
                logger.info("Received ElevenLabs contextual update!")
            else:
                logger.warning("Did not receive ElevenLabs contextual update")

            # Overall test result
            if client_tool_result_received:
                logger.info("Test passed! Received client_tool_result response.")
                return True
            else:
                logger.error("Test failed. Did not receive client_tool_result response.")
                return False

    except Exception as e:
        logger.error(f"Test failed: {str(e)}")
        return False

async def main():
    """Run the test."""
    logger.info("Starting ElevenLabs tool test")

    try:
        result = await test_get_shipping_quotes()
        if result:
            logger.info("Test completed successfully!")
        else:
            logger.error("Test failed!")
            sys.exit(1)
    except Exception as e:
        logger.error(f"Test failed: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
