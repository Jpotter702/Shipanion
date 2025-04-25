#!/bin/bash
# Test scenario for shipping rate requests

# Set variables
WS_SERVER_URL=${WS_SERVER_URL:-"ws://localhost:8001/ws"}
API_SERVER_URL=${API_SERVER_URL:-"http://localhost:8001"}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Shipping Rate Request Test ===${NC}"
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

# Test 1: Basic rate request
echo -e "\n${YELLOW}Test 1: Basic rate request${NC}"
WS_URL="$WS_SERVER_URL?token=$TEST_TOKEN"
echo "URL: $WS_URL"

# Create a rate request message
RATE_REQUEST='{
    "type": "rate_request",
    "payload": {
        "from_zip": "90210",
        "to_zip": "10001",
        "weight_lbs": 5.0,
        "dimensions": {
            "length": 12.0,
            "width": 8.0,
            "height": 6.0
        }
    },
    "timestamp": '$(date +%s000)',
    "requestId": "test-'$(date +%s)'"
}'

echo -e "${YELLOW}Sending rate request:${NC}"
echo "$RATE_REQUEST"

# Use websocat to send the request and capture the response
WEBSOCAT_OUTPUT=$(mktemp)
echo "$RATE_REQUEST" | websocat --no-close -n1 "$WS_URL?token=$TEST_TOKEN" > "$WEBSOCAT_OUTPUT" 2>&1

# Check if we got a response
if [ ! -s "$WEBSOCAT_OUTPUT" ]; then
    echo -e "${RED}✗ No response received${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Print the response
echo -e "\n${GREEN}Response received:${NC}"
cat "$WEBSOCAT_OUTPUT"

# Check if it's a quote_ready response
if grep -q '"type":"quote_ready"' "$WEBSOCAT_OUTPUT"; then
    echo -e "\n${GREEN}✓ Test passed: Received quote_ready response${NC}"
else
    echo -e "\n${RED}✗ Test failed: Did not receive quote_ready response${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Check if the response contains shipping options
if grep -q '"all_options"' "$WEBSOCAT_OUTPUT"; then
    echo -e "${GREEN}✓ Test passed: Response contains shipping options${NC}"
else
    echo -e "${RED}✗ Test failed: Response does not contain shipping options${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Test 2: Invalid rate request (missing required fields)
echo -e "\n${YELLOW}Test 2: Invalid rate request (missing required fields)${NC}"

# Create an invalid rate request message
INVALID_RATE_REQUEST='{
    "type": "rate_request",
    "payload": {
        "from_zip": "90210"
        // Missing to_zip and weight_lbs
    },
    "timestamp": '$(date +%s000)',
    "requestId": "test-'$(date +%s)'"
}'

echo -e "${YELLOW}Sending invalid rate request:${NC}"
echo "$INVALID_RATE_REQUEST"

# Use websocat to send the request and capture the response
WEBSOCAT_OUTPUT=$(mktemp)
echo "$INVALID_RATE_REQUEST" | websocat --no-close -n1 "$WS_URL?token=$TEST_TOKEN" > "$WEBSOCAT_OUTPUT" 2>&1

# Check if we got a response
if [ ! -s "$WEBSOCAT_OUTPUT" ]; then
    echo -e "${RED}✗ No response received${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Print the response
echo -e "\n${GREEN}Response received:${NC}"
cat "$WEBSOCAT_OUTPUT"

# Check if it's an error response
if grep -q '"type":"error"' "$WEBSOCAT_OUTPUT"; then
    echo -e "\n${GREEN}✓ Test passed: Received error response for invalid request${NC}"
else
    echo -e "\n${RED}✗ Test failed: Did not receive error response for invalid request${NC}"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Test 3: Rate request with contextual update
echo -e "\n${YELLOW}Test 3: Rate request with contextual update${NC}"

# Create a rate request message with client_tool_call
TOOL_RATE_REQUEST='{
    "type": "client_tool_call",
    "client_tool_call": {
        "tool_name": "get_shipping_quotes",
        "tool_call_id": "test-'$(date +%s)'",
        "parameters": {
            "from_zip": "90210",
            "to_zip": "10001",
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

echo -e "${YELLOW}Sending tool rate request:${NC}"
echo "$TOOL_RATE_REQUEST"

# Use websocat to send the request and capture the response
WEBSOCAT_OUTPUT=$(mktemp)
echo "$TOOL_RATE_REQUEST" | websocat --no-close -n1 "$WS_URL?token=$TEST_TOKEN" > "$WEBSOCAT_OUTPUT" 2>&1

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

# Wait for contextual update
echo -e "\n${YELLOW}Waiting for contextual update...${NC}"
CONTEXTUAL_OUTPUT=$(mktemp)
websocat --no-close -n1 "$WS_URL?token=$TEST_TOKEN" > "$CONTEXTUAL_OUTPUT" 2>&1 &
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
else
    echo -e "\n${YELLOW}No contextual update received (this may be expected)${NC}"
fi

# Clean up
rm "$WEBSOCAT_OUTPUT" "$CONTEXTUAL_OUTPUT"

echo -e "\n${BLUE}=== Shipping Rate Request Tests Completed ===${NC}"
