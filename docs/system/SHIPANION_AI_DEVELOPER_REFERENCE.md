# SHIPANION AI DEVELOPER REFERENCE

This technical reference is designed for future developers and AI pair programmers working on the Shipanion project. It maps the codebase, key modules, APIs, data models, and event types for both backend and frontend. Use this as your foundational context for onboarding and rapid development.

---

## System Layer Division

- **Middleware API (MW):**
  - Handles REST endpoints
  - Integrates with carriers (FedEx/UPS)
  - Manages session start and label generation

- **WebSocket Server (WS):**
  - Maintains real-time updates between ShipanionUI and ElevenLabs conversational agent ("Bob")
  - Pushes live status (quotes, labels, etc.)

- **ShipanionUI Frontend (UI):**
  - Visual frontend for users
  - Mirrors session status (quotes, labels, errors) live
  - Provides interactive user experience

---

## 📂 Directory Structure

### Backend
- `/app/routes/` — REST API endpoint definitions (e.g., rates, labels)
- `/app/models/` — Pydantic schemas for request/response validation
- `/app/websockets/` — Real-time WebSocket handlers and server logic
- `/app/utils/` — Helper utilities for business logic, third-party integrations

### Frontend
- `/frontend/components/` — React UI components (cards, accordions, status, etc.)
- `/frontend/hooks/` — Custom React hooks (WebSocket, state, toast)
- `/frontend/pages/` — Next.js page routes (main entrypoints)

---

## 🧩 Key Modules

### Backend
- `routes/rates.py` — Handles `/get-rates` REST call, fetches shipping rates
- `routes/labels.py` — Handles `/create-label` REST call
- `websockets/server.py` — Manages WebSocket server, message dispatch
- `models/rate_quote.py` — Defines `RateQuote` schema
- `utils/fedex_client.py` — Integrates with FedEx API

### Frontend
- `components/shipping-feed/quotes-card.tsx` — Renders shipping quotes, loading states
- `components/shipping-feed/label-card.tsx` — Displays generated shipping label
- `hooks/use-web-socket.ts` — WebSocket connection, reconnection, session_id logic
- `hooks/use-toast.ts` — Toast/banner notification utility
- `dispatchMessageByType.ts` — Centralized WebSocket message handler

---

## 🧠 Important Classes

- `WebSocketManager` (backend): Handles connection lifecycle, session management
- `FedExClient` (backend): Fetches rates from FedEx API
- `RateQuote` (backend): Pydantic schema for shipping quotes
- `ShippingFeedContainer` (frontend): Main orchestrator for shipping UI

---

## 🛠️ Important Functions

- `get_shipping_quotes(origin_zip, destination_zip, weight)` — Returns shipping quotes (backend)
- `create_label(selected_quote_id, shipment_details)` — Generates shipping label (backend)
- `useWebSocket(options)` — Custom hook for live, reconnectable WebSocket (frontend)
- `dispatchMessageByType(message, dispatch)` — Handles incoming WebSocket events (frontend)
- `toast({title, description, ...})` — Shows user notifications (frontend)

---

## 🌐 API Endpoints

- **POST** `/get-rates`
  - Request: `{ origin_zip, destination_zip, weight }`
  - Response: `{ quotes: [RateQuote, ...] }`

- **POST** `/create-label`
  - Request: `{ selected_quote_id, shipment_details }`
  - Response: `{ label_pdf_url, qr_code_url }`

---

## 🔗 WebSocket Event Types

- `quote_ready` — Shipping quotes are ready
- `label_created` — Label has been generated
- `client_tool_result` — Result from a backend tool (e.g., get_shipping_quotes)
- `contextual_update` — Miscellaneous UI/UX or workflow updates

---

## 🧱 Data Models

- `RateQuote`
  - `carrier: str` — e.g., "FedEx"
  - `price: float` — e.g., 12.99
  - `eta: str` — e.g., "2 days"
- `Label`
  - `label_pdf_url: str`
  - `qr_code_url: str`

---

## 📝 Additional Notes
- **Session Persistence:** WebSocket sessions use a `session_id` for reconnection and continuity.
- **Loading States:** Managed in frontend reducer and reflected in UI components.
- **Notifications:** All contextual updates are surfaced as both console logs and user toasts.
- **Security:** JWT authentication required for WebSocket and API endpoints.

---

**For more details, see the developer summary or explore the codebase using this map as your guide.**
