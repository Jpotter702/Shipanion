# Agent Studio Prompt Guide for Shipping Quotes

This guide provides instructions for adjusting the tool prompt in Agent Studio to ensure that Bob (the ElevenLabs conversational AI) speaks shipping quotes clearly and effectively.

## Current Issues

If Bob is not clearly communicating the shipping quotes, you may observe one or more of the following issues:

1. **Missing Information**: Bob doesn't mention all carriers, prices, or delivery times
2. **Unclear Presentation**: Bob presents the quotes in a confusing or disorganized way
3. **No Follow-up Question**: Bob doesn't ask which option the user prefers
4. **Incorrect Emphasis**: Bob doesn't emphasize the most important information (price and carrier)

## Adjusting the Tool Prompt

### Step 1: Access Agent Studio

1. Log in to the ElevenLabs Agent Studio
2. Find your Shipanion agent (Bob)
3. Navigate to the Tools section

### Step 2: Find the `get_shipping_quotes` Tool

1. Locate the `get_shipping_quotes` tool in the list of tools
2. Click on it to edit its configuration

### Step 3: Update the Tool Description

The tool description should clearly explain how Bob should present the shipping quotes. Here's a template:

```
This tool retrieves shipping quotes based on origin, destination, and package details.

When presenting shipping quotes to the user:
1. ALWAYS start by mentioning the cheapest option first, including the carrier name, service type, exact price (with $ symbol), and delivery timeframe.
2. Then present 2-3 additional options in a clear, organized manner.
3. For each option, clearly state: [CARRIER NAME] [SERVICE TYPE] at $[PRICE], which would arrive in [DELIVERY TIME].
4. Always end by asking the user which option they prefer.

Example good response:
"I've found some shipping options for you. The most affordable option is USPS Priority Mail at $9.99, which would arrive in 2-3 business days. Other options include UPS Ground at $12.99 with delivery in 3-5 business days, and FedEx Express Saver at $14.99 with delivery in 1-2 business days. Which option would you prefer?"

Parameters:
- from_zip: The origin ZIP code
- to_zip: The destination ZIP code
- weight: The package weight in pounds
- dimensions: (Optional) The package dimensions in format LxWxH (inches)
- pickup_requested: (Optional) Whether pickup is requested (true/false)

The tool returns an array of shipping options, each containing:
- carrier: The carrier name (e.g., "UPS", "USPS", "FedEx")
- service: The service type (e.g., "Ground", "Priority Mail")
- price: The shipping cost (e.g., 12.99)
- eta: The estimated delivery time (e.g., "3-5 business days")
```

### Step 4: Add Examples

In the Examples section, add clear examples of how the tool should be used and how Bob should respond:

#### Example 1: Basic Quote Request

**User**: "I need to ship a 5-pound package from Beverly Hills to New York."

**Bob**: "I'll help you get shipping quotes for that. Could you confirm that you're shipping from ZIP code 90210 to 10001, and the package weighs 5 pounds?"

**User**: "Yes, that's correct."

**Bob**: *[Uses get_shipping_quotes tool with from_zip=90210, to_zip=10001, weight=5.0]*

**Tool Result**:
```json
[
  {
    "carrier": "USPS",
    "service": "Priority Mail",
    "price": 9.99,
    "eta": "2-3 business days"
  },
  {
    "carrier": "UPS",
    "service": "Ground",
    "price": 12.99,
    "eta": "3-5 business days"
  },
  {
    "carrier": "FedEx",
    "service": "Express Saver",
    "price": 14.99,
    "eta": "1-2 business days"
  }
]
```

**Bob**: "I've found some shipping options for you. The most affordable option is USPS Priority Mail at $9.99, which would arrive in 2-3 business days. Other options include UPS Ground at $12.99 with delivery in 3-5 business days, and FedEx Express Saver at $14.99 with delivery in 1-2 business days. Which option would you prefer?"

#### Example 2: Detailed Quote Request

**User**: "I need to ship a package that's 8 pounds and measures 12x10x8 inches from Los Angeles to Chicago."

**Bob**: "I'll help you get shipping quotes for that. Could you provide the ZIP codes for Los Angeles and Chicago?"

**User**: "From 90001 to 60601."

**Bob**: *[Uses get_shipping_quotes tool with from_zip=90001, to_zip=60601, weight=8.0, dimensions="12x10x8"]*

**Tool Result**:
```json
[
  {
    "carrier": "UPS",
    "service": "Ground",
    "price": 15.99,
    "eta": "3-4 business days"
  },
  {
    "carrier": "USPS",
    "service": "Priority Mail",
    "price": 18.99,
    "eta": "2-3 business days"
  },
  {
    "carrier": "FedEx",
    "service": "Express Saver",
    "price": 22.99,
    "eta": "2 business days"
  }
]
```

**Bob**: "I've found some shipping options for your 8-pound package. The most affordable option is UPS Ground at $15.99, which would arrive in 3-4 business days. Other options include USPS Priority Mail at $18.99 with delivery in 2-3 business days, and FedEx Express Saver at $22.99 with delivery in 2 business days. Which option would you prefer?"

### Step 5: Test and Iterate

After making changes to the tool prompt:

1. Save the changes
2. Run the test script to verify that Bob speaks the quote clearly:
   ```bash
   python tests/sprint3/test_bob_speaks_quote.py
   ```
3. Listen to Bob's response and check if it meets the requirements
4. If not, iterate on the tool prompt and test again

## Common Issues and Solutions

### Bob Doesn't Mention Prices Clearly

**Solution**: Update the tool description to emphasize that Bob should always include the $ symbol and the exact price.

### Bob Doesn't Mention Carrier Names

**Solution**: Add explicit instructions to always mention the carrier name for each option.

### Bob Presents Too Many Options

**Solution**: Specify that Bob should present only the cheapest option plus 2-3 alternatives.

### Bob Doesn't Ask for User Preference

**Solution**: Add a clear instruction to always end with "Which option would you prefer?" or a similar question.

## Advanced Customization

For more advanced customization, you can:

1. Adjust the agent's personality to be more clear and concise
2. Add custom instructions for how to handle shipping quotes
3. Create more detailed examples with various scenarios
4. Use the "Conversation Starters" feature to guide users toward asking about shipping quotes

Remember that changes to the agent may take some time to propagate, so allow a few minutes after making changes before testing again.
