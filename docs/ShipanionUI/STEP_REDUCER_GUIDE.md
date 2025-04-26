# Step Reducer Guide

This guide explains how the step reducer works in the Shipanion UI to track the current step in the shipping process.

## Overview

The step reducer is a custom hook that tracks the current step in the shipping process and updates it when matching WebSocket messages arrive. It provides a way to track the progression through the shipping workflow:

1. ZIP Collected
2. Weight Confirmed
3. Quote Ready
4. Label Created

## Implementation Details

### 1. Step Reducer Hook

The `useStepReducer` hook in `ShipanionUI/hooks/use-step-reducer.ts` manages the state of the shipping steps:

```typescript
export function useStepReducer(lastMessage: any = null) {
  const [state, dispatch] = useReducer(stepReducer, initialState)
  
  // Process WebSocket messages
  useEffect(() => {
    if (lastMessage) {
      dispatch({
        type: StepActionType.PROCESS_WEBSOCKET_MESSAGE,
        payload: lastMessage
      })
    }
  }, [lastMessage])
  
  // Helper functions to dispatch actions
  const setStep = (step: ShippingStep) => {
    dispatch({
      type: StepActionType.SET_STEP,
      payload: step
    })
  }
  
  const completeStep = (step: ShippingStep) => {
    dispatch({
      type: StepActionType.COMPLETE_STEP,
      payload: step
    })
  }
  
  return {
    state,
    setStep,
    completeStep
  }
}
```

### 2. Step State

The step reducer maintains a state object with the following properties:

```typescript
export interface StepState {
  currentStep: ShippingStep
  completedSteps: ShippingStep[]
  lastUpdated: Date | null
}
```

- `currentStep`: The current active step in the shipping process
- `completedSteps`: An array of steps that have been completed
- `lastUpdated`: A timestamp of when the state was last updated

### 3. WebSocket Message Processing

The step reducer processes WebSocket messages to update the current step:

```typescript
function processWebSocketMessage(state: StepState, message: any): StepState {
  try {
    // Parse the message if it's a string
    const data = typeof message.data === 'string' ? JSON.parse(message.data) : message.data
    
    // Process based on message type
    switch (data.type) {
      case MessageType.CONTEXTUAL_UPDATE:
        return processContextualUpdate(state, data)
        
      case MessageType.ZIP_COLLECTED:
        return {
          ...state,
          currentStep: ShippingStep.ZIP_COLLECTED,
          completedSteps: [...state.completedSteps, ShippingStep.ZIP_COLLECTED],
          lastUpdated: new Date()
        }
        
      // ... other message types
    }
  } catch (error) {
    console.error("Error processing WebSocket message in step reducer:", error)
    return state
  }
}
```

### 4. Integration with ShippingFeedPage

The `ShippingFeedPage` component in `ShipanionUI/shipping-feed.tsx` uses the step reducer to track the current step:

```typescript
// Initialize WebSocket connection
const { lastMessage, isConnected, sendMessage } = useWebSocket({
  url: process.env.NEXT_PUBLIC_WEBSOCKET_URL || 'ws://localhost:8000/ws',
  token,
  reconnectInterval: 3000,
  maxReconnectAttempts: 5
})

// Use our step reducer to track the current step
const { state: stepState, setStep, completeStep } = useStepReducer(lastMessage)
```

## Message Types

The step reducer responds to the following WebSocket message types:

| Message Type | Action |
|--------------|--------|
| `zip_collected` | Sets the current step to ZIP_COLLECTED |
| `weight_confirmed` | Sets the current step to WEIGHT_CONFIRMED |
| `quote_ready` | Sets the current step to QUOTE_READY |
| `label_created` | Sets the current step to LABEL_CREATED |
| `contextual_update` | Processes the update based on its type |

## UI Integration

The step reducer is integrated with the UI to show the current step and completed steps:

```tsx
{/* Step Indicator */}
<div className="mb-6 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg">
  <div className="flex flex-col gap-2">
    <div className="flex justify-between items-center">
      <h2 className="text-lg font-semibold">Current Step:</h2>
      <Badge variant="outline" className="text-sm font-medium">
        {stepNames[stepState.currentStep]}
      </Badge>
    </div>
    <div className="flex flex-wrap gap-2 mt-2">
      <h3 className="text-sm font-medium mr-2">Completed Steps:</h3>
      {stepState.completedSteps.length > 0 ? (
        stepState.completedSteps.map((step) => (
          <Badge key={step} variant="secondary" className="text-xs">
            {stepNames[step]}
          </Badge>
        ))
      ) : (
        <span className="text-sm text-gray-500">No steps completed yet</span>
      )}
    </div>
    {stepState.lastUpdated && (
      <div className="text-xs text-gray-500 mt-1">
        Last updated: {stepState.lastUpdated.toLocaleTimeString()}
      </div>
    )}
  </div>
</div>
```

## Testing

A test component has been created to verify the step reducer works correctly:

```bash
# Path to test component
ShipanionUI/tests/sprint3/test-step-reducer.tsx
```

To test the step reducer:

1. Navigate to the test page in your browser
2. Click the buttons to simulate different WebSocket messages
3. Observe how the current step and completed steps are updated

## Troubleshooting

If the step reducer is not working correctly:

1. Check the browser console for any errors
2. Verify that WebSocket messages are being received
3. Ensure that the message types match the expected format
4. Check that the step reducer is properly integrated with the WebSocket hook
