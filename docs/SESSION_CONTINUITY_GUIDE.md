# Session Continuity Guide

This guide explains how session continuity is implemented in the Shipanion application, allowing users to reconnect and resume their session where they left off.

## Overview

Session continuity ensures that users can disconnect and reconnect to the application without losing their progress. This is achieved by:

1. Adding a `session_id` to all WebSocket messages
2. Implementing reconnect/resume logic in the UI
3. Configuring ElevenLabs to carry `session_id` in tool call metadata

## Implementation Details

### 1. Session ID in Messages

#### JWT Decoding and Session ID Extraction

The WebSocket server extracts the `session_id` from the query parameters and attaches it to every outbound WebSocket message:

```python
# Extract session_id from query parameters
session_id = websocket.query_params.get("session_id")

# If token is valid, proceed with connection
await manager.connect(websocket, user_info, session_id)

# Add session ID to the message if available
if session_id and not data.get('session_id'):
    data['session_id'] = session_id

# Add session ID to the contextual update
if session_id:
    contextual_update['session_id'] = session_id
    await manager.broadcast_to_session(session_id, contextual_update)
```

#### Session Management

The WebSocket connection manager maintains a mapping of connections to sessions:

```python
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []
        self.connection_info: Dict[WebSocket, Dict[str, Any]] = {}
        self.sessions: Dict[WebSocket, str] = {}
    
    async def connect(self, websocket: WebSocket, user_info: Dict[str, Any], session_id: Optional[str] = None):
        await websocket.accept()
        self.active_connections.append(websocket)
        self.connection_info[websocket] = user_info

        # Create a new session or use the provided one
        if not session_id:
            session_id = create_session(user_info)

        # Store the session ID with the connection
        self.sessions[websocket] = session_id
        websocket.session_id = session_id
```

### 2. Reconnect/Resume Logic in UI

#### WebSocket Hook Enhancement

The `useWebSocket` hook has been enhanced to handle disconnections and reconnections:

```typescript
// Reconnection logic
useEffect(() => {
  if (!isConnected && !error && reconnectAttemptsRef.current < maxReconnectAttempts) {
    const timer = setTimeout(() => {
      console.log(`Attempting to reconnect (${reconnectAttemptsRef.current + 1}/${maxReconnectAttempts})...`)
      reconnectAttemptsRef.current += 1
      connectWebSocket()
    }, reconnectInterval)

    return () => clearTimeout(timer)
  }
}, [isConnected, error, reconnectInterval, maxReconnectAttempts])
```

#### Session State Restoration

When reconnecting with a `session_id`, the UI requests the last known state:

```typescript
// Request last known state when reconnecting with session_id
useEffect(() => {
  if (isConnected && sessionId && !initialStateRequested.current) {
    initialStateRequested.current = true
    
    // Request the last known state
    sendMessage({
      type: 'get_session_state',
      session_id: sessionId
    })
  }
}, [isConnected, sessionId, sendMessage])
```

#### UI Position Restoration

The UI restores its position based on the last known state:

```typescript
// Restore UI position based on session state
useEffect(() => {
  if (sessionState) {
    // Set the current step
    setCurrentStep(sessionState.currentStep)
    
    // Restore scroll position if available
    if (sessionState.scrollPosition) {
      window.scrollTo(0, sessionState.scrollPosition)
    }
  }
}, [sessionState])
```

### 3. ElevenLabs Session Resumption

#### Session ID in Tool Call Metadata

ElevenLabs is configured to carry `session_id` in tool call metadata:

```json
{
  "type": "client_tool_call",
  "client_tool_call": {
    "tool_name": "get_shipping_quotes",
    "tool_call_id": "abc123",
    "parameters": {
      "from_zip": "90210",
      "to_zip": "10001",
      "weight": 5.0
    },
    "metadata": {
      "session_id": "session-123456"
    }
  }
}
```

#### Session State Retrieval

When Bob receives a message with a `session_id`, it retrieves the session state:

```python
# Extract session_id from tool call metadata
session_id = client_tool_call.get("metadata", {}).get("session_id")

# If session_id is available, retrieve the session state
if session_id:
    session_state = get_session(session_id)
    
    # Use the session state to provide context for Bob
    if session_state:
        # Add session context to the response
        response_context = create_session_context(session_state)
        return response_context
```

#### Conversation Continuity

Bob uses the session state to continue the conversation where it left off:

```python
def create_session_context(session_state):
    """Create context for Bob based on session state."""
    context = "Previous conversation summary:\n"
    
    # Add shipping details if available
    if session_state.get("shipping_details"):
        details = session_state["shipping_details"]
        context += f"- Shipping from {details['from']} to {details['to']}\n"
        context += f"- Package weight: {details['weight_lbs']} lbs\n"
    
    # Add quotes if available
    if session_state.get("quotes"):
        quotes = session_state["quotes"]
        context += "- Shipping quotes received:\n"
        for quote in quotes:
            context += f"  - {quote['carrier']} {quote['service']}: ${quote['cost']}\n"
    
    # Add label if available
    if session_state.get("label"):
        label = session_state["label"]
        context += f"- Label created with tracking number: {label['tracking_number']}\n"
    
    return context
```

## Session State Storage

Session state is stored in a database or in-memory store:

```python
# In-memory session store (for development)
sessions = {}

def create_session(user_info):
    """Create a new session."""
    session_id = f"session-{uuid.uuid4()}"
    sessions[session_id] = {
        "user_info": user_info,
        "created_at": time.time(),
        "last_updated": time.time(),
        "state": {}
    }
    return session_id

def get_session(session_id):
    """Get a session by ID."""
    return sessions.get(session_id)

def update_session_state(session_id, state):
    """Update the state of a session."""
    if session_id in sessions:
        sessions[session_id]["state"] = state
        sessions[session_id]["last_updated"] = time.time()
        return True
    return False
```

## Testing

A test script has been created to verify session continuity:

```bash
python ShipanionWS/tests/sprint3/test_session_continuity.py
```

This script:

1. Connects to the WebSocket server
2. Sends messages to establish a session
3. Disconnects and reconnects with the same `session_id`
4. Verifies that the session state is restored
5. Checks that Bob continues the conversation where it left off

## Benefits

1. **Improved User Experience**: Users can disconnect and reconnect without losing their progress
2. **Conversation Continuity**: Bob remembers the context of the conversation
3. **Multi-Device Support**: Users can switch devices and continue their session
4. **Resilience to Network Issues**: The application can recover from network disruptions

## Future Improvements

1. **Persistent Session Storage**: Store sessions in a database for better durability
2. **Session Expiration**: Implement session expiration and cleanup
3. **Session Sharing**: Allow users to share sessions with others
4. **Session History**: Provide a way for users to view and restore previous sessions
