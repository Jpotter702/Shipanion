#!/bin/bash
# Test scenario for label creation

# Set variables
WS_SERVER_URL=${WS_SERVER_URL:-"ws://localhost:8001/ws"}
API_SERVER_URL=${API_SERVER_URL:-"http://localhost:8001"}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Label Creation Test ===${NC}"
echo "Server URL: $WS_SERVER_URL"

# Get test token
echo -e "\n${YELLOW}Getting test token...${NC}"
TEST_TOKEN=$(curl -s "$API_SERVER_URL/test-token" | grep -o '"test_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TEST_TOKEN" ]; then
    echo -e "${RED}Failed to get test token${NC}"
    exit 1
fi

echo -e "${GREEN}Got test token: ${TEST_TOKEN:0:15}...${NC}"

# Check if websocat is installed
if ! command -v websocat &> /dev/null; then
    echo -e "${RED}websocat is not installed. Please install it to run this test.${NC}"
    echo "You can install it with: cargo install websocat"
    echo "Or download a binary from: https://github.com/vi/websocat/releases"
    exit 1
fi

# Test 1: Create label using client tool
echo -e "\n${YELLOW}Test 1: Create label using client tool${NC}"
WS_URL="$WS_SERVER_URL?token=$TEST_TOKEN"
echo "URL: $WS_URL"

# Create a label creation request
LABEL_REQUEST='{
    "type": "client_tool_call",
    "client_tool_call": {
        "tool_name": "create_label",
        "tool_call_id": "test-'$(date +%s)'",
        "parameters": {
            "carrier": "fedex",
            "service_type": "FEDEX_GROUND",
            "shipper_name": "John Doe",
            "shipper_street": "123 Main St",
            "shipper_city": "Beverly Hills",
            "shipper_state": "CA",
            "shipper_zip": "90210",
            "recipient_name": "Jane Smith",
            "recipient_street": "456 Park Ave",
            "recipient_city": "New York",
            "recipient_state": "NY",
            "recipient_zip": "10001",
            "weight": 5.0,
            "dimensions": {
                "length": 12.0,
                "width": 8.0,
                "height": 6.0
            }
        }
    },
    "timestamp": '$(date +%s000)',
    "requestId": "test-'$(date +%s)'"
}'

echo -e "${YELLOW}Sending label creation request:${NC}"
echo "$LABEL_REQUEST"

# Use websocat to send the request and capture the response
WEBSOCAT_OUTPUT=$(mktemp)
echo "$LABEL_REQUEST" | websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1

# Check if we got a response
if [ ! -s "$WEBSOCAT_OUTPUT" ]; then
    echo -e "${RED}✗ No response received${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Print the response
echo -e "\n${GREEN}Response received:${NC}"
cat "$WEBSOCAT_OUTPUT"

# Check if it's a client_tool_result response
if grep -q '"type":"client_tool_result"' "$WEBSOCAT_OUTPUT"; then
    echo -e "\n${GREEN}✓ Test passed: Received client_tool_result response${NC}"
else
    echo -e "\n${RED}✗ Test failed: Did not receive client_tool_result response${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Check if the result is not an error
if grep -q '"is_error":false' "$WEBSOCAT_OUTPUT"; then
    echo -e "${GREEN}✓ Test passed: Result is not an error${NC}"
else
    echo -e "${RED}✗ Test failed: Result is an error${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Check if the response contains tracking number
if grep -q '"tracking_number"' "$WEBSOCAT_OUTPUT"; then
    echo -e "${GREEN}✓ Test passed: Response contains tracking number${NC}"
else
    echo -e "${RED}✗ Test failed: Response does not contain tracking number${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Wait for contextual update
echo -e "\n${YELLOW}Waiting for contextual update...${NC}"
CONTEXTUAL_OUTPUT=$(mktemp)
websocat --no-close -n1 "$WS_URL" > "$CONTEXTUAL_OUTPUT" 2>&1 &
WEBSOCAT_PID=$!

# Wait for the update
sleep 3

# Kill the websocat process
kill $WEBSOCAT_PID 2>/dev/null

# Check if we got a contextual update
if [ -s "$CONTEXTUAL_OUTPUT" ]; then
    echo -e "\n${GREEN}Contextual update received:${NC}"
    cat "$CONTEXTUAL_OUTPUT"
    
    # Check if it's a contextual_update message
    if grep -q '"type":"contextual_update"' "$CONTEXTUAL_OUTPUT"; then
        echo -e "\n${GREEN}✓ Test passed: Received contextual_update message${NC}"
    else
        echo -e "\n${RED}✗ Test failed: Did not receive contextual_update message${NC}"
    fi
    
    # Check if it's a label_created update
    if grep -q '"text":"label_created"' "$CONTEXTUAL_OUTPUT"; then
        echo -e "${GREEN}✓ Test passed: Received label_created update${NC}"
    else
        echo -e "${RED}✗ Test failed: Did not receive label_created update${NC}"
    fi
else
    echo -e "\n${YELLOW}No contextual update received (this may be expected)${NC}"
fi

# Test 2: Invalid label request (missing required fields)
echo -e "\n${YELLOW}Test 2: Invalid label request (missing required fields)${NC}"

# Create an invalid label request
INVALID_LABEL_REQUEST='{
    "type": "client_tool_call",
    "client_tool_call": {
        "tool_name": "create_label",
        "tool_call_id": "test-'$(date +%s)'",
        "parameters": {
            "carrier": "fedex"
            // Missing most required fields
        }
    },
    "timestamp": '$(date +%s000)',
    "requestId": "test-'$(date +%s)'"
}'

echo -e "${YELLOW}Sending invalid label request:${NC}"
echo "$INVALID_LABEL_REQUEST"

# Use websocat to send the request and capture the response
WEBSOCAT_OUTPUT=$(mktemp)
echo "$INVALID_LABEL_REQUEST" | websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1

# Check if we got a response
if [ ! -s "$WEBSOCAT_OUTPUT" ]; then
    echo -e "${RED}✗ No response received${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Print the response
echo -e "\n${GREEN}Response received:${NC}"
cat "$WEBSOCAT_OUTPUT"

# Check if it's a client_tool_result response
if grep -q '"type":"client_tool_result"' "$WEBSOCAT_OUTPUT"; then
    echo -e "\n${GREEN}✓ Test passed: Received client_tool_result response${NC}"
else
    echo -e "\n${RED}✗ Test failed: Did not receive client_tool_result response${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Check if the result is an error
if grep -q '"is_error":true' "$WEBSOCAT_OUTPUT"; then
    echo -e "${GREEN}✓ Test passed: Result is an error as expected${NC}"
else
    echo -e "${RED}✗ Test failed: Result is not an error${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Clean up
rm "$WEBSOCAT_OUTPUT" "$CONTEXTUAL_OUTPUT" 2>/dev/null

echo -e "\n${BLUE}=== Label Creation Tests Completed ===${NC}"
