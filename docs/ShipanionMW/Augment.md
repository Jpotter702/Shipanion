Augment just finished syncing with your codebase! Here is a summary of what we saw:

ShipVox is a shipping middleware application that serves as a unified API layer between conversational interfaces (like ElevenLabs agents) and carrier shipping APIs (FedEx, UPS, with USPS planned).

Key features:

Accepts shipping details (origin/destination ZIP, weight, dimensions)
Normalizes and validates input data
Fetches rates from multiple carriers (FedEx, UPS) in parallel
Compares rates to find cheapest and fastest options
Handles label generation and pickup scheduling
Uses OAuth2 for carrier authentication
The project follows a modular architecture with separate components for:

Rate requests (`/rates`)
Label creation (`/labels`)
Pickup scheduling (`/pickup`)
Authentication (`/auth`)
Common utilities (`/utils`)
The system is built using FastAPI and follows modern Python practices, including async/await patterns, Pydantic models for validation, and comprehensive error handling. It's designed to be extensible for adding new carriers and maintaining response times under 3 seconds.

FedExRateEngine
ServiceNormalizer
RateEngine
FedExRateEngine.__init__
UPSRateEngine.__init__
RateService

Test for:
Request rates from both carriers simultaneously
Normalize service types for comparison
Handle API errors gracefully
Return the cheapest and fastest options as specified
need to use the sandbox endpoint for fedex pls


Start-up procedure
Using  run.py:
Or directly with uvicorn:
The server will start at http://localhost:8000. You can access:

API documentation at http://localhost:8000/docs
Alternative API docs at http://localhost:8000/redoc
The rates endpoint at http://localhost:8000/api/get-rates
To test the rates endpoint, you can use curl or the Swagger UI at /docs:

auth/fedex_auth.py
Update rates/fedex_rates.py
Update rates/rate_service.py
Update app/routes/rates.py
app/routes
app
auth
rates
models
utils