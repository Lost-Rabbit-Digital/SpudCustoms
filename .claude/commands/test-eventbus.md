---
description: Create unit tests for EventBus signal emissions and subscriptions
---

Create comprehensive unit tests for the EventBus system to verify:

**Test Coverage:**
1. **Signal Emissions**: Verify all signals emit with correct parameters
2. **Event Chaining**: Test that events trigger expected downstream events
3. **State Changes**: Verify GameStateManager responds correctly to events
4. **Backward Compatibility**: Ensure Global.gd stays in sync with GameStateManager
5. **Helper Methods**: Test convenience methods like `request_score_add()`, `show_alert()`
6. **Connection Validation**: Test `get_connection_report()` functionality
7. **Metadata Handling**: Verify optional metadata is preserved correctly

**Test File:** `godot_project/tests/unit/test_event_bus.gd`

**Key Test Scenarios:**
- Score add request → GameStateManager updates → Global syncs → UI update signal
- Strike add request → Max strikes check → Game over trigger
- Runner stopped → Score bonus → Achievement check
- Multiple rapid events → State consistency
- Event emission with missing metadata → Graceful handling
