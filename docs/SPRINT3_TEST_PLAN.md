# Sprint 3 Test Plan

This document outlines the test plan for Sprint 3 features of the Shipanion project.

## Test Environment

- **Backend**: ShipanionWS running locally on port 8000
- **Frontend**: ShipanionUI running locally on port 3000
- **ElevenLabs**: Configured with the appropriate tools and API keys

## Test Categories

1. **Step Tracking Tests**
2. **ElevenLabs Integration Tests**
3. **Session Continuity Tests**
4. **End-to-End Tests**

## 1. Step Tracking Tests

### 1.1 Step Reducer Test

**Test File**: `ShipanionUI/tests/sprint3/test-step-reducer.tsx`

**Test Steps**:
1. Navigate to the test page
2. Simulate ZIP_COLLECTED message
3. Verify current step is updated to ZIP_COLLECTED
4. Simulate WEIGHT_CONFIRMED message
5. Verify current step is updated to WEIGHT_CONFIRMED
6. Simulate QUOTE_READY message
7. Verify current step is updated to QUOTE_READY
8. Simulate LABEL_CREATED message
9. Verify current step is updated to LABEL_CREATED
10. Verify completed steps list contains all steps

**Expected Results**:
- Current step should update correctly for each message
- Completed steps should accumulate as steps are completed
- Last updated timestamp should update with each step change

### 1.2 StepperAccordion Test

**Test File**: `ShipanionUI/tests/sprint3/test-stepper-accordion.tsx`

**Test Steps**:
1. Navigate to the test page
2. Use the Current Step Controls to change the traditional currentStep value
3. Use the Step Reducer Controls to change the stepState values
4. Observe how the StepperAccordion updates to reflect the changes

**Expected Results**:
- Active step should be highlighted based on both currentStep and stepState.currentStep
- Completed steps should show check icons
- Visual enhancements like pulsing effects and ring highlights should be visible

### 1.3 Client Tool Result Test

**Test File**: `ShipanionUI/tests/sprint3/test-client-tool-result.tsx`

**Test Steps**:
1. Navigate to the test page
2. Click "Simulate Shipping Quotes Result"
3. Observe the QuotesCard component
4. Click "Simulate Error Result"
5. Observe the error handling
6. Click "Reset Quotes"

**Expected Results**:
- QuotesCard should display the shipping quotes when "Simulate Shipping Quotes Result" is clicked
- Error should be handled gracefully when "Simulate Error Result" is clicked
- Quotes should be cleared when "Reset Quotes" is clicked

### 1.4 Loading Quotes Test

**Test File**: `ShipanionUI/tests/sprint3/test-loading-quotes.tsx`

**Test Steps**:
1. Navigate to the test page
2. Click "Simulate Quote Request"
3. Observe the loading state in the QuotesCard
4. Wait for the quotes to load
5. Use "Set Loading: True" and "Set Loading: False" to manually control the loading state
6. Click "Reset"

**Expected Results**:
- QuotesCard should show a loading spinner when loading is true
- Loading state should automatically change to false when quotes are received
- Manual controls should work as expected

## 2. ElevenLabs Integration Tests

### 2.1 Bob's Quote Response Test

**Test File**: `ShipanionWS/tests/sprint3/test_bob_quote_response.py`

**Test Steps**:
1. Run the test script
2. Observe the WebSocket connection and message sending
3. Wait for the client_tool_result response
4. Verify the response format

**Expected Results**:
- WebSocket connection should be established successfully
- client_tool_call should be sent successfully
- client_tool_result should be received with the correct format
- Bob should speak the quotes aloud

### 2.2 Bob Speaks Quote Test

**Test File**: `ShipanionWS/tests/sprint3/test_bob_speaks_quote.py`

**Test Steps**:
1. Run the test script
2. Listen for Bob's spoken response
3. Verify that Bob mentions the carrier names, prices, and delivery times
4. Verify that Bob asks which option the user would prefer

**Expected Results**:
- Bob should speak the quotes aloud
- Bob should clearly mention the carrier names (UPS, USPS, FedEx)
- Bob should clearly mention the prices ($9.99, $12.99, $14.99)
- Bob should mention the delivery times
- Bob should ask which option the user would prefer

### 2.3 Contextual Update Test

**Test File**: `ShipanionWS/tests/sprint3/test_contextual_update.py`

**Test Steps**:
1. Run the test script
2. Observe the WebSocket connection and message sending
3. Wait for the client_tool_result response
4. Wait for the contextual update messages
5. Verify that both the UI and ElevenLabs receive contextual updates

