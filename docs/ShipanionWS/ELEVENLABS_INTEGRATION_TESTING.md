# ElevenLabs Integration Testing Guide

This document explains how to test the integration between ElevenLabs Conversational AI, the WebSocket server, and the UI.

## Overview

The integration between ElevenLabs Conversational AI (Bob) and the Shipanion system involves several components:

1. **ElevenLabs Conversational AI**: The voice assistant that interacts with users and makes tool calls
2. **WebSocket Server**: The server that handles WebSocket connections and processes tool calls
3. **UI**: The user interface that displays shipping information and updates in real-time

The test verifies that:
- ElevenLabs can make tool calls to get shipping quotes and create labels
- The WebSocket server correctly processes these tool calls
- The WebSocket server sends appropriate responses back to ElevenLabs
- The WebSocket server broadcasts contextual updates to all clients in the same session
- The UI receives and can display these updates

## Test Files

The following test files are provided:

1. `test_elevenlabs_integration.py`: Basic tests for ElevenLabs client tool calls
2. `test_elevenlabs_full_flow.py`: Comprehensive tests for the full flow between ElevenLabs, WebSocket server, and UI

## Running the Tests

### Prerequisites

- The WebSocket server is running on `localhost:8000`
- The API server is running on `localhost:8000`
- Python 3.8+ with required packages installed

### Basic Integration Test

```bash
cd ShipanionWS/tests/sprint2
python test_elevenlabs_integration.py
```

This test verifies that:
- Valid tool calls receive correct responses
- Invalid tool calls receive appropriate error messages
- Unsupported tool calls receive appropriate error messages

### Full Flow Test

```bash
cd ShipanionWS/tests/sprint2
./run_elevenlabs_test.sh
```

This test verifies the complete flow:
1. ElevenLabs makes a tool call to get shipping quotes
2. The WebSocket server processes the tool call and sends a response
3. ElevenLabs receives the response and can speak the quote information
4. The UI receives contextual updates and can display them

## Test Scenarios

### Scenario 1: Get Shipping Quotes

1. ElevenLabs makes a `get_shipping_quotes` tool call with origin ZIP, destination ZIP, and weight
2. The WebSocket server processes the tool call and gets quotes from the ShipVox API
3. The WebSocket server sends a `client_tool_result` message back to ElevenLabs
4. The WebSocket server broadcasts a `contextual_update` message to all clients in the session
5. ElevenLabs receives the `client_tool_result` and speaks the quote information
6. The UI receives the `contextual_update` and displays the quotes

### Scenario 2: Create Shipping Label

1. ElevenLabs makes a `create_label` tool call with shipper, recipient, and package information
2. The WebSocket server processes the tool call and creates a label using the ShipVox API
3. The WebSocket server sends a `client_tool_result` message back to ElevenLabs
4. The WebSocket server broadcasts a `contextual_update` message to all clients in the session
5. ElevenLabs receives the `client_tool_result` and speaks the label information
6. The UI receives the `contextual_update` and displays the label

## Message Formats

### Client Tool Call (from ElevenLabs)

```json
{
  "type": "client_tool_call",
  "client_tool_call": {
    "tool_name": "get_shipping_quotes",
    "tool_call_id": "elevenlabs-123",
    "parameters": {
      "from_zip": "90210",
      "to_zip": "10001",
      "weight": 5.0
    }
  },
  "session_id": "test-session-123",
  "broadcast": true
}
```

### Client Tool Result (to ElevenLabs)

```json
{
  "type": "client_tool_result",
  "tool_call_id": "elevenlabs-123",
  "result": [
    {
      "carrier": "FedEx",
      "service": "Priority Overnight",
      "price": 45.99,
      "eta": "1 days"
    },
    {
      "carrier": "USPS",
      "service": "Priority Mail",
      "price": 12.99,
      "eta": "3 days"
    }
  ],
  "is_error": false,
  "timestamp": 1650000001000,
  "requestId": "550e8400-e29b-41d4-a716-446655440001"
}
```

### Contextual Update (to all clients)

```json
{
  "type": "contextual_update",
  "text": "quote_ready",
  "data": {
    "message": "Quote ready from FedEx Priority Overnight for $45.99",
    "tool_name": "get_shipping_quotes",
    "is_error": false
  },
  "timestamp": 1650000001000,
  "requestId": "550e8400-e29b-41d4-a716-446655440001",
  "user": "username",
  "session_id": "test-session-123"
}
```

## Troubleshooting

### Common Issues

1. **Connection Refused**: Make sure the WebSocket server is running on the correct port
2. **Authentication Failed**: Make sure the test token is valid
3. **Tool Call Failed**: Check the parameters in the tool call
4. **Missing Contextual Update**: Make sure the session ID is correctly set

### Debugging

The test script includes detailed logging. Run it with the Python debugger for step-by-step execution:

```bash
python -m pdb test_elevenlabs_full_flow.py
```

## Next Steps

After verifying that the integration works correctly, you can:

1. Register the tools in the ElevenLabs dashboard
2. Configure the ElevenLabs agent to use these tools
3. Test the integration with the actual ElevenLabs agent
