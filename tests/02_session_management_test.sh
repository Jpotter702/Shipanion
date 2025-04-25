#!/bin/bash
# Test scenario for session management

# Set variables
WS_SERVER_URL=${WS_SERVER_URL:-"ws://localhost:8001/ws"}
API_SERVER_URL=${API_SERVER_URL:-"http://localhost:8001"}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Session Management Test ===${NC}"
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

# Test 1: Create a new session
echo -e "\n${YELLOW}Test 1: Creating a new session${NC}"
WS_URL="$WS_SERVER_URL?token=$TEST_TOKEN"
echo "URL: $WS_URL"

WEBSOCAT_OUTPUT=$(mktemp)
websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &
WEBSOCAT_PID=$!

# Wait for connection to establish
sleep 2

# Check if connection was successful
if ! ps -p $WEBSOCAT_PID > /dev/null; then
    echo -e "${RED}✗ Failed to connect to WebSocket${NC}"
    cat "$WEBSOCAT_OUTPUT"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✓ Connected to WebSocket${NC}"

# Send a test message to get the session ID
echo -e "\n${YELLOW}Sending test message...${NC}"
TEST_MESSAGE='{
    "type": "ping",
    "payload": {
        "message": "Hello, server!"
    },
    "timestamp": '$(date +%s000)',
    "requestId": "test-'$(date +%s)'"
}'

echo "$TEST_MESSAGE" | websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &

# Wait for response
sleep 2

# Extract session ID from the response
SESSION_ID=$(grep -o '"session_id":"[^"]*' "$WEBSOCAT_OUTPUT" | head -1 | cut -d'"' -f4)

if [ -n "$SESSION_ID" ]; then
    echo -e "${GREEN}✓ Session ID created: $SESSION_ID${NC}"
else
    echo -e "${RED}✗ No session ID found in response${NC}"
    cat "$WEBSOCAT_OUTPUT"
    kill $WEBSOCAT_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Clean up first connection
kill $WEBSOCAT_PID 2>/dev/null
rm "$WEBSOCAT_OUTPUT"

# Test 2: Connect to existing session
echo -e "\n${YELLOW}Test 2: Connecting to existing session${NC}"
WS_URL="$WS_SERVER_URL?token=$TEST_TOKEN&session_id=$SESSION_ID"
echo "URL: $WS_URL"

WEBSOCAT_OUTPUT=$(mktemp)
websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &
WEBSOCAT_PID=$!

# Wait for connection to establish
sleep 2

# Check if connection was successful
if ! ps -p $WEBSOCAT_PID > /dev/null; then
    echo -e "${RED}✗ Failed to connect to existing session${NC}"
    cat "$WEBSOCAT_OUTPUT"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✓ Connected to existing session${NC}"

# Send a test message to verify session ID
echo -e "\n${YELLOW}Sending test message to verify session...${NC}"
TEST_MESSAGE='{
    "type": "ping",
    "payload": {
        "message": "Hello from existing session!"
    },
    "timestamp": '$(date +%s000)',
    "requestId": "test-'$(date +%s)'"
}'

echo "$TEST_MESSAGE" | websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &

# Wait for response
sleep 2

# Extract session ID from the response
VERIFIED_SESSION_ID=$(grep -o '"session_id":"[^"]*' "$WEBSOCAT_OUTPUT" | head -1 | cut -d'"' -f4)

if [ "$VERIFIED_SESSION_ID" = "$SESSION_ID" ]; then
    echo -e "${GREEN}✓ Session ID verified: $VERIFIED_SESSION_ID${NC}"
else
    echo -e "${RED}✗ Session ID mismatch or not found${NC}"
    cat "$WEBSOCAT_OUTPUT"
    kill $WEBSOCAT_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Test 3: Connect with invalid session ID
echo -e "\n${YELLOW}Test 3: Connecting with invalid session ID${NC}"
WS_URL="$WS_SERVER_URL?token=$TEST_TOKEN&session_id=invalid_session_id_123"
echo "URL: $WS_URL"

WEBSOCAT_OUTPUT=$(mktemp)
websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &
WEBSOCAT_PID_INVALID=$!

# Wait for connection to establish
sleep 2

# Check if connection was successful (it should be, but with a new session)
if ! ps -p $WEBSOCAT_PID_INVALID > /dev/null; then
    echo -e "${RED}✗ Failed to connect with invalid session ID${NC}"
    cat "$WEBSOCAT_OUTPUT"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

echo -e "${GREEN}✓ Connected with invalid session ID (should create new session)${NC}"

# Send a test message to check if a new session was created
echo -e "\n${YELLOW}Sending test message to check new session...${NC}"
TEST_MESSAGE='{
    "type": "ping",
    "payload": {
        "message": "Hello from new session!"
    },
    "timestamp": '$(date +%s000)',
    "requestId": "test-'$(date +%s)'"
}'

echo "$TEST_MESSAGE" | websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &

# Wait for response
sleep 2

# Extract session ID from the response
NEW_SESSION_ID=$(grep -o '"session_id":"[^"]*' "$WEBSOCAT_OUTPUT" | head -1 | cut -d'"' -f4)

if [ -n "$NEW_SESSION_ID" ] && [ "$NEW_SESSION_ID" != "$SESSION_ID" ]; then
    echo -e "${GREEN}✓ New session created: $NEW_SESSION_ID${NC}"
else
    echo -e "${RED}✗ New session not created or session ID matches original${NC}"
    cat "$WEBSOCAT_OUTPUT"
    kill $WEBSOCAT_PID_INVALID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
fi

# Clean up
kill $WEBSOCAT_PID 2>/dev/null
kill $WEBSOCAT_PID_INVALID 2>/dev/null
rm "$WEBSOCAT_OUTPUT"

echo -e "\n${BLUE}=== All Session Management Tests Passed ===${NC}"
