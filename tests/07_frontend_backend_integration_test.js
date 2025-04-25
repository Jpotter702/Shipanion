/**
 * Frontend-Backend Integration Test
 * 
 * This script tests the integration between the ShipanionUI frontend and the WebSocket backend.
 * It can be run in a browser console when the frontend is loaded.
 */

// Configuration
const WS_SERVER_URL = 'ws://localhost:8001/ws';
const API_SERVER_URL = 'http://localhost:8001';

// Test results
const testResults = {
  passed: 0,
  failed: 0,
  total: 0
};

// Helper function to log test results
function logTest(name, passed, message) {
  testResults.total++;
  if (passed) {
    testResults.passed++;
    console.log(`%c✓ ${name}: ${message}`, 'color: green; font-weight: bold');
  } else {
    testResults.failed++;
    console.log(`%c✗ ${name}: ${message}`, 'color: red; font-weight: bold');
  }
}

// Helper function to get a test token
async function getTestToken() {
  try {
    const response = await fetch(`${API_SERVER_URL}/test-token`);
    const data = await response.json();
    return data.test_token;
  } catch (error) {
    console.error('Error getting test token:', error);
    return null;
  }
}

// Test 1: WebSocket Connection
async function testWebSocketConnection() {
  console.log('%cTest 1: WebSocket Connection', 'color: blue; font-weight: bold');
  
  try {
    const token = await getTestToken();
    if (!token) {
      logTest('WebSocket Connection', false, 'Failed to get test token');
      return;
    }
    
    const ws = new WebSocket(`${WS_SERVER_URL}?token=${token}`);
    
    return new Promise((resolve) => {
      ws.onopen = () => {
        logTest('WebSocket Connection', true, 'Successfully connected to WebSocket server');
        
        // Send a ping message
        const pingMessage = {
          type: 'ping',
          payload: {
            message: 'Hello from frontend test'
          },
          timestamp: Date.now(),
          requestId: `test-${Date.now()}`
        };
        
        ws.send(JSON.stringify(pingMessage));
      };
      
      ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          logTest('WebSocket Message', true, 'Received response from server');
          console.log('Response:', data);
          
          // Close the connection after receiving a message
          ws.close();
          resolve();
        } catch (error) {
          logTest('WebSocket Message', false, `Error parsing message: ${error.message}`);
          ws.close();
          resolve();
        }
      };
      
      ws.onerror = (error) => {
        logTest('WebSocket Connection', false, `Error connecting to WebSocket server: ${error.message}`);
        resolve();
      };
      
      ws.onclose = () => {
        console.log('WebSocket connection closed');
      };
    });
  } catch (error) {
    logTest('WebSocket Connection', false, `Unexpected error: ${error.message}`);
  }
}

// Test 2: Shipping Rate Request
async function testShippingRateRequest() {
  console.log('%cTest 2: Shipping Rate Request', 'color: blue; font-weight: bold');
  
  try {
    const token = await getTestToken();
    if (!token) {
      logTest('Shipping Rate Request', false, 'Failed to get test token');
      return;
    }
    
    const ws = new WebSocket(`${WS_SERVER_URL}?token=${token}`);
    
    return new Promise((resolve) => {
      ws.onopen = () => {
        logTest('Shipping Rate Connection', true, 'Successfully connected to WebSocket server');
        
        // Send a rate request message
        const rateRequest = {
          type: 'rate_request',
          payload: {
            from_zip: '90210',
            to_zip: '10001',
            weight_lbs: 5.0,
            dimensions: {
              length: 12.0,
              width: 8.0,
              height: 6.0
            }
          },
          timestamp: Date.now(),
          requestId: `test-${Date.now()}`
        };
        
        ws.send(JSON.stringify(rateRequest));
      };
      
      ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          
          if (data.type === 'quote_ready') {
            logTest('Shipping Rate Request', true, 'Received quote_ready response');
            console.log('Shipping quotes:', data.payload);
            
            // Check if the response contains shipping options
            if (data.payload && data.payload.all_options && data.payload.all_options.length > 0) {
              logTest('Shipping Options', true, `Received ${data.payload.all_options.length} shipping options`);
            } else {
              logTest('Shipping Options', false, 'No shipping options in response');
            }
            
            // Close the connection after receiving the quote
            ws.close();
            resolve();
          } else if (data.type === 'error') {
            logTest('Shipping Rate Request', false, `Received error: ${data.payload.message}`);
            ws.close();
            resolve();
          } else {
            console.log('Received other message type:', data.type);
          }
        } catch (error) {
          logTest('Shipping Rate Request', false, `Error parsing message: ${error.message}`);
          ws.close();
          resolve();
        }
      };
      
      ws.onerror = (error) => {
        logTest('Shipping Rate Connection', false, `Error connecting to WebSocket server: ${error.message}`);
        resolve();
      };
      
      // Set a timeout in case we don't get a response
      setTimeout(() => {
        if (ws.readyState === WebSocket.OPEN) {
          logTest('Shipping Rate Request', false, 'Timeout waiting for response');
          ws.close();
          resolve();
        }
      }, 5000);
    });
  } catch (error) {
    logTest('Shipping Rate Request', false, `Unexpected error: ${error.message}`);
  }
}

