# ShipanionUI Frontend Changes

This document outlines all changes made to the ShipanionUI frontend during the recent sprint.

## Overview

We implemented several key enhancements to the frontend:

1. WebSocket integration with session support
2. State management with a reducer pattern
3. UI enhancements with animations and visual feedback
4. Sound effects for user interactions
5. Real-time updates and notifications

## WebSocket Integration

### 1. Enhanced WebSocket Hook

Updated the `useWebSocket` hook to support:

- Session ID tracking
- Token authentication
- Message type definitions
- Reconnection logic

```typescript
export function useWebSocket({ 
  url, 
  reconnectInterval = 3000, 
  maxReconnectAttempts = 5, 
  token, 
  sessionId 
}: WebSocketOptions) {
  // ...
  
  // Build the WebSocket URL with token and session ID
  let wsUrl = url
  const params = new URLSearchParams()
  
  if (token) {
    params.append('token', token)
  }
  
  if (currentSessionId) {
    params.append('session_id', currentSessionId)
  }
  
  // Add params to URL if we have any
  if (params.toString()) {
    wsUrl = `${url}?${params.toString()}`
  }
  
  // ...
}
```

### 2. Message Type Definitions

Added enums for message types:

```typescript
// Define WebSocket message types from our backend
export enum MessageType {
  QUOTE_READY = 'quote_ready',
  LABEL_CREATED = 'label_created',
  CONTEXTUAL_UPDATE = 'contextual_update',
  CLIENT_TOOL_RESULT = 'client_tool_result',
  ERROR = 'error'
}

// Define contextual update types
export enum ContextualUpdateType {
  QUOTE_READY = 'quote_ready',
  LABEL_CREATED = 'label_created',
  ZIP_COLLECTED = 'zip_collected',
  WEIGHT_CONFIRMED = 'weight_confirmed'
}
```

## State Management

### 1. Shipping Reducer

Created a reducer to manage shipping state:

```typescript
export function shippingReducer(state: ShippingData, action: ShippingAction): ShippingData {
  switch (action.type) {
    case ActionType.SET_CURRENT_STEP:
      return {
        ...state,
        currentStep: action.payload
      }
      
    // ... other action types
      
    case ActionType.PROCESS_WEBSOCKET_MESSAGE:
      const message = action.payload
      
      try {
        // Parse the message if it's a string
        const data = typeof message.data === 'string' ? JSON.parse(message.data) : message.data
        
        // Process based on message type
        switch (data.type) {
          case MessageType.CONTEXTUAL_UPDATE:
            return processContextualUpdate(state, data)
            
          case MessageType.CLIENT_TOOL_RESULT:
            return processClientToolResult(state, data)
            
          // ... other message types
        }
      } catch (error) {
        console.error("Error processing WebSocket message:", error)
        return state
      }
      
    default:
      return state
  }
}
```

### 2. Shipping Context

Created a context provider for shipping state:

```typescript
export function ShippingProvider({
  children,
  initialData,
  websocketUrl = process.env.NEXT_PUBLIC_WEBSOCKET_URL || 'ws://localhost:8000/ws',
  token,
  sessionId: initialSessionId
}: ShippingProviderProps) {
  // Initialize with merged initial data
  const mergedInitialState = { ...initialState, ...initialData }
  
  // Create the reducer
  const [shippingData, dispatch] = useReducer(shippingReducer, mergedInitialState)
  
  // Get session ID from localStorage if available
  const storedSessionId = typeof window !== 'undefined' ? localStorage.getItem('shipanion_session_id') : null
  const sessionIdToUse = initialSessionId || storedSessionId || undefined
  
  // Initialize WebSocket connection
  const { isConnected, lastMessage, sendMessage, error, useFallback, sessionId } = useWebSocket({
    url: websocketUrl,
    token,
    sessionId: sessionIdToUse,
    reconnectInterval: 3000,
    maxReconnectAttempts: 5
  })
  
  // Process WebSocket messages
  useEffect(() => {
    if (lastMessage) {
      dispatch({
        type: ActionType.PROCESS_WEBSOCKET_MESSAGE,
        payload: lastMessage
      })
    }
  }, [lastMessage])
  
  // ...
}
```

## UI Enhancements

### 1. Toast Notifications

Added a toast notification system:

```typescript
export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<ToastMessage[]>([])

  // Add a new toast
  const addToast = (toast: Omit<ToastMessage, "id">) => {
    const id = uuidv4()
    const newToast = { ...toast, id }
    
    setToasts((prev) => [...prev, newToast])
    
    // Auto-remove toast after duration
    if (toast.duration !== Infinity) {
      setTimeout(() => {
        removeToast(id)
      }, toast.duration || 5000)
    }
    
    return id
  }
  
  // ...
}
```

### 2. WebSocket Notifier

Created a component to show WebSocket events as notifications:

```typescript
export function WebSocketNotifier() {
  const { shippingData, isConnected, sessionId } = useShipping()
  const { addToast } = useToast()
  
  // Show connection status changes
  useEffect(() => {
    if (prevConnectedRef.current === isConnected) {
      prevConnectedRef.current = isConnected
      return
    }
    
    if (isConnected) {
      addToast({
        title: "Connected",
        description: "WebSocket connection established",
        type: "success",
        duration: 3000,
      })
      
      // Play success sound when connected
      playSound('success', 0.2)
    } else {
      // ...
    }
  }, [isConnected, addToast])
  
  // ...
}
```

### 3. Connection Status Indicator

Added a floating connection status indicator:

```typescript
export function ConnectionStatus() {
  const { isConnected } = useShipping()
  const [isReconnecting, setIsReconnecting] = useState(false)
  const [showStatus, setShowStatus] = useState(true)
  
  // ...
  
  return (
    <div className="fixed bottom-4 right-4 z-50">
      <AnimatePresence>
        {showStatus && (
          <motion.div
            initial={{ opacity: 0, y: 20, scale: 0.8 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 20, scale: 0.8 }}
            transition={{ duration: 0.2 }}
            className={`flex items-center gap-2 px-3 py-2 rounded-full shadow-lg ${
              isConnected 
                ? "bg-green-500 text-white" 
                : "bg-red-500 text-white"
            }`}
          >
            {/* ... */}
          </motion.div>
        )}
      </AnimatePresence>
      
      {/* Always visible indicator dot */}
      {!showStatus && (
        <motion.div
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          className={`h-3 w-3 rounded-full shadow-lg ${
            isConnected ? "bg-green-500" : "bg-red-500"
          }`}
        />
      )}
    </div>
  )
}
```

### 4. Progress Indicator

Added a progress indicator for shipping steps:

```typescript
export function ProgressIndicator() {
  const { shippingData } = useShipping()
  const { currentStep } = shippingData
  const [progress, setProgress] = useState(0)
  
  // Calculate progress percentage
  useEffect(() => {
    // Total number of steps
    const totalSteps = 5
    
    // Calculate progress (0-100%)
    const newProgress = Math.min(100, Math.round((currentStep / (totalSteps - 1)) * 100))
    
    // Animate the progress change
    const timer = setTimeout(() => {
      setProgress(newProgress)
    }, 300)
    
    return () => clearTimeout(timer)
  }, [currentStep])
  
  // ...
}
```

### 5. Confetti Celebration

Added a confetti animation for completed shipping:

```typescript
export function ConfettiCelebration({ trigger, duration = 5000 }: ConfettiCelebrationProps) {
  const [isActive, setIsActive] = useState(false)
  const { width, height } = useWindowSize()
  
  useEffect(() => {
    if (trigger && !isActive) {
      setIsActive(true)
      
      // Stop confetti after duration
      const timer = setTimeout(() => {
        setIsActive(false)
      }, duration)
      
      return () => clearTimeout(timer)
    }
  }, [trigger, duration, isActive])
  
  if (!isActive) return null
  
  return (
    <Confetti
      width={width}
      height={height}
      recycle={false}
      numberOfPieces={500}
      gravity={0.15}
    />
  )
}
```

## Sound Effects

### 1. Sound Utility Module

Created a utility module for sound effects:

```typescript
export function playSound(effect: SoundEffect, volume = DEFAULT_VOLUME): void {
  if (typeof window === 'undefined') return
  
  // Check if sound effects are enabled
  const soundEnabled = localStorage.getItem('soundEffectsEnabled') !== 'false'
  if (!soundEnabled) return
  
  // Map effect name to file path
  const soundPaths: Record<SoundEffect, string> = {
    'step-advance': '/sounds/step-advance.mp3',
    'success': '/sounds/success.mp3',
    'error': '/sounds/error.mp3',
    'notification': '/sounds/notification.mp3'
  }
  
  const path = soundPaths[effect]
  
  // Use cached audio if available, otherwise create new
  let audio = audioCache[effect]
  if (!audio) {
    audio = new Audio(path)
    audioCache[effect] = audio
  } else {
    // Reset audio to beginning if it's already playing
    audio.currentTime = 0
  }
  
  // Set volume and play
  audio.volume = volume
  
  // Play the sound (with error handling)
  audio.play().catch(err => {
    console.log(`Failed to play sound effect: ${err.message}`)
  })
}
```