**Expected Results**:
- WebSocket connection should be established successfully
- client_tool_call should be sent successfully
- client_tool_result should be received with the correct format
- UI contextual update should be received with structured data
- ElevenLabs contextual update should be received with a human-readable message

## 3. Session Continuity Tests

### 3.1 Session ID in Messages Test

**Test File**: `ShipanionWS/tests/sprint3/test_session_continuity.py`

**Test Steps**:
1. Run the test script
2. Observe the WebSocket connection and message sending
3. Verify that the response includes a session_id

**Expected Results**:
- WebSocket connection should be established successfully
- Response should include a session_id

### 3.2 Reconnect/Resume Test

**Test File**: `ShipanionUI/tests/sprint3/test-session-continuity.tsx`

**Test Steps**:
1. Navigate to the test page
2. Click "1. Send Test Message"
3. Click "2. Force Disconnect"
4. Click "3. Reconnect with Session ID"
5. Click "4. Request Session State"
6. Observe the session state

**Expected Results**:
- Session ID should be obtained after sending the test message
- Connection should be lost after forcing disconnect
- Connection should be re-established after reconnecting with session ID
- Session state should be retrieved successfully

### 3.3 ElevenLabs Session Resumption Test

**Test File**: `ShipanionWS/tests/sprint3/test_session_continuity.py`

**Test Steps**:
1. Run the test script
2. Observe the WebSocket connection and message sending
3. Verify that the tool call includes the session_id in metadata
4. Verify that the response includes the session_id

**Expected Results**:
- WebSocket connection should be established successfully
- Tool call should include the session_id in metadata
- Response should include the session_id

## 4. End-to-End Tests

### 4.1 Full Shipping Flow Test

**Test Steps**:
1. Open the Shipanion UI
2. Enter shipping details (origin ZIP, destination ZIP, weight)
3. Observe the step indicator updating to ZIP_COLLECTED
4. Confirm the weight
5. Observe the step indicator updating to WEIGHT_CONFIRMED
6. Wait for shipping quotes to load
7. Observe the step indicator updating to QUOTE_READY
8. Select a shipping option
9. Wait for the label to be created
10. Observe the step indicator updating to LABEL_CREATED
11. Verify that Bob speaks at each step

**Expected Results**:
- Step indicator should update correctly at each step
- Bob should speak appropriately at each step
- Shipping quotes should load with a loading spinner
- Label should be created successfully

### 4.2 Session Continuity End-to-End Test

**Test Steps**:
1. Open the Shipanion UI
2. Enter shipping details and proceed to the quotes step
3. Note the session ID (from browser storage or network tab)
4. Close the browser
5. Reopen the Shipanion UI
6. Verify that the session is resumed
7. Verify that Bob remembers the context

**Expected Results**:
- Session should be resumed successfully
- UI should restore to the quotes step
- Bob should remember the context of the conversation

## Test Execution

To run all tests, execute the following commands:

```bash
# Backend tests
cd ShipanionWS
python -m tests.sprint3.test_bob_quote_response
python -m tests.sprint3.test_bob_speaks_quote
python -m tests.sprint3.test_contextual_update
python -m tests.sprint3.test_session_continuity

# Frontend tests
cd ShipanionUI
# Navigate to the test pages in your browser:
# - http://localhost:3000/tests/sprint3/test-step-reducer
# - http://localhost:3000/tests/sprint3/test-stepper-accordion
# - http://localhost:3000/tests/sprint3/test-client-tool-result
# - http://localhost:3000/tests/sprint3/test-loading-quotes
# - http://localhost:3000/tests/sprint3/test-session-continuity
```

## Test Reporting

After executing the tests, document the results in a test report that includes:

1. Test name
2. Pass/Fail status
3. Any issues encountered
4. Screenshots or logs if applicable
5. Recommendations for fixes or improvements

## Troubleshooting

If tests fail, consider the following troubleshooting steps:

1. **WebSocket Connection Issues**:
   - Verify that the WebSocket server is running
   - Check that the WebSocket URL is correct
   - Ensure that authentication is working

2. **ElevenLabs Integration Issues**:
   - Verify that ElevenLabs is configured correctly
   - Check that the tool definitions match the expected format
   - Ensure that the API keys are valid

3. **Session Continuity Issues**:
   - Check that session IDs are being generated and stored correctly
   - Verify that session state is being maintained
   - Ensure that reconnection logic is working

4. **UI Rendering Issues**:
   - Check the browser console for errors
   - Verify that the component props are correct
   - Ensure that state updates are triggering re-renders