// Test 3: Session Management
async function testSessionManagement() {
  console.log('%cTest 3: Session Management', 'color: blue; font-weight: bold');
  
  try {
    const token = await getTestToken();
    if (!token) {
      logTest('Session Management', false, 'Failed to get test token');
      return;
    }
    
    // First connection to create a session
    const ws1 = new WebSocket(`${WS_SERVER_URL}?token=${token}`);
    let sessionId = null;
    
    return new Promise((resolve) => {
      ws1.onopen = () => {
        logTest('First Connection', true, 'Successfully connected to WebSocket server');
        
        // Send a ping message
        const pingMessage = {
          type: 'ping',
          payload: {
            message: 'Hello from first connection'
          },
          timestamp: Date.now(),
          requestId: `test-${Date.now()}`
        };
        
        ws1.send(JSON.stringify(pingMessage));
      };
      
      ws1.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          console.log('First connection received:', data);
          
          // Extract session ID
          if (data.session_id) {
            sessionId = data.session_id;
            logTest('Session ID', true, `Received session ID: ${sessionId}`);
            
            // Close the first connection
            ws1.close();
            
            // Create a second connection with the same session ID
            const ws2 = new WebSocket(`${WS_SERVER_URL}?token=${token}&session_id=${sessionId}`);
            
            ws2.onopen = () => {
              logTest('Second Connection', true, 'Successfully connected with session ID');
              
              // Send a ping message
              const pingMessage = {
                type: 'ping',
                payload: {
                  message: 'Hello from second connection'
                },
                timestamp: Date.now(),
                requestId: `test-${Date.now()}`
              };
              
              ws2.send(JSON.stringify(pingMessage));
            };
            
            ws2.onmessage = (event) => {
              try {
                const data = JSON.parse(event.data);
                console.log('Second connection received:', data);
                
                // Verify the session ID
                if (data.session_id === sessionId) {
                  logTest('Session Verification', true, 'Session ID matches in second connection');
                } else {
                  logTest('Session Verification', false, 'Session ID does not match in second connection');
                }
                
                // Close the second connection
                ws2.close();
                resolve();
              } catch (error) {
                logTest('Second Connection', false, `Error parsing message: ${error.message}`);
                ws2.close();
                resolve();
              }
            };
            
            ws2.onerror = (error) => {
              logTest('Second Connection', false, `Error connecting with session ID: ${error.message}`);
              resolve();
            };
          } else {
            logTest('Session ID', false, 'No session ID in response');
            ws1.close();
            resolve();
          }
        } catch (error) {
          logTest('First Connection', false, `Error parsing message: ${error.message}`);
          ws1.close();
          resolve();
        }
      };
      
      ws1.onerror = (error) => {
        logTest('First Connection', false, `Error connecting to WebSocket server: ${error.message}`);
        resolve();
      };
    });
  } catch (error) {
    logTest('Session Management', false, `Unexpected error: ${error.message}`);
  }
}

// Run all tests
async function runAllTests() {
  console.log('%cStarting Frontend-Backend Integration Tests', 'color: blue; font-size: 16px; font-weight: bold');
  
  await testWebSocketConnection();
  await testShippingRateRequest();
  await testSessionManagement();
  
  console.log('%cTest Results:', 'color: blue; font-size: 16px; font-weight: bold');
  console.log(`Total tests: ${testResults.total}`);
  console.log(`%cPassed: ${testResults.passed}`, 'color: green; font-weight: bold');
  console.log(`%cFailed: ${testResults.failed}`, 'color: red; font-weight: bold');
  
  return testResults;
}

// Export the test functions
window.shipanionTests = {
  runAllTests,
  testWebSocketConnection,
  testShippingRateRequest,
  testSessionManagement
};

console.log('%cShipanion Frontend-Backend Integration Tests loaded', 'color: blue; font-size: 16px; font-weight: bold');
console.log('Run tests with: window.shipanionTests.runAllTests()');
