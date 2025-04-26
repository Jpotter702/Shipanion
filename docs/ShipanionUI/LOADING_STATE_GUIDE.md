# Loading State Guide

This guide explains how the loading state is implemented in the Shipanion UI while waiting for quotes to arrive.

## Overview

When a `client_tool_call` is sent, a `loading: true` state is set in the reducer. The `QuoteCard` component then shows a spinner or placeholder until the `client_tool_result` arrives.

## Implementation Details

### 1. ShippingData Type

The `ShippingData` type has been updated to include `loadingQuotes` and `loadingLabel` flags:

```typescript
export interface ShippingData {
  currentStep: number
  details: ShippingDetails | null
  quotes: ShippingQuotes | null
  confirmation: ShippingConfirmation | null
  payment: PaymentData | null
  label: LabelData | null
  loadingQuotes: boolean
  loadingLabel: boolean
}
```

### 2. Action Types

New action types have been added to set the loading state:

```typescript
export enum ActionType {
  // ... existing action types
  SET_LOADING_QUOTES = 'SET_LOADING_QUOTES',
  SET_LOADING_LABEL = 'SET_LOADING_LABEL',
  // ... other action types
}
```

### 3. WebSocket Message Handling

The `useWebSocket.ts` hook has been updated to handle `client_tool_call` messages:

```typescript
// Process client tool call based on tool_name
if (parsedData.type === MessageType.CLIENT_TOOL_CALL) {
  console.log("Received client tool call:", parsedData)
  
  if (parsedData.tool_name === ClientToolType.GET_SHIPPING_QUOTES) {
    console.log("Received shipping quotes call:", parsedData)
    
    // Create a properly formatted message for the reducer
    const formattedMessage = {
      type: MessageType.CLIENT_TOOL_CALL,
      tool_name: ClientToolType.GET_SHIPPING_QUOTES,
      tool_call_id: parsedData.tool_call_id || `quotes-${Date.now()}`
    }
    
    // Set the formatted message
    setLastMessage({
      data: JSON.stringify(formattedMessage),
      type: MessageType.CLIENT_TOOL_CALL
    })
    
    // Return early to avoid setting the message again below
    return
  }
}
```

### 4. Reducer Updates

The shipping reducer has been updated to handle the `CLIENT_TOOL_CALL` message type:

```typescript
case MessageType.CLIENT_TOOL_CALL:
  console.log("Processing client tool call:", data)
  
  // Set loading state based on tool_name
  if (data.tool_name === ClientToolType.GET_SHIPPING_QUOTES) {
    return {
      ...state,
      loadingQuotes: true
    }
  } else if (data.tool_name === ClientToolType.CREATE_LABEL) {
    return {
      ...state,
      loadingLabel: true
    }
  }
  return state
```

And to set `loadingQuotes: false` when a result is received:

```typescript
return {
  ...state,
  currentStep: 1, // Move to quotes step
  quotes,
  loadingQuotes: false // Set loading to false when quotes are received
}
```

### 5. QuotesCard Component

The `QuotesCard` component has been updated to accept a `loading` prop:

```typescript
interface QuotesCardProps {
  data: ShippingQuotes | null
  loading?: boolean
}

export function QuotesCard({ data, loading = false }: QuotesCardProps) {
  // ...
}
```

And to show a loading state when `loading` is true:

```typescript
// Show loading state if loading is true or if there's no data
if (loading || !data) {
  return (
    <Card className="w-full dark:border-gray-800">
      <CardHeader className="pb-2">
        <CardTitle className="text-lg">
          <motion.span
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.3 }}
          >
            {loading ? "Fetching Shipping Options..." : "Shipping Options"}
          </motion.span>
        </CardTitle>
      </CardHeader>
      <CardContent className="p-6">
        <div className="space-y-4">
          {/* Show skeleton loading UI */}
          {[1, 2, 3].map((i) => (
            <motion.div 
              key={i}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3, delay: i * 0.1 }}
              className="border rounded-lg p-4 flex items-center justify-between animate-pulse"
            >
              {/* Skeleton UI elements */}
            </motion.div>
          ))}
          
          {/* Loading indicator */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="text-gray-400 dark:text-gray-500 flex items-center justify-center gap-2 mt-4"
          >
            <svg className="animate-spin -ml-1 mr-2 h-5 w-5 text-gray-400 dark:text-gray-500">
              {/* SVG spinner */}
            </svg>
            {loading ? "Getting the best rates for you..." : "Waiting for shipping quotes..."}
          </motion.div>
        </div>
      </CardContent>
    </Card>
  )
}
```

### 6. ShippingFeed Component

The `ShippingFeed` component has been updated to pass the `loadingQuotes` state to the `QuotesCard`:

```typescript
export function ShippingFeed({ data, stepState }: ShippingFeedProps) {
  const { currentStep, details, quotes, confirmation, payment, label, loadingQuotes, loadingLabel } = data
  // ...
}
```

```tsx
{
  title: "Shipping Quotes",
  content: (
    <motion.div animate={quotesControls}>
      <QuotesCard data={quotes} loading={loadingQuotes} />
    </motion.div>
  ),
  // ...
}
```

## Message Flow

The message flow for loading states is:

1. A `client_tool_call` message is sent
2. The `useWebSocket.ts` hook formats the message and sets it as `lastMessage`
3. The shipping context's `useEffect` hook processes the `lastMessage`
4. The shipping reducer sets `loadingQuotes: true` in the state
5. The `QuotesCard` component shows a loading state
6. When a `client_tool_result` message is received, the reducer sets `loadingQuotes: false`
7. The `QuotesCard` component shows the quotes

## Testing

A test component has been created to verify the loading state works correctly:

```bash
# Path to test component
ShipanionUI/tests/sprint3/test-loading-quotes.tsx
```

To test the loading state:

1. Navigate to the test page in your browser
2. Click the "Simulate Quote Request" button to simulate sending a `client_tool_call` and receiving a `client_tool_result` after a delay
3. Observe how the `QuotesCard` component shows a loading state while waiting for the result
4. Use the "Set Loading: True" and "Set Loading: False" buttons to manually control the loading state
5. Click the "Reset" button to reset the quotes and loading state

## Troubleshooting

If the loading state is not working correctly:

1. Check the browser console for any errors
2. Verify that the `client_tool_call` message has the correct format
3. Ensure that the `tool_name` property is set to `get_shipping_quotes`
4. Check that the shipping reducer is correctly setting `loadingQuotes: true`
5. Verify that the `QuotesCard` component is receiving the `loading` prop
6. Check that the `client_tool_result` message is setting `loadingQuotes: false`
