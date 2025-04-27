
<![endif]-->

# **Project Plan: Modular Multi-Carrier Rate Checker**

## **Objective**

Develop a modular shipping rate checker that integrates FedEx, UPS, and USPS APIs. The system will accept shipment details from multiple sources (e.g., chatbot, form), query all three carriers for rates, normalize the services, and return the results. It will also include logic to compare discounted vs. retail rates and provide the best rate options (cheapest or fastest). The system will be designed to plug into a larger project.

---

## **Features**

1. **Carrier API Integrations**:

- FedEx API (already implemented).

- UPS API.

- USPS API.

2. **Rate Normalization**:

- Map carrier-specific services (e.g., "FedEx Overnight", "UPS Next Day Air") to common service levels (e.g., "Overnight").

3. **Rate Comparison**:

- Compare discounted rates vs. retail rates for each carrier and service.

4. **Best Rate Logic**:

- Identify the cheapest and fastest shipping options.

5. **Input Sources**:

- Accept shipment details from:

- A chatbot (via an API endpoint).

- A form-based front end.

6. **Output**:

- Return normalized rates and best rate options to the chatbot or front end.

- Send shipment details and selected rates to a downstream system for further processing.

7. **Reporting**:

- Generate a report comparing discounted vs. retail rates in a normalized table.

---

## **Task List**

### **1. Backend Development**

#### **1.1 FedEx API Integration**

- [x] Implement FedEx OAuth token retrieval (`/get-token` endpoint).

- [x] Query FedEx rates (already implemented in rates.py).

#### **1.2 UPS API Integration**

- [ ] Obtain UPS API credentials (client ID, client secret, redirect URI).

- [ ] Create a new module `app/ups.py` to handle UPS API requests:

- [ ] Add a function to authenticate with the UPS API using OAuth 2.0.

- [ ] Add a function to query UPS rates (both retail and discounted).

- [ ] Add error handling for UPS API responses.

#### **1.3 USPS API Integration**

- [ ] Obtain USPS API credentials (user ID).

- [ ] Create a new module `app/usps.py` to handle USPS API requests:

- [ ] Add a function to query USPS rates (both retail and discounted).

- [ ] Add error handling for USPS API responses.

#### **1.4 Rate Normalization**

- [ ] Create a new module `app/normalizer.py` to map carrier-specific services to common service levels:

- [ ] Define mappings for FedEx services.

- [ ] Define mappings for UPS services.

- [ ] Define mappings for USPS services.

- [ ] Add logic to normalize rates and services returned by all three carriers.

#### **1.5 Rate Comparison**

- [ ] Add logic to compare discounted rates vs. retail rates for each carrier and service.

#### **1.6 Best Rate Logic**

- [ ] Add logic to determine the "best rate" based on:

- [ ] Cheapest option.

- [ ] Fastest option.

#### **1.7 Reporting**

- [ ] Create a new endpoint `/get-rate-report` to:

- [ ] Accept shipment details (origin, destination, weight, dimensions).

- [ ] Query all three carriers for rates.

- [ ] Normalize the services and rates.

- [ ] Return a table-like JSON response comparing discounted and retail rates for each service.

#### **1.8 Shipment Details Endpoint**

- [ ] Create a new endpoint `/process-shipment` to:

- [ ] Accept shipment details from a chatbot or form.

- [ ] Validate the input data.

- [ ] Query the `/get-rate-report` endpoint for rates.

- [ ] Return the rates to the chatbot or form.

- [ ] Send the shipment details and selected rate to a downstream system (e.g., for label generation).

---

### **2. Front-End Development**

#### **2.1 Input Form**

- [ ] Create a form to capture:

- [ ] Origin ZIP code.

- [ ] Destination ZIP code.

- [ ] Weight.

- [ ] Dimensions (length, width, height).

- [ ] Validate the input fields on the front end.

#### **2.2 Display Rates**

- [ ] Create a table to display:

- [ ] Carrier name (FedEx, UPS, USPS).

- [ ] Service level (e.g., "Overnight", "2-Day").

- [ ] Retail rate.

- [ ] Discounted rate.

- [ ] Savings (calculated as `retail_rate - discounted_rate`).

- [ ] Highlight the "best rate" options (cheapest and fastest).

#### **2.3 API Integration**

- [ ] Connect the front end to the `/process-shipment` endpoint.

- [ ] Display the rate comparison table returned by the backend.

---

### **3. Testing**

#### **3.1 Unit Tests**

- [ ] Write unit tests for:

- [ ] FedEx API integration.

- [ ] UPS API integration.

- [ ] USPS API integration.

- [ ] Normalization logic.

- [ ] Discounted vs. retail rate comparison logic.

- [ ] Best rate logic.

#### **3.2 Integration Tests**

- [ ] Test the `/get-rates`, `/get-rate-report`, and `/process-shipment` endpoints with real API responses.

- [ ] Test the front end with mock backend responses.

#### **3.3 End-to-End Testing**

- [ ] Simulate user input on the front end and chatbot and verify the rates and report are displayed correctly.

---

### **4. Deployment**

#### **4.1 Backend Deployment**

- [ ] Set up environment variables for FedEx, UPS, and USPS credentials in production.

- [ ] Deploy the backend to a cloud platform (e.g., AWS, Azure, or Heroku).

#### **4.2 Front-End Deployment**

- [ ] Deploy the front end to a hosting service (e.g., Netlify or Vercel).

#### **4.3 Security**

- [ ] Ensure HTTPS is enabled for secure communication.

- [ ] Use environment variables to store sensitive credentials.

---

### **5. Documentation**

- [ ] Document the API endpoints and their expected inputs/outputs.

- [ ] Provide instructions for setting up the .env file with API credentials.

- [ ] Add a README file explaining how to run the project locally.

---

## **Timeline**

| Task  | Estimated Time |

|-------------------------------|----------------|

| Backend Development  | 2-3 weeks  |

| Front-End Development  | 1-2 weeks  |

| Testing  | 1 week  |

| Deployment  | 1 week  |

| Documentation  | 2-3 days  |

---

## **Deliverables**

1. Fully functional backend with FedEx, UPS, and USPS API integrations.

2. Front-end interface to input shipment details and display rates.

3. Normalized rate comparison table with discounted vs. retail rates.

4. Best rate logic for cheapest and fastest options.

5. Deployment to production with proper documentation.

---

### **Modular Design Considerations**

1. **Separation of Concerns**:

- Each carrier integration (FedEx, UPS, USPS) will have its own module (`app/fedex.py`, `app/ups.py`, `app/usps.py`).

- Normalization logic will be handled in a separate module (`app/normalizer.py`).

2. **Reusable Endpoints**:

- The `/get-rate-report` endpoint will be reusable for both chatbot and form-based inputs.

- The `/process-shipment` endpoint will handle input validation and downstream processing.

3. **Extensibility**:

- Additional carriers can be added by creating new modules and updating the normalization logic.

- The system can be extended to include label generation or tracking APIs.