# Shipanion Test Scenarios

This document describes the test scenarios for the Shipanion application.

## Overview

The test scenarios cover all the key use cases of the Shipanion application:

1. WebSocket Connection and Authentication
2. Session Management
3. Shipping Rate Requests
4. Label Creation
5. Contextual Updates
6. ElevenLabs Integration
7. Frontend-Backend Integration
8. Sound Effects

## Test Files

| Test Scenario | Test File | Description |
|---------------|-----------|-------------|
| WebSocket Connection and Authentication | `01_websocket_auth_test.sh` | Tests WebSocket connection with valid and invalid tokens |
| Session Management | `02_session_management_test.sh` | Tests session creation, reconnection, and session state |
| Shipping Rate Requests | `03_shipping_rate_test.sh` | Tests shipping rate requests and responses |
| Label Creation | `04_label_creation_test.sh` | Tests label creation and contextual updates |
| Contextual Updates | `05_contextual_updates_test.sh` | Tests broadcasting of contextual updates to multiple clients |
| ElevenLabs Integration | `06_elevenlabs_integration_test.py` | Tests integration with ElevenLabs client tools |
| Frontend-Backend Integration | `07_frontend_backend_integration_test.js` | Tests frontend integration with the WebSocket server |
| Sound Effects | `08_sound_effects_test.js` | Tests sound effects implementation in the frontend |

## Running the Tests

### Backend Tests

The backend tests can be run using the master test script:

```bash
cd test_scenarios
chmod +x run_all_tests.sh
./run_all_tests.sh
```

This script will:
1. Check if the servers are running
2. Run all the backend tests
3. Provide instructions for running the frontend tests
4. Report the test results

### Individual Tests

You can also run individual tests:

```bash
# WebSocket Authentication Test
./01_websocket_auth_test.sh

# Session Management Test
./02_session_management_test.sh

# Shipping Rate Requests Test
./03_shipping_rate_test.sh

# Label Creation Test
./04_label_creation_test.sh

# Contextual Updates Test
./05_contextual_updates_test.sh

# ElevenLabs Integration Test
python -m pytest 06_elevenlabs_integration_test.py -v
```

### Frontend Tests

The frontend tests need to be run manually in the browser console:

1. Open the frontend in your browser (http://localhost:3001)
2. Open the browser console (F12 or Ctrl+Shift+J)
3. Copy and paste the content of `07_frontend_backend_integration_test.js`
4. Run the tests with: `window.shipanionTests.runAllTests()`
5. Copy and paste the content of `08_sound_effects_test.js`
6. Run the tests with: `window.shipanionSoundTests.runAllTests()`

## Test Scenarios Details

### 1. WebSocket Connection and Authentication

- **Test 1**: Get a valid token
- **Test 2**: Connect with valid token
- **Test 3**: Connect without token (should be rejected)
- **Test 4**: Connect with invalid token (should be rejected)

### 2. Session Management

- **Test 1**: Create a new session
- **Test 2**: Connect to existing session
- **Test 3**: Connect with invalid session ID (should create a new session)

### 3. Shipping Rate Requests

- **Test 1**: Basic rate request
- **Test 2**: Invalid rate request (missing required fields)
- **Test 3**: Rate request with contextual update

### 4. Label Creation

- **Test 1**: Create label using client tool
- **Test 2**: Invalid label request (missing required fields)

### 5. Contextual Updates

- **Test 1**: Create a session and listen for updates
- **Test 2**: Send a rate request to trigger a contextual update
- **Test 3**: Create a second listener in the same session
- **Test 4**: Send a label request to trigger another contextual update

### 6. ElevenLabs Integration

- **Test 1**: Test the get_shipping_quotes tool
- **Test 2**: Test the create_label tool
- **Test 3**: Test invalid tool call

### 7. Frontend-Backend Integration

- **Test 1**: WebSocket Connection
- **Test 2**: Shipping Rate Request
- **Test 3**: Session Management

### 8. Sound Effects

- **Test 1**: Sound Utility Module
- **Test 2**: Sound Toggle Component
- **Test 3**: StepperAccordion Sound Effects
- **Test 4**: WebSocket Event Sounds

## Expected Results

All tests should pass, indicating that:

1. The WebSocket server correctly handles authentication
2. Session management works as expected
3. Shipping rate requests return valid quotes
4. Label creation works and triggers contextual updates
5. Contextual updates are broadcast to all clients in the same session
6. ElevenLabs client tools are properly integrated
7. The frontend correctly integrates with the WebSocket server
8. Sound effects work as expected in the frontend

## Troubleshooting

If tests fail, check:

1. Server logs for errors
2. Network requests in the browser developer tools
3. Console output for error messages
4. WebSocket connection status
5. Test script output for specific failure points
