#!/bin/bash
# Test scenario for WebSocket connection and authentication

# Set variables
WS_SERVER_URL=${WS_SERVER_URL:-"ws://localhost:8001/ws"}
API_SERVER_URL=${API_SERVER_URL:-"http://localhost:8001"}

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== WebSocket Authentication Test ===${NC}"
echo "Server URL: $WS_SERVER_URL"

# Test 1: Get a valid token
echo -e "\n${YELLOW}Test 1: Getting a valid token${NC}"
TEST_TOKEN=$(curl -s "$API_SERVER_URL/test-token" | grep -o '"test_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TEST_TOKEN" ]; then
    echo -e "${RED}✗ Failed to get test token${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Successfully got test token: ${TEST_TOKEN:0:15}...${NC}"
fi

# Check if websocat is installed
if ! command -v websocat &> /dev/null; then
    echo -e "${RED}websocat is not installed. Please install it to run this test.${NC}"
    echo "You can install it with: cargo install websocat"
    echo "Or download a binary from: https://github.com/vi/websocat/releases"
    exit 1
fi

# Test 2: Connect with valid token
echo -e "\n${YELLOW}Test 2: Connecting with valid token${NC}"
WS_URL="$WS_SERVER_URL?token=$TEST_TOKEN"
echo "URL: $WS_URL"

WEBSOCAT_OUTPUT=$(mktemp)
websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &
WEBSOCAT_PID=$!

# Wait for connection to establish
sleep 2

# Check if connection was successful
if ! ps -p $WEBSOCAT_PID > /dev/null; then
    echo -e "${RED}✗ Failed to connect with valid token${NC}"
    cat "$WEBSOCAT_OUTPUT"
    rm "$WEBSOCAT_OUTPUT"
    exit 1
else
    echo -e "${GREEN}✓ Successfully connected with valid token${NC}"
    kill $WEBSOCAT_PID 2>/dev/null
fi

# Test 3: Connect without token
echo -e "\n${YELLOW}Test 3: Connecting without token${NC}"
WS_URL="$WS_SERVER_URL"
echo "URL: $WS_URL"

WEBSOCAT_OUTPUT=$(mktemp)
websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &
WEBSOCAT_PID=$!

# Wait for connection attempt
sleep 2

# Check if connection was rejected (process should have exited)
if ps -p $WEBSOCAT_PID > /dev/null; then
    echo -e "${RED}✗ Connection without token was not rejected${NC}"
    kill $WEBSOCAT_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
else
    echo -e "${GREEN}✓ Connection without token was correctly rejected${NC}"
fi

# Test 4: Connect with invalid token
echo -e "\n${YELLOW}Test 4: Connecting with invalid token${NC}"
WS_URL="$WS_SERVER_URL?token=invalid_token_123"
echo "URL: $WS_URL"

WEBSOCAT_OUTPUT=$(mktemp)
websocat --no-close -n1 "$WS_URL" > "$WEBSOCAT_OUTPUT" 2>&1 &
WEBSOCAT_PID=$!

# Wait for connection attempt
sleep 2

# Check if connection was rejected (process should have exited)
if ps -p $WEBSOCAT_PID > /dev/null; then
    echo -e "${RED}✗ Connection with invalid token was not rejected${NC}"
    kill $WEBSOCAT_PID 2>/dev/null
    rm "$WEBSOCAT_OUTPUT"
    exit 1
else
    echo -e "${GREEN}✓ Connection with invalid token was correctly rejected${NC}"
fi

echo -e "\n${BLUE}=== All WebSocket Authentication Tests Passed ===${NC}"
