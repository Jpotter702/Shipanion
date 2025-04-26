# Contextual Update Guide

This guide explains how contextual updates are sent to both ElevenLabs and the AccordionStepper UI after returning a `client_tool_result`.

## Overview

When a `client_tool_call` is processed and a `client_tool_result` is returned, the system now sends a second WebSocket message with `type: contextual_update` containing a short sentence about the result. This helps Bob (the ElevenLabs conversational AI) stay aware of the session state and provides structured data to the AccordionStepper UI.

## Implementation Details

### 1. Contextual Update Creation

The system creates two types of contextual updates:

1. **UI Contextual Update**: Contains structured data for the AccordionStepper UI
2. **ElevenLabs Contextual Update**: Contains a human-readable message for Bob

#### UI Contextual Update

```json
{
  "type": "contextual_update",
  "text": "quote_ready",
  "data": {
    "from": "90210",
    "to": "10001",
    "weight_lbs": 5.0,
    "carrier": "UPS",
    "service": "Ground",
    "price": 12.99,
    "eta": "3-5 days",
    "message": "Quote ready from UPS Ground for $12.99"
  },
  "timestamp": 1623456789.123,
  "requestId": "abc-123-def-456",
  "user": "testuser"
}
```

#### ElevenLabs Contextual Update

```json
{
  "type": "contextual_update",
  "text": "get_shipping_quotes_result",
  "data": {
    "message": "Quote ready from UPS for $12.99",
    "tool_name": "get_shipping_quotes",
    "is_error": false
  },
  "timestamp": 1623456789.123,
  "requestId": "abc-123-def-456",
  "user": "testuser"
}
```

### 2. Message Flow

1. Client sends a `client_tool_call` message
2. Server processes the message and calls the appropriate handler
3. Handler returns a `client_tool_result` and a contextual update
4. Server creates a second contextual update specifically for ElevenLabs
5. Server sends the `client_tool_result` to the client
6. Server broadcasts both contextual updates to all clients in the session

### 3. Code Structure

#### Creating Contextual Updates

The `contextual_update.py` module provides functions for creating contextual updates:

```python
def create_contextual_update(
    update_type: str,
    data: Dict[str, Any],
    user_info: Dict[str, Any],
    request_id: Optional[str] = None
) -> Dict[str, Any]:
    """Create a contextual update message."""
    return {
        "type": "contextual_update",
        "text": update_type,
        "data": data,
        "timestamp": time.time(),
        "requestId": request_id or str(uuid.uuid4()),
        "user": user_info.get("username")
    }
```

#### Creating ElevenLabs Contextual Updates

The `elevenlabs_handler.py` module provides a function for creating ElevenLabs-specific contextual updates:

```python
def create_elevenlabs_contextual_update(
    tool_result: Dict[str, Any],
    tool_name: str,
    user_info: Dict[str, Any]
) -> Dict[str, Any]:
    """Create a contextual update specifically for ElevenLabs."""
    # Extract information from the tool result
    is_error = tool_result.get("is_error", False)
    result = tool_result.get("result", {})
    
    if is_error:
        # Create an error message
        message = f"Error processing {tool_name}: {result.get('error', 'Unknown error')}"
    else:
        # Create a success message based on the tool name
        if tool_name == "get_shipping_quotes":
            # For shipping quotes, extract the cheapest option
            if isinstance(result, list) and len(result) > 0:
                cheapest = min(result, key=lambda x: x.get("price", float("inf")))
                carrier = cheapest.get("carrier", "")
                price = cheapest.get("price", 0)
                message = f"Quote ready from {carrier} for ${price:.2f}"
            else:
                message = "Shipping quotes received"
        elif tool_name == "create_label":
            # For label creation, extract the tracking number
            tracking_number = result.get("tracking_number", "")
            carrier = result.get("carrier", "")
            message = f"Label created with {carrier} tracking number {tracking_number}"
        else:
            # Generic message for other tools
            message = f"{tool_name} completed successfully"
    
    # Create the contextual update
    return {
        "type": "contextual_update",
        "text": f"{tool_name}_result",
        "data": {
            "message": message,
            "tool_name": tool_name,
            "is_error": is_error
        },
        "timestamp": time.time(),
        "requestId": tool_result.get("requestId", str(uuid.uuid4())),
        "user": user_info.get("username")
    }
```

#### Handling Client Tool Calls

The `handle_client_tool_call` function in `elevenlabs_handler.py` has been updated to create and return both contextual updates:

```python
async def handle_client_tool_call(message: Dict[str, Any], user_info: Dict[str, Any]) -> Tuple[Dict[str, Any], Optional[Dict[str, Any]]]:
    """Handle a client_tool_call message from ElevenLabs."""
    # ...
    
    # Call the appropriate handler
    tool_result, contextual_update = await tool_handlers[tool_name](client_tool_call, user_info)
    
    # Create a second contextual update specifically for ElevenLabs
    elevenlabs_update = create_elevenlabs_contextual_update(
        tool_result=tool_result,
        tool_name=tool_name,
        user_info=user_info
    )
    
    # Combine the two contextual updates
    if contextual_update:
        # Return both updates as a list
        return tool_result, [contextual_update, elevenlabs_update]
    else:
        # Return just the ElevenLabs update
        return tool_result, elevenlabs_update
    
    # ...
```

#### Broadcasting Contextual Updates

The WebSocket endpoint in `main.py` has been updated to handle multiple contextual updates:

```python
# If there's a contextual update, broadcast it to the session
if contextual_update:
    # Check if it's a list of updates
    if isinstance(contextual_update, list):
        for update in contextual_update:
            if session_id:
                # Add session ID to the contextual update
                update['session_id'] = session_id
                await manager.broadcast_to_session(session_id, update)
            else:
                # No session, broadcast to all
                await manager.broadcast(update)
    else:
        # Single update
        if session_id:
            # Add session ID to the contextual update
            contextual_update['session_id'] = session_id
            await manager.broadcast_to_session(session_id, contextual_update)
        else:
            # No session, broadcast to all
            await manager.broadcast(contextual_update)
```

## Testing

A test script has been created to verify that both ElevenLabs and the AccordionStepper UI receive contextual updates:

```bash
python tests/sprint3/test_contextual_update.py
```

This script:

1. Connects to the WebSocket server
2. Sends a `client_tool_call` message
3. Waits for the `client_tool_result` response
4. Waits for the contextual update messages
5. Verifies that both the UI and ElevenLabs receive contextual updates

## Benefits

1. **Improved User Experience**: Bob can acknowledge the quote information, making the conversation more natural
2. **Better Session Awareness**: Bob stays aware of the session state, even if the user changes topics
3. **Structured Data for UI**: The AccordionStepper UI receives structured data to update its display
4. **Consistent Information**: Both Bob and the UI receive the same information, ensuring consistency
