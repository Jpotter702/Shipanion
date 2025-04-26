# StepperAccordion Guide

This guide explains how the `StepperAccordion` component works in the Shipanion UI, particularly how it highlights the active step and shows check icons for completed steps.

## Overview

The `StepperAccordion` component is a key UI element in the shipping workflow that displays the different steps in the shipping process. It has been enhanced to:

1. Visually highlight the active step based on data from `useStepReducer()`
2. Show check icons for completed steps
3. Provide visual feedback for the current state of the shipping process

## Implementation Details

### 1. Step State Integration

The `StepperAccordion` component now accepts a `stepState` prop from the `useStepReducer()` hook:

```typescript
interface StepperAccordionProps {
  steps: Step[]
  currentStep: number
  stepState: StepState
}
```

This allows the component to use both the traditional `currentStep` value and the more detailed `stepState` information to determine which steps are active and completed.

### 2. Active Step Highlighting

The active step is highlighted based on both the `currentStep` value and the `stepState.currentStep` value:

```typescript
className={cn(
  "border-b border-l-0 border-r-0 border-t-0 pl-12 relative transition-all duration-300",
  // Highlight active step from both sources
  (step.isActive || index === stepState.currentStep) && "bg-gray-50 dark:bg-gray-800/50 rounded-md",
  // Add a stronger highlight for the step from stepState
  index === stepState.currentStep && "border-l-2 border-l-green-500 dark:border-l-green-400",
  // Keep the blue highlight for updated steps
  step.isUpdated && !step.isActive && index !== stepState.currentStep && "border-l-2 border-l-blue-500 dark:border-l-blue-400",
)}
```

This ensures that the active step is always highlighted, regardless of which source is used.

### 3. Completed Steps

Check icons are shown for completed steps based on both the `step.isComplete` value and the `stepState.completedSteps` array:

```typescript
{/* Show check icon if step is complete from either source */}
{(step.isComplete || stepState.completedSteps.includes(index as ShippingStep)) ? (
  <motion.div
    initial={{ scale: 0 }}
    animate={{ scale: 1 }}
    transition={{ type: "spring", stiffness: 300, damping: 20 }}
  >
    <CheckCircle2 className="h-5 w-5 text-green-500 dark:text-green-400" />
  </motion.div>
) : (
  <span className="text-base font-semibold">
    {index + 1}
  </span>
)}
```

This ensures that completed steps are properly marked with check icons.

### 4. Visual Enhancements

Several visual enhancements have been added to improve the user experience:

- A pulsing effect for the current step from `stepState`
- A ring highlight for the current step
- Special text styling for completed steps
- Animated transitions for all state changes

## Integration with Step Reducer

The `StepperAccordion` component is integrated with the step reducer through the following flow:

1. The `ShippingFeedPage` component initializes the `useStepReducer()` hook
2. The step state is passed to the `ShippingFeedContainer` component
3. The `ShippingFeedContainer` passes the step state to the `ShippingFeed` component
4. The `ShippingFeed` component passes the step state to the `StepperAccordion` component

This ensures that the `StepperAccordion` always has the most up-to-date information about the current step and completed steps.

## Testing

A test component has been created to verify the `StepperAccordion` works correctly with the step reducer:

```bash
# Path to test component
ShipanionUI/tests/sprint3/test-stepper-accordion.tsx
```

To test the `StepperAccordion`:

1. Navigate to the test page in your browser
2. Use the "Current Step Controls" to change the traditional `currentStep` value
3. Use the "Step Reducer Controls" to change the `stepState` values
4. Observe how the `StepperAccordion` updates to reflect the changes

## Troubleshooting

If the `StepperAccordion` is not working correctly:

1. Check that the `stepState` prop is being passed correctly
2. Verify that the `steps` array has the correct `isActive` and `isComplete` values
3. Ensure that the `currentStep` value is correct
4. Check the browser console for any errors
