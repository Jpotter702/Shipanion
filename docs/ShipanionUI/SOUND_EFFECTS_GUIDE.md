# Sound Effects Implementation Guide

This document provides a comprehensive guide to the sound effects implementation in the ShipanionUI.

## Overview

Sound effects have been added to enhance the user experience by providing audio feedback for important events and interactions. The implementation includes:

1. A sound utility module for playing and managing sounds
2. A toggle component for enabling/disabling sounds
3. Integration with various UI components
4. Sound effects for different events and interactions

## Sound Utility Module

The core of the sound implementation is the `sound-effects.ts` utility module:

```typescript
// Sound effect options
export type SoundEffect = 'step-advance' | 'success' | 'error' | 'notification'

// Sound effect volume levels (0-1)
const DEFAULT_VOLUME = 0.2

// Cache for preloaded audio objects
const audioCache: Record<string, HTMLAudioElement> = {}

/**
 * Preload sound effects for better performance
 */
export function preloadSoundEffects() {
  if (typeof window === 'undefined') return
  
  // Preload common sound effects
  loadSound('step-advance', '/sounds/step-advance.mp3')
  loadSound('success', '/sounds/success.mp3')
  loadSound('error', '/sounds/error.mp3')
  loadSound('notification', '/sounds/notification.mp3')
}

/**
 * Load a sound into the cache
 */
function loadSound(name: string, path: string): void {
  if (typeof window === 'undefined') return
  
  if (!audioCache[name]) {
    const audio = new Audio(path)
    audio.preload = 'auto'
    audioCache[name] = audio
    
    // Start loading
    audio.load()
  }
}

/**
 * Play a sound effect
 */
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

/**
 * Toggle sound effects on/off
 */
export function toggleSoundEffects(): boolean {
  if (typeof window === 'undefined') return false
  
  const currentSetting = localStorage.getItem('soundEffectsEnabled') !== 'false'
  const newSetting = !currentSetting
  
  localStorage.setItem('soundEffectsEnabled', newSetting.toString())
  return newSetting
}

/**
 * Check if sound effects are enabled
 */
export function areSoundEffectsEnabled(): boolean {
  if (typeof window === 'undefined') return true
  return localStorage.getItem('soundEffectsEnabled') !== 'false'
}
```

## Sound Toggle Component

A toggle component allows users to enable or disable sound effects:

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

## Sound Integration Points

### 1. StepperAccordion

Sound effects are played when steps are opened or advanced:

```typescript
// Update open steps when currentStep changes
useEffect(() => {
  if (!openSteps.includes(`step-${currentStep}`)) {
    setOpenSteps((prev) => [...prev, `step-${currentStep}`])
    
    // Play sound when automatically advancing to a new step
    // But don't play on initial render (when currentStep is 0)
    if (currentStep > 0) {
      playSound('step-advance', 0.3)
    }
  }
}, [currentStep, openSteps])

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

### 2. ShippingFeed Component

Sound effects are played when data is updated:

```typescript
// Detect changes in data and trigger animations
useEffect(() => {
  if (details && !updatedSections.includes(0)) {
    detailsControls.start({
      scale: [1, 1.02, 1],
      boxShadow: [
        "0 0 0 rgba(59, 130, 246, 0)",
        "0 0 15px rgba(59, 130, 246, 0.5)",
        "0 0 0 rgba(59, 130, 246, 0)"
      ],
      transition: { duration: 0.5 }
    })
    setUpdatedSections(prev => [...prev, 0])
    
    // Play notification sound when details are updated
    playSound('notification', 0.2)
  }
}, [details, updatedSections, detailsControls])
```

### 3. WebSocket Events

Sound effects are played for WebSocket connection events:

```typescript
// Show connection status changes
useEffect(() => {
  // Skip initial render
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
    addToast({
      title: "Disconnected",
      description: "WebSocket connection lost. Attempting to reconnect...",
      type: "warning",
      duration: 5000,
    })
    
    // Play error sound when disconnected
    playSound('error', 0.2)
  }
  
  prevConnectedRef.current = isConnected
}, [isConnected, addToast])
```

### 4. Session Management

Sound effects are played for session events:

```typescript
// Show session ID changes
useEffect(() => {
  // Skip initial render
  if (prevSessionIdRef.current === sessionId) {
    prevSessionIdRef.current = sessionId
    return
  }
  
  if (sessionId) {
    addToast({
      title: "Session Active",
      description: `Connected to session: ${sessionId.substring(0, 8)}...`,
      type: "info",
      duration: 4000,
      action: {
        label: "Share",
        onClick: () => {
          // Create a shareable link with the session ID
          const url = new URL(window.location.href)
          url.searchParams.set('session_id', sessionId)
          navigator.clipboard.writeText(url.toString())
          
          addToast({
            title: "Link Copied",
            description: "Session link copied to clipboard",
            type: "success",
            duration: 2000,
          })
          
          // Play notification sound when link is copied
          playSound('notification', 0.2)
        }
      }
    })
    
    // Play notification sound when session is active
    playSound('notification', 0.2)
  }
  
  prevSessionIdRef.current = sessionId
}, [sessionId, addToast])
```

## Sound Effect Types

The implementation includes four types of sound effects:

1. **step-advance**: Played when advancing to a new step in the shipping process
2. **success**: Played when a shipping label is created or a connection is established
3. **error**: Played when an error occurs or a connection is lost
4. **notification**: Played when new data is received (quotes, details, etc.)

## User Preferences

Sound preferences are stored in localStorage:

```typescript
// Toggle sound effects on/off
export function toggleSoundEffects(): boolean {
  if (typeof window === 'undefined') return false
  
  const currentSetting = localStorage.getItem('soundEffectsEnabled') !== 'false'
  const newSetting = !currentSetting
  
  localStorage.setItem('soundEffectsEnabled', newSetting.toString())
  return newSetting
}
```

## Performance Considerations

To optimize performance, sound effects are:

1. **Preloaded**: Common sounds are preloaded when the app starts
2. **Cached**: Audio objects are cached to avoid creating new ones
3. **Volume Controlled**: Volume is kept at a reasonable level
4. **Error Handled**: Errors during playback are caught and logged

## Accessibility Considerations

The implementation considers accessibility:

1. **Toggle Control**: Users can disable sound effects
2. **Visual Alternatives**: All sound effects have visual counterparts
3. **Subtle Effects**: Sound effects are subtle and non-intrusive
4. **Volume Control**: Sound effects use appropriate volume levels

## Adding New Sound Effects

To add a new sound effect:

1. Add the sound file to the `public/sounds` directory
2. Update the `SoundEffect` type in `sound-effects.ts`
3. Add the file path to the `soundPaths` object
4. Preload the sound in the `preloadSoundEffects` function
5. Use the new sound effect with `playSound('new-effect')`

## Testing Sound Effects

To test sound effects:

1. Ensure sound is enabled on your device
2. Use the SoundToggle component to toggle sounds on/off
3. Trigger different events to hear the associated sounds
4. Test on different devices and browsers

## Best Practices

When using sound effects:

1. **Be Consistent**: Use the same sound for similar actions
2. **Be Subtle**: Keep sounds short and non-intrusive
3. **Provide Control**: Always allow users to disable sounds
4. **Consider Context**: Some environments may not be suitable for sounds
5. **Provide Alternatives**: Always have visual feedback alongside sounds
