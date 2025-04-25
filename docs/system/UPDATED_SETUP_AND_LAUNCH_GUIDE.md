# Shipanion Setup and Launch Guide

This guide provides step-by-step instructions for setting up and launching all components of the Shipanion application.

## System Overview

The Shipanion application consists of the following components:

1. **WebSocket Server**: Backend server handling real-time communication
2. **ShipVox API**: API for shipping rates and label creation
3. **ShipanionUI**: Frontend React application
4. **Test Tools**: Scripts and tools for testing the integration

## Prerequisites

- Node.js 16+ and npm/pnpm
- Python 3.8+
- pip (Python package manager)
- Git (for version control)
- websocat (for WebSocket testing)

## Directory Structure

```
Shipanion/
├── websocket/            # WebSocket server
│   ├── backend/          # Backend Python code
│   ├── tests/            # Test files
│   └── docs/             # Documentation
├── ShipanionUI/          # Frontend React application
│   ├── app/              # Next.js app directory
│   ├── components/       # React components
│   ├── hooks/            # Custom React hooks
│   └── public/           # Static assets
└── scripts/              # Utility scripts
```

## Setup Instructions

### 1. WebSocket Server Setup

```bash
# Navigate to the websocket directory
cd websocket

# Create a virtual environment
python -m venv venv

# Activate the virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
python -m pip install -r requirements.txt
```

### 2. ShipVox API Setup

The ShipVox API is included in the WebSocket server package. No additional setup is required.

### 3. ShipanionUI Setup

```bash
# Navigate to the ShipanionUI directory
cd ShipanionUI

# Install dependencies using pnpm
pnpm install
```

### 4. Environment Configuration

#### WebSocket Server Environment

Create a `.env` file in the `websocket` directory:

```
DEBUG=True
SECRET_KEY=your_secret_key_here
SHIPVOX_API_KEY=your_shipvox_api_key_here
ALLOWED_ORIGINS=http://localhost:3001
```

#### ShipanionUI Environment

Create a `.env.local` file in the `ShipanionUI` directory:

```
NEXT_PUBLIC_WEBSOCKET_URL=ws://localhost:8001/ws
```

## Launch Instructions

### 1. Start the WebSocket Server

```bash
# Navigate to the websocket directory
cd websocket

# Activate the virtual environment if not already activated
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Start the server
python -m uvicorn backend.main:app --reload --port 8001
```

The WebSocket server will be available at:
- HTTP: http://localhost:8001
- WebSocket: ws://localhost:8001/ws

### 2. Start the ShipanionUI Frontend

```bash
# Navigate to the ShipanionUI directory
cd ShipanionUI

# Start the development server
pnpm dev
```

The frontend will be available at http://localhost:3001

### 3. Run Test Scripts

#### WebSocket Test Scripts

```bash
# Navigate to the websocket directory
cd websocket

# Make sure the scripts are executable
chmod +x test_create_label.sh
chmod +x test_session.sh

# Update the scripts to use port 8001 instead of 8000
sed -i 's/localhost:8000/localhost:8001/g' test_create_label.sh
sed -i 's/localhost:8000/localhost:8001/g' test_session.sh

# Run the create label test
./test_create_label.sh

# Run the session test
./test_session.sh
```

#### Automated Tests

```bash
# Navigate to the websocket directory
cd websocket

# Activate the virtual environment if not already activated
source venv/bin/activate

# Run the tests
python -m pytest tests/sprint2/test_create_label.py -v
```

## Accessing the Applications

### WebSocket Server Endpoints

- **Main API**: http://localhost:8001
- **WebSocket Endpoint**: ws://localhost:8001/ws
- **Test Token**: http://localhost:8001/test-token

### ShipanionUI

- **Main UI**: http://localhost:3001
- **WebSocket Tester**: Available in development mode at the bottom of the main page

## Troubleshooting

### WebSocket Connection Issues

If you're having trouble connecting to the WebSocket server:

1. Ensure the server is running
2. Check that the NEXT_PUBLIC_WEBSOCKET_URL is correct in the frontend
3. Verify that ALLOWED_ORIGINS includes your frontend URL
4. Check browser console for connection errors

### Missing Dependencies

If you encounter missing dependencies:

1. For the WebSocket server: `python -m pip install -r requirements.txt`
2. For the ShipanionUI: `pnpm install`

### Port Conflicts

If ports are already in use:

1. For the WebSocket server: Change the port in the uvicorn command (e.g., `--port 8002`)
2. For the ShipanionUI: Change the port with `pnpm dev -p 3002`

### Maximum Call Stack Size Exceeded Error

If you encounter a "Maximum call stack size exceeded" error in the frontend:

1. Check for recursive component rendering in the toast components
2. Ensure that the ToastProvider is not being used recursively

## Additional Resources

- [WebSocket Server Documentation](websocket/README.md)
- [ShipanionUI Documentation](ShipanionUI/README.md)
- [API Documentation](http://localhost:8001/docs) (when server is running)
- [WebSocket Changes Documentation](websocket/SPRINT2_CHANGES.md)
- [Frontend Changes Documentation](ShipanionUI/FRONTEND_CHANGES.md)
- [Sound Effects Guide](ShipanionUI/SOUND_EFFECTS_GUIDE.md)
