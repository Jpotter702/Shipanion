# Quote Animation Guide

This guide explains how the quote animation works in the Shipanion UI when a `quote_ready` message is received.

## Overview

When the WebSocket server sends a `quote_ready` message, the UI displays shipping quotes with a smooth fade-in animation. Each quote card is animated individually, creating a staggered effect that draws the user's attention to the available shipping options.

## Implementation Details

### 1. Animation Detection

The `QuotesCard` component in `ShipanionUI/components/shipping-feed/quotes-card.tsx` detects when new quotes are received by:

- Using a `useRef` to track the previous quotes data
- Comparing the current quotes with the previous quotes
- Setting a `justReceived` state flag when new quotes are detected
- Resetting the flag after a delay to allow for re-animation on future updates

```typescript
// Detect when new quotes are received
useEffect(() => {
  // Check if we're receiving quotes for the first time or getting new quotes
  if (data && (!prevDataRef.current || data.quotes.length !== prevDataRef.current.quotes.length)) {
    console.log("New quotes received, triggering animation")
    setJustReceived(true)
    
    // Reset the flag after a short delay to allow for re-animation on future updates
    const timer = setTimeout(() => {
      setJustReceived(false)
    }, 2000)
    
    return () => clearTimeout(timer)
  }
  
  // Update the ref with current data
  prevDataRef.current = data
}, [data])
```

### 2. Container Animation

The container uses Framer Motion's `AnimatePresence` and `motion.div` to create a smooth fade-in effect:

```typescript
<AnimatePresence mode="wait">
  <motion.div 
    className="grid gap-4"
    variants={containerVariants}
    initial="hidden"
    animate="visible"
    // Reset the animation when new quotes are received
    key={justReceived ? "new-quotes" : "existing-quotes"}
  >
    {/* Quote items */}
  </motion.div>
</AnimatePresence>
```

The `key` prop changes when new quotes are received, causing React to unmount and remount the component, which triggers the animation to run again.

### 3. Individual Quote Animation

Each quote item is animated individually with a staggered delay, creating a cascading effect:

```typescript
<QuoteItem 
  key={`${quote.carrier}-${quote.service}-${index}`} 
  quote={quote} 
  isSelected={index === selectedIndex} 
  delay={index * 0.15}
  isNew={justReceived}
/>
```

The `QuoteItem` component uses different animation settings based on whether it's a new quote:

```typescript
// Enhanced animation for newly received quotes
const newQuoteAnimation = isNew ? {
  initial: { opacity: 0, scale: 0.9, y: 10 },
  animate: { 
    opacity: 1, 
    scale: 1, 
    y: 0,
    transition: {
      duration: 0.5,
      delay,
      type: "spring",
      stiffness: 120,
      damping: 8
    }
  }
} : {
  initial: { opacity: 0, y: 10 },
  animate: { 
    opacity: 1, 
    y: 0,
    transition: {
      duration: 0.4,
      delay,
      type: "spring",
      stiffness: 100
    }
  }
}
```

## Testing the Animation

A test component has been created to verify the animation works correctly:

```bash
# Path to test component
ShipanionUI/tests/sprint3/test-quote-animation.tsx
```

To test the animation:

1. Navigate to the test page in your browser
2. Click the "Simulate quote_ready" button to trigger the animation
3. Once quotes are displayed, click "Simulate new quotes" to see the animation again with different quotes

## WebSocket Integration

The animation is triggered automatically when the WebSocket receives a `quote_ready` message. The message flow is:

1. WebSocket server sends a `quote_ready` message
2. `use-web-socket.ts` hook receives the message and updates the `lastMessage` state
3. The shipping reducer processes the message and updates the quotes state
4. The `QuotesCard` component detects the new quotes and triggers the animation

## Troubleshooting

If the animation is not working correctly:

1. Check the browser console for any errors
2. Verify that the `quote_ready` message is being received by the WebSocket
3. Ensure that the quotes data is properly formatted
4. Check that Framer Motion is properly installed and imported
