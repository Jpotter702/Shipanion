# SHIPANION DEVELOPER SUMMARY

Welcome to Shipanion! This is your quick-start map to the project’s backend and frontend.

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

## Directory Structure
- `/app/` — Backend: routes, models, websockets, utils
- `/frontend/` — Frontend: components, hooks, pages

---

## Key Modules
- **Backend:** `rates.py`, `labels.py`, `server.py`, `fedex_client.py`
- **Frontend:** `quotes-card.tsx`, `label-card.tsx`, `use-web-socket.ts`, `use-toast.ts`

---

## API Endpoints
- `/get-rates` — Get shipping quotes
- `/create-label` — Create a shipping label

---

## WebSocket Events
- `quote_ready`, `label_created`, `client_tool_result`, `contextual_update`

---

## Data Models
- `RateQuote`: `{ carrier, price, eta }`
- `Label`: `{ label_pdf_url, qr_code_url }`

---

## Quick Notes
- WebSocket sessions persist with `session_id`
- Loading and notifications are reducer-driven and user-facing
- JWT auth secures all live endpoints

---

**Use this as your orientation guide. For deeper details, see the full AI Developer Reference.**
