# Client Tool Result Guide

This guide explains how `client_tool_result` messages with `tool_name: get_shipping_quotes` are handled in the Shipanion UI and dispatched to the reducer for the `QuoteCard.tsx` to render.

## Overview

When the WebSocket server sends a `client_tool_result` message with `tool_name: get_shipping_quotes`, the UI processes this message and dispatches it to the shipping reducer. The reducer then updates the shipping quotes state, which is rendered by the `QuoteCard.tsx` component.

## Implementation Details

### 1. Message Types

The `useWebSocket.ts` hook defines the message types and client tool types:

```typescript
// Define WebSocket message types from our backend
export enum MessageType {
  QUOTE_READY = 'quote_ready',
  LABEL_CREATED = 'label_created',
  CONTEXTUAL_UPDATE = 'contextual_update',
  CLIENT_TOOL_RESULT = 'client_tool_result',
  ERROR = 'error'
}

// Define client tool types
export enum ClientToolType {
  GET_SHIPPING_QUOTES = 'get_shipping_quotes',
  CREATE_LABEL = 'create_label'
}
```

### 2. Message Processing

The `useWebSocket.ts` hook processes `client_tool_result` messages and formats them for the reducer:

```typescript
// Process client tool result based on tool_name
if (parsedData.type === MessageType.CLIENT_TOOL_RESULT) {
  console.log("Received client tool result:", parsedData)
  
  if (parsedData.client_tool_call && parsedData.client_tool_call.tool_name === ClientToolType.GET_SHIPPING_QUOTES) {
    console.log("Received shipping quotes result:", parsedData)
    
    // Create a properly formatted message for the reducer
    const formattedMessage = {
      type: MessageType.CLIENT_TOOL_RESULT,
      tool_name: ClientToolType.GET_SHIPPING_QUOTES,
      tool_call_id: parsedData.tool_call_id,
      result: parsedData.result,
      is_error: parsedData.is_error || false
    }
    
    // Set the formatted message
    setLastMessage({
      data: JSON.stringify(formattedMessage),
      type: MessageType.CLIENT_TOOL_RESULT
    })
    
    // Return early to avoid setting the message again below
    return
  }
}
```

### 3. Reducer Processing

The shipping reducer processes the formatted message in the `processClientToolResult` function:

```typescript
// Check for the tool_name property from our formatted message
if (data.tool_name === ClientToolType.GET_SHIPPING_QUOTES) {
  console.log("Processing shipping quotes result:", data.result)
  
  // Make sure we have a valid result array
  if (!Array.isArray(data.result)) {
    console.error("Invalid shipping quotes result format:", data.result)
    return state
  }
  
  // This is a shipping quotes result
  const quotes = {
    quotes: data.result.map((quote: any) => ({
      carrier: quote.carrier,
      service: quote.service,
      cost: quote.price,
      estimatedDelivery: quote.eta
    })),
    selectedIndex: 0
  }

  return {
    ...state,
    currentStep: 1, // Move to quotes step
    quotes
  }
}
```

### 4. QuoteCard Rendering

The `QuoteCard.tsx` component renders the shipping quotes from the state:

```tsx
export function QuotesCard({ data }: QuotesCardProps) {
  // Debug logging
  useEffect(() => {
    console.log("QuotesCard data:", data)
  }, [data])

  if (!data) {
    // Render loading state
    return (...)
  }

  // Ensure we have quotes array and selectedIndex
  const quotes = data.quotes || []
  const selectedIndex = data.selectedIndex || 0

  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.4 }}>
      <Card className="w-full dark:border-gray-800">
        <CardHeader className="pb-2">
          <CardTitle className="text-lg">Available Shipping Options</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4">
          {quotes.length > 0 ? (
            quotes.map((quote, index) => (
              <QuoteItem key={index} quote={quote} isSelected={index === selectedIndex} delay={index * 0.15} />
            ))
          ) : (
            <div className="text-gray-500 dark:text-gray-400 text-center py-4">No shipping quotes available</div>
          )}
        </CardContent>
      </Card>
    </motion.div>
  )
}
```

## Message Flow

The message flow for `client_tool_result` messages with `tool_name: get_shipping_quotes` is:

1. WebSocket server sends a `client_tool_result` message
2. `useWebSocket.ts` hook receives the message and formats it
3. The formatted message is set as `lastMessage`
4. The shipping context's `useEffect` hook processes the `lastMessage`
5. The shipping reducer's `processClientToolResult` function updates the shipping quotes state
6. The `QuoteCard.tsx` component re-renders with the updated quotes

## Testing

A test component has been created to verify the `client_tool_result` handling works correctly:

```bash
# Path to test component
ShipanionUI/tests/sprint3/test-client-tool-result.tsx
```

To test the `client_tool_result` handling:

1. Navigate to the test page in your browser
2. Click the "Simulate Shipping Quotes Result" button to simulate receiving a `client_tool_result` message
3. Observe how the `QuoteCard.tsx` component renders the shipping quotes
4. Click the "Simulate Error Result" button to simulate receiving a `client_tool_result` message with an error
5. Click the "Reset Quotes" button to reset the quotes state

## Troubleshooting

If the `client_tool_result` handling is not working correctly:

1. Check the browser console for any errors
2. Verify that the `client_tool_result` message has the correct format
3. Ensure that the `tool_name` property is set to `get_shipping_quotes`
4. Check that the `result` property contains an array of shipping quotes
5. Verify that the shipping reducer is correctly processing the message
6. Check that the `QuoteCard.tsx` component is receiving the updated quotes state
