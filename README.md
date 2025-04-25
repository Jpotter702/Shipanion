# Shipanion

A comprehensive shipping platform with modular architecture for efficient multi-carrier shipping operations.

## Project Overview

Shipanion is a modern shipping platform designed to streamline the shipping process by providing:

- Multi-carrier integration (UPS, FedEx, etc.)
- Real-time shipping rates and label generation
- WebSocket-based real-time communication
- Voice integration via ElevenLabs
- Responsive UI with real-time updates

The project utilizes a modular architecture with three main components, each maintained as a separate git repository within the project structure.

## Project Structure

```
/Shipanion/
    /ShipanionUI/     (Frontend application)
    /ShipanionMW/     (Middleware services)
    /ShipanionWS/     (WebSocket server)
    /docs/            (Documentation by component)
        /system/      (System-wide documentation)
        /ShipanionUI/
        /ShipanionMW/
        /ShipanionWS/
    /tests/           (Tests by component)
        /ShipanionUI/
        /ShipanionMW/
        /ShipanionWS/
```

## Component Descriptions

### ShipanionUI

The frontend application built with:
- Next.js/React framework
- Tailwind CSS for styling
- Real-time WebSocket communication
- Sound effects and voice integration

ShipanionUI provides the user interface for the platform, including shipping rate calculations, label generation, and tracking. It communicates with the backend services via the WebSocket server.

### ShipanionMW (Middleware)

The backend middleware services include:
- API integrations with carrier services (UPS, FedEx, etc.)
- Rate calculation engines
- Label generation services
- Authentication and authorization
- Data persistence and management

ShipanionMW handles the business logic and carrier integrations, providing services to the WebSocket server.

### ShipanionWS (WebSocket Server)

Real-time communication layer:
- WebSocket server for real-time updates
- ElevenLabs voice integration
- Session management
- Event-based communication between UI and middleware
- Authentication via JWT

ShipanionWS serves as the communication bridge between the frontend and middleware, enabling real-time updates and voice interactions.

## Documentation Structure

The documentation is organized by component to make it easier to find relevant information:

- `/docs/system/` - System-wide documentation including setup guides and quick start information
- `/docs/ShipanionUI/` - Frontend-specific documentation
- `/docs/ShipanionMW/` - Middleware-specific documentation
- `/docs/ShipanionWS/` - WebSocket server documentation

### Key Documentation Files

- Quick Start Guide: `/docs/system/QUICK_START_GUIDE.md`
- Setup and Launch Guide: `/docs/system/SETUP_AND_LAUNCH_GUIDE.md`
- WebSocket Documentation: `/docs/ShipanionWS/`
- API References: `/docs/ShipanionMW/`

## Test Organization

Tests are organized by component to facilitate targeted testing:

- `/tests/ShipanionUI/` - Frontend-specific tests
- `/tests/ShipanionMW/` - Middleware-specific tests
- `/tests/ShipanionWS/` - WebSocket server tests
- Root level test files for integration tests across components

## Development

Each component is maintained as a separate git repository, allowing for independent versioning and deployment. When making changes:

1. Navigate to the specific component directory
2. Work with the git repository specific to that component
3. Place component-specific documentation in the appropriate `/docs/` subdirectory
4. Place component-specific tests in the appropriate `/tests/` subdirectory

## Getting Started

To get started with Shipanion, refer to the Quick Start Guide at `/docs/system/QUICK_START_GUIDE.md` for instructions on setting up and running the platform.

For more detailed setup instructions, see the Setup and Launch Guide at `/docs/system/SETUP_AND_LAUNCH_GUIDE.md`.
