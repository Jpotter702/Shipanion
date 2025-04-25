# Shipanion Quick Start Guide

This guide provides quick instructions to get the Shipanion application up and running.

## Prerequisites

- Python 3.8+
- Node.js 16+
- pnpm
- websocat (for testing)

## Quick Start

### 1. Start the WebSocket Server

```bash
# Navigate to the websocket directory
cd websocket

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
python -m pip install -r requirements.txt

# Start the server
python -m uvicorn backend.main:app --reload --port 8001
```

### 2. Start the Frontend

```bash
# In a new terminal, navigate to the ShipanionUI directory
cd ShipanionUI

# Install dependencies
pnpm install

# Start the development server
pnpm dev
```

### 3. Access the Applications

- **WebSocket Server**: http://localhost:8001
- **Frontend**: http://localhost:3001
- **WebSocket Endpoint**: ws://localhost:8001/ws
- **Test Token**: http://localhost:8001/test-token

### 4. Test the Integration

- Use the WebSocket Tester at the bottom of the frontend page
- Run the test scripts in the websocket directory:
  ```bash
  cd websocket
  chmod +x test_session_8001.sh
  ./test_session_8001.sh
  ```

## Troubleshooting

- If ports are in use, try different port numbers
- Check browser console for connection errors
- Ensure environment variables are set correctly

For more detailed instructions, see [UPDATED_SETUP_AND_LAUNCH_GUIDE.md](UPDATED_SETUP_AND_LAUNCH_GUIDE.md)
