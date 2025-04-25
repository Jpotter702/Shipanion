#!/bin/bash
# Test scenario for contextual updates

# Set variables
WS_SERVER_URL=${WS_SERVER_URL:-"ws://localhost:8001/ws"}
API_SERVER_URL=${API_SERVER_URL:-"http://localhost:8001"}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Contextual Updates Test ===${NC}"
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

# Test 1: Create a session and listen for updates
echo -e "\n${YELLOW}Test 1: Create a session and listen for updates${NC}"
WS_URL="$WS_SERVER_URL?token=$TEST_TOKEN"
echo "URL: $WS_URL"

# Connect to WebSocket and keep it open
WEBSOCAT_OUTPUT=$(mktemp)
websocat --no-close "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &
LISTENER_PID=$!

# Wait for connection to establish
sleep 2

# Check if connection was successful
if ! ps -p $LISTENER_PID > /dev/null; then
    echo -e "${RED}✗ Failed to connect to WebSocket${NC}"
    cat "$WEBSOCAT_OUTPUT"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✓ Connected to WebSocket and listening for updates${NC}"

# Test 2: Send a rate request to trigger a contextual update
echo -e "\n${YELLOW}Test 2: Send a rate request to trigger a contextual update${NC}"

# Create a rate request message
RATE_REQUEST='{
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

echo -e "${YELLOW}Sending rate request to trigger contextual update:${NC}"
echo "$RATE_REQUEST"

# Use a separate connection to send the request
SENDER_OUTPUT=$(mktemp)
echo "$RATE_REQUEST" | websocat --no-close -n1 "$WS_URL" > "$SENDER_OUTPUT" 2>&1

# Wait for the response and update
sleep 3

# Check if the sender got a response
if [ ! -s "$SENDER_OUTPUT" ]; then
    echo -e "${RED}✗ No response received by sender${NC}"
    rm "$SENDER_OUTPUT"
    kill $LISTENER_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

echo -e "\n${GREEN}Sender received response:${NC}"
cat "$SENDER_OUTPUT"

# Check if the listener received an update
if [ ! -s "$WEBSOCAT_OUTPUT" ]; then
    echo -e "${RED}✗ No update received by listener${NC}"
    rm "$SENDER_OUTPUT"
    kill $LISTENER_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

echo -e "\n${GREEN}Listener received update:${NC}"
cat "$WEBSOCAT_OUTPUT"

# Check if it's a contextual_update message
if grep -q '"type":"contextual_update"' "$WEBSOCAT_OUTPUT"; then
    echo -e "\n${GREEN}✓ Test passed: Received contextual_update message${NC}"
else
    echo -e "\n${RED}✗ Test failed: Did not receive contextual_update message${NC}"
    rm "$SENDER_OUTPUT"
    kill $LISTENER_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Test 3: Create a second listener in the same session
echo -e "\n${YELLOW}Test 3: Create a second listener in the same session${NC}"

# Extract session ID from the first listener's output
SESSION_ID=$(grep -o '"session_id":"[^"]*' "$WEBSOCAT_OUTPUT" | head -1 | cut -d'"' -f4)

if [ -z "$SESSION_ID" ]; then
    echo -e "${RED}✗ Could not extract session ID from listener output${NC}"
    rm "$SENDER_OUTPUT"
    kill $LISTENER_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✓ Extracted session ID: $SESSION_ID${NC}"

# Connect a second listener to the same session
WS_URL_SESSION="$WS_SERVER_URL?token=$TEST_TOKEN&session_id=$SESSION_ID"
echo "URL: $WS_URL_SESSION"

SECOND_LISTENER_OUTPUT=$(mktemp)
websocat --no-close "$WS_URL_SESSION" > "$SECOND_LISTENER_OUTPUT" 2>&1 &
SECOND_LISTENER_PID=$!

# Wait for connection to establish
sleep 2

# Check if connection was successful
if ! ps -p $SECOND_LISTENER_PID > /dev/null; then
    echo -e "${RED}✗ Failed to connect second listener to WebSocket${NC}"
    cat "$SECOND_LISTENER_OUTPUT"
    rm "$SECOND_LISTENER_OUTPUT"
    rm "$SENDER_OUTPUT"
    kill $LISTENER_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✓ Connected second listener to the same session${NC}"

# Test 4: Send a label request to trigger another contextual update
echo -e "\n${YELLOW}Test 4: Send a label request to trigger another contextual update${NC}"

# Create a label request message
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

echo -e "${YELLOW}Sending label request to trigger contextual update:${NC}"
echo "$LABEL_REQUEST"

# Use a separate connection to send the request
LABEL_SENDER_OUTPUT=$(mktemp)
echo "$LABEL_REQUEST" | websocat --no-close -n1 "$WS_URL_SESSION" > "$LABEL_SENDER_OUTPUT" 2>&1

# Wait for the response and update
sleep 3

# Clear the first listener's output to capture only new messages
> "$WEBSOCAT_OUTPUT"

# Wait for updates to both listeners
sleep 3

# Check if both listeners received updates
if [ -s "$WEBSOCAT_OUTPUT" ]; then
    echo -e "\n${GREEN}First listener received update:${NC}"
    cat "$WEBSOCAT_OUTPUT"
    
    # Check if it's a contextual_update message
    if grep -q '"type":"contextual_update"' "$WEBSOCAT_OUTPUT"; then
        echo -e "\n${GREEN}✓ Test passed: First listener received contextual_update message${NC}"
    else
        echo -e "\n${RED}✗ Test failed: First listener did not receive contextual_update message${NC}"
    fi
else
    echo -e "\n${YELLOW}First listener did not receive an update${NC}"
fi

if [ -s "$SECOND_LISTENER_OUTPUT" ]; then
    echo -e "\n${GREEN}Second listener received update:${NC}"
    cat "$SECOND_LISTENER_OUTPUT"
    
    # Check if it's a contextual_update message
    if grep -q '"type":"contextual_update"' "$SECOND_LISTENER_OUTPUT"; then
        echo -e "\n${GREEN}✓ Test passed: Second listener received contextual_update message${NC}"
    else
        echo -e "\n${RED}✗ Test failed: Second listener did not receive contextual_update message${NC}"
    fi
else
    echo -e "\n${YELLOW}Second listener did not receive an update${NC}"
fi

# Clean up
kill $LISTENER_PID $SECOND_LISTENER_PID 2>/dev/null
rm "$WEBSOCAT_OUTPUT" "$SECOND_LISTENER_OUTPUT" "$SENDER_OUTPUT" "$LABEL_SENDER_OUTPUT" 2>/dev/null

echo -e "\n${BLUE}=== Contextual Updates Tests Completed ===${NC}"
