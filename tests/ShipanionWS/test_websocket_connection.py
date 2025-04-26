"""
Test WebSocket Connection

This script tests the WebSocket connection to the server.
"""
import asyncio
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

def get_test_token():
    """Get a test token for authentication."""
    try:
        response = requests.get(f"{API_SERVER_URL}/test-token")
        response.raise_for_status()
        return response.json()["test_token"]
    except Exception as e:
        logger.error(f"Failed to get test token: {str(e)}")
        raise

async def test_websocket_connection():
    """Test the WebSocket connection."""
    try:
        # Get test token
        token = get_test_token()
        logger.info(f"Obtained test token: {token[:10]}...")
        
        # Connect to WebSocket server
        logger.info(f"Connecting to WebSocket server at {WS_SERVER_URL}?token={token}")
        
        # Try with different connection parameters
        try:
            async with websockets.connect(f"{WS_SERVER_URL}?token={token}") as websocket:
                logger.info("Connected to WebSocket server with token in query parameter")
                await websocket.send('{"type": "ping"}')
                response = await websocket.recv()
                logger.info(f"Received response: {response}")
        except Exception as e:
            logger.error(f"Failed to connect with token in query parameter: {str(e)}")
            
            # Try with token in header
            try:
                async with websockets.connect(
                    WS_SERVER_URL,
                    extra_headers={"Authorization": f"Bearer {token}"}
                ) as websocket:
                    logger.info("Connected to WebSocket server with token in header")
                    await websocket.send('{"type": "ping"}')
                    response = await websocket.recv()
                    logger.info(f"Received response: {response}")
            except Exception as e:
                logger.error(f"Failed to connect with token in header: {str(e)}")
                
                # Try with a different WebSocket library or approach
                logger.info("All connection attempts failed")
                return False
        
        return True
    except Exception as e:
        logger.error(f"Test failed: {str(e)}")
        return False

async def main():
    """Run the test."""
    logger.info("Starting WebSocket connection test")
    
    try:
        result = await test_websocket_connection()
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
