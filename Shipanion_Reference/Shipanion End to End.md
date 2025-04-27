Comprehensive Plan for Testing ElevenLabs WebSocket Integration
Phase 1: Environment Setup and Verification
Start the Middleware Server (ShipanionMW)
Verify the middleware server is running on port 8003
Confirm the API endpoints are accessible (especially /api/labels and /get-rates)
Test basic API functionality with curl or Postman
Start the WebSocket Server (ShipanionWS)
Verify the WebSocket server is running on port 8000
Confirm the /test-token endpoint is accessible
Test basic WebSocket connectivity
Start the UI Server (ShipanionUI)
Verify the UI server is running on port 3000
Confirm the UI is accessible in the browser
Test basic UI functionality and navigation
Verify Authentication
Obtain a test token from the /test-token endpoint
Establish a WebSocket connection using the token
Confirm successful authentication in both WebSocket and UI
Phase 2: Middleware-WebSocket Integration Testing
Test Middleware-WebSocket Communication
Verify the WebSocket server can communicate with the middleware
Test rate requests from WebSocket to middleware
Test label creation requests from WebSocket to middleware
Test FedEx API Integration
Verify the middleware can authenticate with FedEx API
Test rate requests to FedEx API
Test label creation with FedEx API
Verify special services (Saturday delivery, signature requirements) work correctly
Phase 3: UI Integration Testing
Test UI-WebSocket Connection
Verify the UI can establish a WebSocket connection
Test message exchange between UI and WebSocket server
Confirm the UI can handle different message types
Test UI Components
Test the StepperAccordion component
Verify the QuotesCard component displays shipping quotes correctly
Test the loading states and animations
Confirm error handling and display in the UI
Test UI State Management
Verify the step reducer correctly tracks shipping steps
Test state updates based on WebSocket messages
Confirm the UI reflects the current state of the shipping process
Phase 4: ElevenLabs Integration Testing
Test get_shipping_quotes Tool Call
Send a client_tool_call message with the get_shipping_quotes tool
Verify the WebSocket server forwards the request to the middleware
Confirm the middleware processes the request and returns rates
Verify the WebSocket server formats and returns the client_tool_result
Simultaneously check that the UI updates with the shipping quotes
Check that the response includes shipping quotes with carrier, price, and ETA
Test create_label Tool Call
Send a client_tool_call message with the create_label tool
Verify the WebSocket server forwards the request to the middleware
Confirm the middleware processes the request and creates a label
Verify the WebSocket server formats and returns the client_tool_result
Simultaneously check that the UI updates with the label information
Check that the response includes tracking number and label URL
Test Contextual Updates
Verify that after a tool call, contextual updates are sent
Confirm both the UI and ElevenLabs receive appropriate updates
Verify the UI components update in real-time with the contextual data
Check that the updates contain the expected data
Test Session Continuity with ElevenLabs
Send a tool call with a session ID
Disconnect and reconnect with the same session ID
Verify the session state is maintained across the entire stack
Confirm the UI state is restored after reconnection
Phase 5: End-to-End Testing with Parallel UI Updates
Test Full Shipping Flow with UI
Simulate a complete shipping flow from ZIP collection to label creation
Verify all steps are tracked correctly in the UI (StepperAccordion)
Confirm the UI updates in real-time as ElevenLabs processes the flow
Verify the middleware correctly processes all requests
Confirm the FedEx API integration works throughout the flow
Test the synchronization between voice interactions and UI updates
Test Error Handling with UI Feedback
Simulate error conditions at each layer (WebSocket, middleware, FedEx API)
Verify appropriate error responses are propagated through the stack
Confirm the UI displays error messages and recovery options
Confirm ElevenLabs can handle and communicate errors
Test Special Services with UI Confirmation
Test Saturday delivery with UI confirmation
Test signature requirements with UI display
Test other special services supported by FedEx
Verify the UI correctly displays the selected special services
Phase 6: Multi-Device Testing
Test Simultaneous Connections
Connect multiple devices to the same session
Verify updates are broadcast to all connected devices
Confirm the UI state is consistent across all devices
Test Device Handoff
Start a shipping process on one device
Continue the process on another device using the same session ID
Verify the state is correctly transferred between devices
Confirm both the UI and ElevenLabs maintain context during handoff
Deliverables
Test Results Report
Document the results of each test
Note any issues or discrepancies
Provide recommendations for improvements
Sample Code
Create reusable test scripts for future testing
Document how to use the scripts
Integration Documentation
Update or create documentation on the complete integration flow
Include sample code and configuration for all components
Document the UI-WebSocket-ElevenLabs synchronization
Timeline
Phase 1: 1 day
Phase 2: 2 days
Phase 3: 2 days
Phase 4: 2 days
Phase 5: 2 days
Phase 6: 1 day
Documentation and reporting: 1 day
Total: 11 days

This comprehensive plan now includes the UI server, testing of UI components, and verification of simultaneous updates to the UI as ElevenLabs interacts with the system.