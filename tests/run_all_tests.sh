#!/bin/bash
# Master test script for Shipanion

# Set variables
WS_SERVER_URL=${WS_SERVER_URL:-"ws://localhost:8001/ws"}
API_SERVER_URL=${API_SERVER_URL:-"http://localhost:8001"}
FRONTEND_URL=${FRONTEND_URL:-"http://localhost:3001"}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Shipanion Test Suite ===${NC}"
echo "WebSocket Server URL: $WS_SERVER_URL"
echo "API Server URL: $API_SERVER_URL"
echo "Frontend URL: $FRONTEND_URL"

# Make all test scripts executable
chmod +x *.sh

# Test results
PASSED=0
FAILED=0
TOTAL=0

# Function to run a test and track results
run_test() {
    TEST_NAME=$1
    TEST_SCRIPT=$2
    
    echo -e "\n${BLUE}Running test: ${TEST_NAME}${NC}"
    
    if [ -f "$TEST_SCRIPT" ]; then
        # Run the test script
        bash "$TEST_SCRIPT"
        
        # Check the exit code
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ ${TEST_NAME} passed${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}✗ ${TEST_NAME} failed${NC}"
            FAILED=$((FAILED + 1))
        fi
        
        TOTAL=$((TOTAL + 1))
    else
        echo -e "${RED}Test script not found: ${TEST_SCRIPT}${NC}"
    fi
}

# Check if servers are running
echo -e "\n${YELLOW}Checking if servers are running...${NC}"

# Check WebSocket server
curl -s "$API_SERVER_URL/test-token" > /dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ WebSocket server is running${NC}"
else
    echo -e "${RED}✗ WebSocket server is not running${NC}"
    echo -e "${YELLOW}Please start the WebSocket server:${NC}"
    echo "cd /home/jason/Shipanion/websocket && python -m uvicorn backend.main:app --reload --port 8001"
    exit 1
fi

# Check Frontend server
curl -s "$FRONTEND_URL" > /dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Frontend server is running${NC}"
else
    echo -e "${RED}✗ Frontend server is not running${NC}"
    echo -e "${YELLOW}Please start the Frontend server:${NC}"
    echo "cd /home/jason/Shipanion/ShipanionUI && pnpm dev"
    exit 1
fi

# Run all tests
echo -e "\n${BLUE}=== Running Backend Tests ===${NC}"

# 1. WebSocket Connection and Authentication Test
run_test "WebSocket Authentication" "01_websocket_auth_test.sh"

# 2. Session Management Test
run_test "Session Management" "02_session_management_test.sh"

# 3. Shipping Rate Requests Test
run_test "Shipping Rate Requests" "03_shipping_rate_test.sh"

# 4. Label Creation Test
run_test "Label Creation" "04_label_creation_test.sh"

# 5. Contextual Updates Test
run_test "Contextual Updates" "05_contextual_updates_test.sh"

# 6. ElevenLabs Integration Test
echo -e "\n${BLUE}Running ElevenLabs Integration Test${NC}"
cd ..
python -m pytest test_scenarios/06_elevenlabs_integration_test.py -v
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ ElevenLabs Integration Test passed${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ ElevenLabs Integration Test failed${NC}"
    FAILED=$((FAILED + 1))
fi
TOTAL=$((TOTAL + 1))
cd test_scenarios

echo -e "\n${BLUE}=== Frontend Tests ===${NC}"
echo -e "${YELLOW}Frontend tests need to be run manually in the browser console.${NC}"
echo -e "1. Open ${FRONTEND_URL} in your browser"
echo -e "2. Open the browser console (F12 or Ctrl+Shift+J)"
echo -e "3. Copy and paste the content of 07_frontend_backend_integration_test.js"
echo -e "4. Run the tests with: window.shipanionTests.runAllTests()"
echo -e "5. Copy and paste the content of 08_sound_effects_test.js"
echo -e "6. Run the tests with: window.shipanionSoundTests.runAllTests()"

# Print test results
echo -e "\n${BLUE}=== Test Results ===${NC}"
echo -e "Total tests: ${TOTAL}"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed.${NC}"
    exit 1
fi
