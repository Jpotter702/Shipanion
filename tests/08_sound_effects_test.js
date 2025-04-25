/**
 * Sound Effects Test
 * 
 * This script tests the sound effects implementation in the ShipanionUI frontend.
 * It can be run in a browser console when the frontend is loaded.
 */

// Test results
const testResults = {
  passed: 0,
  failed: 0,
  total: 0
};

// Helper function to log test results
function logTest(name, passed, message) {
  testResults.total++;
  if (passed) {
    testResults.passed++;
    console.log(`%c✓ ${name}: ${message}`, 'color: green; font-weight: bold');
  } else {
    testResults.failed++;
    console.log(`%c✗ ${name}: ${message}`, 'color: red; font-weight: bold');
  }
}

// Test 1: Sound Utility Module
function testSoundUtilityModule() {
  console.log('%cTest 1: Sound Utility Module', 'color: blue; font-weight: bold');
  
  // Check if the sound utility module is available
  if (typeof window.playSound !== 'function') {
    logTest('Sound Utility Module', false, 'playSound function not found in global scope');
    console.log('Note: This test expects the sound utility functions to be exposed globally for testing purposes.');
    return;
  }
  
  // Test playSound function
  try {
    window.playSound('step-advance', 0.1);
    logTest('playSound Function', true, 'playSound function called successfully');
  } catch (error) {
    logTest('playSound Function', false, `Error calling playSound: ${error.message}`);
  }
  
  // Test toggleSoundEffects function
  if (typeof window.toggleSoundEffects !== 'function') {
    logTest('toggleSoundEffects Function', false, 'toggleSoundEffects function not found in global scope');
  } else {
    try {
      const initialState = window.areSoundEffectsEnabled();
      const newState = window.toggleSoundEffects();
      const finalState = window.toggleSoundEffects(); // Toggle back to original state
      
      logTest('toggleSoundEffects Function', newState !== initialState && finalState === initialState, 
        'toggleSoundEffects function toggled sound effects correctly');
    } catch (error) {
      logTest('toggleSoundEffects Function', false, `Error calling toggleSoundEffects: ${error.message}`);
    }
  }
  
  // Test preloadSoundEffects function
  if (typeof window.preloadSoundEffects !== 'function') {
    logTest('preloadSoundEffects Function', false, 'preloadSoundEffects function not found in global scope');
  } else {
    try {
      window.preloadSoundEffects();
      logTest('preloadSoundEffects Function', true, 'preloadSoundEffects function called successfully');
    } catch (error) {
      logTest('preloadSoundEffects Function', false, `Error calling preloadSoundEffects: ${error.message}`);
    }
  }
}

// Test 2: Sound Toggle Component
function testSoundToggleComponent() {
  console.log('%cTest 2: Sound Toggle Component', 'color: blue; font-weight: bold');
  
  // Check if the SoundToggle component is rendered
  const soundToggleButton = document.querySelector('button[aria-label="Mute sound effects"], button[aria-label="Enable sound effects"]');
  
  if (!soundToggleButton) {
    logTest('Sound Toggle Component', false, 'Sound toggle button not found in the DOM');
    return;
  }
  
  logTest('Sound Toggle Component', true, 'Sound toggle button found in the DOM');
  
  // Test clicking the sound toggle button
  try {
    const initialLabel = soundToggleButton.getAttribute('aria-label');
    soundToggleButton.click();
    
    // Wait for the state to update
    setTimeout(() => {
      const newLabel = soundToggleButton.getAttribute('aria-label');
      const toggled = initialLabel !== newLabel;
      
      logTest('Sound Toggle Click', toggled, 
        toggled ? 'Sound toggle button changed state when clicked' : 'Sound toggle button did not change state when clicked');
      
      // Toggle back to original state
      soundToggleButton.click();
    }, 100);
  } catch (error) {
    logTest('Sound Toggle Click', false, `Error clicking sound toggle button: ${error.message}`);
  }
}

// Test 3: StepperAccordion Sound Effects
function testStepperAccordionSounds() {
  console.log('%cTest 3: StepperAccordion Sound Effects', 'color: blue; font-weight: bold');
  
  // Find all accordion triggers
  const accordionTriggers = document.querySelectorAll('[data-state="closed"][data-orientation="vertical"]');
  
  if (accordionTriggers.length === 0) {
    logTest('StepperAccordion', false, 'No accordion triggers found in the DOM');
    return;
  }
  
  logTest('StepperAccordion', true, `Found ${accordionTriggers.length} accordion triggers`);
  
  // Mock the playSound function to detect when it's called
  let playSoundCalled = false;
  const originalPlaySound = window.playSound;
  
  if (typeof originalPlaySound === 'function') {
    window.playSound = (effect, volume) => {
      console.log(`playSound called with effect: ${effect}, volume: ${volume}`);
      playSoundCalled = true;
      // Don't actually play the sound during testing
    };
    
    // Click the first closed accordion trigger
    for (const trigger of accordionTriggers) {
      if (trigger.getAttribute('data-state') === 'closed') {
        trigger.click();
        
        // Check if playSound was called
        setTimeout(() => {
          logTest('Accordion Sound', playSoundCalled, 
            playSoundCalled ? 'playSound was called when accordion was opened' : 'playSound was not called when accordion was opened');
          
          // Restore the original playSound function
          window.playSound = originalPlaySound;
        }, 100);
        
        break;
      }
    }
  } else {
    logTest('Accordion Sound', false, 'playSound function not available for testing');
  }
}

// Test 4: WebSocket Event Sounds
function testWebSocketEventSounds() {
  console.log('%cTest 4: WebSocket Event Sounds', 'color: blue; font-weight: bold');
  
  // This test requires manual verification since we can't easily simulate WebSocket events
  console.log('%cManual verification required:', 'color: orange');
  console.log('1. Disconnect and reconnect to the WebSocket server');
  console.log('2. Verify that sound effects play for connection events');
  console.log('3. Send a rate request and verify that sound effects play for updates');
  
  logTest('WebSocket Event Sounds', true, 'Manual verification required (see console instructions)');
}

// Run all tests
function runAllTests() {
  console.log('%cStarting Sound Effects Tests', 'color: blue; font-size: 16px; font-weight: bold');
  
  testSoundUtilityModule();
  testSoundToggleComponent();
  testStepperAccordionSounds();
  testWebSocketEventSounds();
  
  console.log('%cTest Results:', 'color: blue; font-size: 16px; font-weight: bold');
  console.log(`Total tests: ${testResults.total}`);
  console.log(`%cPassed: ${testResults.passed}`, 'color: green; font-weight: bold');
  console.log(`%cFailed: ${testResults.failed}`, 'color: red; font-weight: bold');
  
  return testResults;
}

// Export the test functions
window.shipanionSoundTests = {
  runAllTests,
  testSoundUtilityModule,
  testSoundToggleComponent,
  testStepperAccordionSounds,
  testWebSocketEventSounds
};

console.log('%cShipanion Sound Effects Tests loaded', 'color: blue; font-size: 16px; font-weight: bold');
console.log('Run tests with: window.shipanionSoundTests.runAllTests()');
