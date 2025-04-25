"""
Test ElevenLabs Integration

This module tests the integration between the WebSocket server and ElevenLabs client tools.
"""
import asyncio
import json
import pytest
import websockets
import httpx
import os
import logging
from typing import Dict, Any

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Test configuration
WS_SERVER_URL = os.environ.get("WS_SERVER_URL", "ws://localhost:8001/ws")
API_SERVER_URL = os.environ.get("API_SERVER_URL", "http://localhost:8001")

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
            "dimensions": {
                "length": 12.0,
                "width": 8.0,
                "height": 6.0
            }
        }
    }
}

# Test data for create_label tool
CREATE_LABEL_TOOL_CALL = {
    "type": "client_tool_call",
    "client_tool_call": {
        "tool_name": "create_label",
        "tool_call_id": "test-label-123",
        "parameters": {
            "carrier": "fedex",
            "service_type": "FEDEX_GROUND",
            "shipper_name": "John Doe",
            "shipper_street": "123 Main St",
            "shipper_city": "Beverly Hills",
            "shipper_state": "CA",
            "shipper_zip": "90210",
            "recipient_name": "Jane Smith",
            "recipient_street": "456 Park Ave",
            "recipient_city": "New York",
            "recipient_state": "NY",
            "recipient_zip": "10001",
            "weight": 5.0,
            "dimensions": {
                "length": 12.0,
                "width": 8.0,
                "height": 6.0
            }
        }
    }
}

async def get_auth_token() -> str:
    """Get an authentication token for testing."""
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{API_SERVER_URL}/test-token")
        response.raise_for_status()
        return response.json()["test_token"]

@pytest.mark.asyncio
async def test_get_shipping_quotes_tool():
    """Test the get_shipping_quotes tool."""
    token = await get_auth_token()
    
    async with websockets.connect(f"{WS_SERVER_URL}?token={token}") as websocket:
        # Send tool call
        await websocket.send(json.dumps(QUOTES_TOOL_CALL))
        
        # Wait for response
        response = await websocket.recv()
        response_data = json.loads(response)
        
        # Verify response structure
        assert response_data["type"] == "client_tool_result"
        assert response_data["tool_call_id"] == "test-quotes-123"
        assert "result" in response_data
        assert "is_error" in response_data
        assert not response_data["is_error"]
        
        # Verify result data
        result = response_data["result"]
        assert isinstance(result, list)
        assert len(result) > 0
        assert "carrier" in result[0]
        assert "service" in result[0]
        assert "price" in result[0]
        assert "eta" in result[0]
        
        # Wait for contextual update
        try:
            contextual_update = await asyncio.wait_for(websocket.recv(), timeout=3.0)
            update_data = json.loads(contextual_update)
            
            # Verify contextual update
            assert update_data["type"] == "contextual_update"
            assert update_data["text"] == "quote_ready"
            assert "data" in update_data
            assert "all_options" in update_data["data"]
        except asyncio.TimeoutError:
            logger.warning("No contextual update received (this may be expected)")

@pytest.mark.asyncio
async def test_create_label_tool():
    """Test the create_label tool."""
    token = await get_auth_token()
    
    async with websockets.connect(f"{WS_SERVER_URL}?token={token}") as websocket:
        # Send tool call
        await websocket.send(json.dumps(CREATE_LABEL_TOOL_CALL))
        
        # Wait for response
        response = await websocket.recv()
        response_data = json.loads(response)
        
        # Verify response structure
        assert response_data["type"] == "client_tool_result"
        assert response_data["tool_call_id"] == "test-label-123"
        assert "result" in response_data
        assert "is_error" in response_data
        assert not response_data["is_error"]
        
        # Verify result data
        result = response_data["result"]
        assert "tracking_number" in result
        assert "label_url" in result
        assert "qr_code" in result
        assert "carrier" in result
        
        # Wait for contextual update
        try:
            contextual_update = await asyncio.wait_for(websocket.recv(), timeout=3.0)
            update_data = json.loads(contextual_update)
            
            # Verify contextual update
            assert update_data["type"] == "contextual_update"
            assert update_data["text"] == "label_created"
            assert "data" in update_data
            assert "tracking_number" in update_data["data"]
        except asyncio.TimeoutError:
            logger.warning("No contextual update received (this may be expected)")

@pytest.mark.asyncio
async def test_invalid_tool_call():
    """Test sending an invalid tool call."""
    token = await get_auth_token()
    
    # Create an invalid tool call
    invalid_tool_call = {
        "type": "client_tool_call",
        "client_tool_call": {
            "tool_name": "invalid_tool",
            "tool_call_id": "test-invalid-123",
            "parameters": {}
        }
    }
    
    async with websockets.connect(f"{WS_SERVER_URL}?token={token}") as websocket:
        # Send invalid tool call
        await websocket.send(json.dumps(invalid_tool_call))
        
        # Wait for response
        response = await websocket.recv()
        response_data = json.loads(response)
        
        # Verify error response
        assert response_data["type"] == "client_tool_result"
        assert response_data["tool_call_id"] == "test-invalid-123"
        assert "result" in response_data
        assert "is_error" in response_data
        assert response_data["is_error"]
        assert "error" in response_data["result"]

if __name__ == "__main__":
    # For manual testing
    async def main():
        token = await get_auth_token()
        logger.info(f"Using token: {token}")
        
        # Test get_shipping_quotes
        logger.info("Testing get_shipping_quotes tool...")
        await test_get_shipping_quotes_tool()
        
        # Test create_label
        logger.info("Testing create_label tool...")
        await test_create_label_tool()
        
        # Test invalid tool
        logger.info("Testing invalid tool call...")
        await test_invalid_tool_call()
        
        logger.info("All tests completed")
    
    asyncio.run(main())
