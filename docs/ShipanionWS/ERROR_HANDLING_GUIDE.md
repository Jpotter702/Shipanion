# Error Handling for Failed REST Calls

This document explains the error handling implementation for failed REST calls to the ShipVox API.

## Overview

The WebSocket server has been updated to properly handle errors when making REST calls to the ShipVox API. When a call to `/get-rates` fails (non-200 response, timeout, or other error), the server now:

1. Logs the error with detailed information
2. Sends a `client_tool_result` back to the client with:
   - `is_error: true`
   - An error message in `result.error`
   - The original request in `result.original_request`

## Implementation Details

### 1. ShipVox Client

The `ShipVoxClient` class in `shipvox_client.py` has been updated to provide more detailed error information:

- **HTTP Status Errors**: When the API returns a non-200 status code, the client extracts the status code and any error details from the response.
- **Timeout Errors**: When a request times out, the client provides a clear error message with the timeout duration.
- **Network Errors**: When there's a network-related error, the client provides a descriptive error message.

All errors are logged with appropriate severity and context, and then propagated to the caller with meaningful error messages.

### 2. ElevenLabs Handler

The `handle_get_shipping_quotes` function in `elevenlabs_handler.py` has been updated to:

- Use a nested try-except block to specifically handle API errors
- Log detailed error information including the tool call ID
- Return a properly formatted `client_tool_result` with `is_error: true` and a descriptive error message

The `handle_create_label` function has been similarly updated to:

- Use explicit error handling for HTTP errors, timeouts, and network errors
- Use a consistent 10-second timeout for API requests
- Return properly formatted error responses with detailed error messages

### 3. Rate Request Handler

The `handle_rate_request` function in `handlers.py` has been similarly updated to:

- Use a nested try-except block to specifically handle API errors
- Log detailed error information including the request ID
- Return a properly formatted error response with `is_error: true` and a descriptive error message

## Error Response Format

### For Client Tool Calls

```json
{
  "type": "client_tool_result",
  "tool_call_id": "<tool_call_id>",
  "result": {
    "error": "Failed to get shipping rates: <detailed error message>",
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
    "message": "Failed to get shipping rates: <detailed error message>",
    "original_request": { ... },
    "is_error": true
  },
  "timestamp": 1650000000000,
  "requestId": "<request_id>",
  "user": "<username>"
}
```

## Testing

A new test file `tests/sprint3/test_error_handling.py` has been created to verify the error handling implementation. It includes tests for:

1. **Timeout Handling**: Using a special ZIP code `99999` to simulate a timeout
2. **Non-200 Response Handling**: Using an invalid ZIP code to trigger a 400 Bad Request

To run the tests:

```bash
cd /home/jason/Shipanion
pytest ShipanionWS/tests/sprint3/test_error_handling.py -v
```

The tests verify that:
- The server properly handles timeouts and returns an appropriate error message
- The server properly handles non-200 responses and returns an appropriate error message
- The error responses include the correct `is_error: true` flag and detailed error information

## Error Scenarios Handled

The implementation now properly handles the following error scenarios:

1. **Invalid Input**: When the client provides invalid input (e.g., invalid ZIP code)
2. **Missing Required Fields**: When required fields are missing from the request
3. **API Errors**: When the ShipVox API returns a non-200 status code
4. **Timeout Errors**: When the request to the ShipVox API times out
5. **Network Errors**: When there's a network-related error (e.g., connection refused)
6. **Unexpected Errors**: Any other unexpected errors that might occur

## Benefits

This improved error handling:

1. Provides clear and actionable error messages to clients
2. Logs detailed error information for debugging
3. Maintains a consistent error response format
4. Ensures that clients can gracefully handle error scenarios
5. Improves the overall reliability and user experience of the application