### 2. Sound Toggle Component

Added a component to toggle sound effects:

```typescript
export function SoundToggle() {
  const [soundEnabled, setSoundEnabled] = useState(true)
  
  // Initialize state from localStorage on mount
  useEffect(() => {
    setSoundEnabled(areSoundEffectsEnabled())
  }, [])
  
  const handleToggle = () => {
    const newState = toggleSoundEffects()
    setSoundEnabled(newState)
  }
  
  return (
    <TooltipProvider>
      <Tooltip>
        <TooltipTrigger asChild>
          <Button
            variant="ghost"
            size="icon"
            onClick={handleToggle}
            className="h-8 w-8"
            aria-label={soundEnabled ? "Mute sound effects" : "Enable sound effects"}
          >
            {soundEnabled ? (
              <Volume2 className="h-4 w-4" />
            ) : (
              <VolumeX className="h-4 w-4" />
            )}
          </Button>
        </TooltipTrigger>
        <TooltipContent>
          <p>{soundEnabled ? "Mute sound effects" : "Enable sound effects"}</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  )
}
```

### 3. StepperAccordion Sound Effects

Added sound effects to the StepperAccordion:

```typescript
// Handle manual accordion changes
const handleValueChange = (value: string[]) => {
  // Check if a new step was opened
  if (value.length > openSteps.length) {
    // Find the newly opened step
    const newStep = value.find(step => !openSteps.includes(step))
    if (newStep) {
      // Play the step advance sound
      playSound('step-advance', 0.3)
    }
  }
  
  setOpenSteps(value)
}
```

## Session Management

### 1. Session Display Component

Added a component to display and manage sessions:

```typescript
export function SessionDisplay() {
  const { sessionId, isConnected } = useShipping()
  const [showDialog, setShowDialog] = useState(false)
  const [copied, setCopied] = useState(false)
  
  // Function to copy session ID to clipboard
  const copyToClipboard = () => {
    if (sessionId && typeof navigator !== 'undefined') {
      navigator.clipboard.writeText(sessionId)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }
  
  // Function to generate a QR code URL for the session
  const getQrCodeUrl = () => {
    if (!sessionId) return ''
    
    // In a real app, you would generate a proper QR code
    // For now, we'll use a placeholder service
    const websocketUrl = process.env.NEXT_PUBLIC_WEBSOCKET_URL || 'ws://localhost:8000/ws'
    const sessionUrl = `${websocketUrl}?session_id=${sessionId}`
    return `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(sessionUrl)}`
  }
  
  // ...
}
```

## Testing Tools

### 1. WebSocket Tester Component

Added a component for testing WebSocket functionality:

```typescript
export function WebSocketTester() {
  const { sendMessage, isConnected, sessionId } = useShipping()
  const [messageText, setMessageText] = useState("")
  
  // Sample messages for testing
  const sampleMessages = {
    zipCollected: {
      type: MessageType.CONTEXTUAL_UPDATE,
      text: ContextualUpdateType.ZIP_COLLECTED,
      data: {
        from: "90210",
        to: "10001"
      },
      timestamp: Date.now(),
      requestId: crypto.randomUUID()
    },
    
    // ... other sample messages
  }
  
  // Function to send a custom message
  const sendCustomMessage = () => {
    try {
      const message = JSON.parse(messageText)
      sendMessage(message)
    } catch (error) {
      console.error("Invalid JSON:", error)
      alert("Invalid JSON. Please check your message format.")
    }
  }
  
  // ...
}
```

## Summary

These changes significantly enhance the frontend's capabilities:

- **Real-time Updates**: WebSocket integration enables real-time updates
- **Session Management**: Session tracking allows for multi-device experiences
- **Enhanced UX**: Animations, sound effects, and visual feedback improve user experience
- **Robust State Management**: Reducer pattern provides predictable state updates
- **Developer Tools**: Testing components make development and debugging easier
