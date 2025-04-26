# Timeout Handling for REST Calls

This document explains the timeout handling implementation for REST calls to the ShipVox API.

## Overview

The WebSocket server has been updated to properly handle timeouts when making REST calls to the ShipVox API. When a call to `/get-rates` takes too long, the server now:

1. Logs the timeout error with detailed information
2. Sends a `client_tool_result` back to the client with:
   - `is_error: true`
   - The exact error message `timeout calling rates endpoint`

## Implementation Details

### 1. ShipVox Client

The `ShipVoxClient` class in `shipvox_client.py` has been updated to:

- Accept a `timeout_seconds` parameter in the `get_rates` method (default: 10.0 seconds)
- Create a specific `httpx.Timeout` object for each request
- Catch `httpx.TimeoutException` and raise a new exception with the exact error message `timeout calling rates endpoint`

```python
async def get_rates(self, rate_request: Dict[str, Any], timeout_seconds: float = 10.0) -> Dict[str, Any]:
    # ...
    # Create a specific timeout for this request
    timeout = httpx.Timeout(timeout_seconds)

    try:
        response = await self.client.post(url, json=rate_request, timeout=timeout)
        # ...
    except httpx.TimeoutException as e:
        logger.error(f"Rate request timed out after {timeout_seconds} seconds: {str(e)}")
        # Use the exact error message specified in the requirements
        raise Exception("timeout calling rates endpoint")
    # ...
```

### 2. ElevenLabs Handler

The `handle_get_shipping_quotes` function in `elevenlabs_handler.py` has been updated to:

- Call `shipvox_client.get_rates` with a 10-second timeout
- Handle the timeout exception and return a properly formatted error response

### 3. Rate Request Handler

The `handle_rate_request` function in `handlers.py` has been similarly updated to:

- Call `shipvox_client.get_rates` with a 10-second timeout
- Handle the timeout exception and return a properly formatted error response

## Error Response Format

### For Client Tool Calls

```json
{
  "type": "client_tool_result",
  "tool_call_id": "<tool_call_id>",
  "result": {
    "error": "timeout calling rates endpoint",
    "original_request": { ... }
  },
  "is_error": true,
  "timestamp": 1650000000000,
  "requestId": "<request_id>"
}
```

### For Direct Rate Requests

```json
{
  "type": "error",
  "payload": {
    "message": "Failed to get shipping rates: timeout calling rates endpoint",
    "original_request": { ... },
    "is_error": true
  },
  "timestamp": 1650000000000,
  "requestId": "<request_id>",
  "user": "<username>"
}
```

## Testing

A new test file `tests/sprint3/test_timeout_handling.py` has been created to verify the timeout handling implementation. It includes tests for:

1. **Client Tool Call Timeout**: Tests that a client tool call with a special ZIP code that triggers a timeout returns the correct error response
2. **Direct Rate Request Timeout**: Tests that a direct rate request with a special ZIP code that triggers a timeout returns the correct error response

To run the tests:

```bash
cd /home/jason/Shipanion
pytest ShipanionWS/tests/sprint3/test_timeout_handling.py -v
```

The tests verify that:
- The server properly handles timeouts and returns an appropriate error message
- The error responses include the correct `is_error: true` flag
- The error message is exactly `timeout calling rates endpoint` as required

### Special Test ZIP Code

The tests use a special ZIP code `99999` to trigger a timeout. When this ZIP code is used in a rate request, the internal shipping service simulates a timeout by raising a `TimeoutError` exception.

## Benefits

This improved timeout handling:

1. Ensures that the client receives a clear error message when a request times out
2. Prevents the WebSocket connection from hanging indefinitely
3. Allows the client to gracefully handle timeout scenarios
4. Improves the overall reliability and user experience of the application
