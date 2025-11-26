# EventBus Migration Guide for Spud Customs

This document outlines the anti-patterns found in the codebase and provides guidance on migrating to the new EventBus pattern.

## Executive Summary

The Spud Customs codebase exhibits several common anti-patterns that reduce maintainability and testability:

1. **God Object Pattern** - Global.gd (490 lines) manages too many responsibilities
2. **Direct Singleton Mutations** - 50+ places directly modify `Global.score`, `Global.strikes`
3. **Hardcoded Node Paths** - 6 instances of `get_node("/root/...")`
4. **Excessive Autoloads** - 19 global singletons (now 21 with EventBus and GameStateManager)
5. **No Centralized Event System** - Point-to-point coupling between systems

## New Architecture

### EventBus (`/assets/autoload/EventBus.gd`)

A centralized signal hub that enables decoupled communication between systems. Instead of:

```gdscript
# OLD: Direct mutation
Global.score += points
Global.strikes += 1
```

Systems now emit events:

```gdscript
# NEW: Event-driven
EventBus.request_score_add(points, "source_name")
EventBus.request_strike_add("reason")
```

### GameStateManager (`/assets/autoload/GameStateManager.gd`)

A centralized state manager that:
- Subscribes to EventBus events
- Manages game state (score, strikes, etc.)
- Keeps Global in sync for backward compatibility
- Emits state change confirmations

## Migration Patterns

### Pattern 1: Direct State Mutation → Event Emission

**BEFORE (Anti-pattern):**
```gdscript
func handle_runner_escape(_runner):
    Global.score = max(0, Global.score - penalty)
    Global.strikes += 1

    if Global.strikes >= Global.max_strikes:
        emit_signal("game_over_triggered")
```

**AFTER (Event-driven):**
```gdscript
func handle_runner_escape(_runner):
    EventBus.emit_runner_escaped("potato", {
        "penalty": escape_penalty,
        "runner_streak_reset": true
    })

    # GameStateManager handles the state changes and emits confirmation events
    if GameStateManager.get_strikes() >= GameStateManager.get_max_strikes():
        emit_signal("game_over_triggered")
```

### Pattern 2: Direct Score Addition → Score Request Event

**BEFORE:**
```gdscript
func add_points(points: int):
    Global.score += points
    score_label.text = str(Global.score)
```

**AFTER:**
```gdscript
func add_points(points: int):
    EventBus.request_score_add(points, "gameplay_action", {
        "bonus_type": "combo",
        "streak": current_streak
    })
    # UI updates are handled by subscribing to EventBus.ui_score_update_requested
```

### Pattern 3: Hardcoded Node Paths → Event Subscription

**BEFORE:**
```gdscript
func _ready():
    var narrative_manager = get_node("/root/NarrativeManager")
    narrative_manager.some_signal.connect(_on_some_signal)
```

**AFTER:**
```gdscript
func _ready():
    EventBus.narrative_choice_made.connect(_on_narrative_choice)
    EventBus.dialogue_ended.connect(_on_dialogue_ended)
```

### Pattern 4: UI Alert Calls → Alert Events

**BEFORE:**
```gdscript
Global.display_red_alert(alert_label, alert_timer, "Message")
```

**AFTER:**
```gdscript
EventBus.show_alert("Message", false)  # false = negative/red alert
# UIManager subscribes to alert_red_requested and handles display
```

## Files That Still Need Refactoring

### High Priority

1. **`/scripts/core/analytics.gd`** (15+ Global reads)
   - Replace direct `Global.score`, `Global.strikes` reads with GameStateManager accessors
   - Subscribe to EventBus events for analytics tracking

2. **`/scripts/level_list_manager.gd`**
   - Replace `Global.advance_shift()` with event emission
   - Use `EventBus.shift_advanced` signal

3. **`/scripts/systems/NarrativeManager.gd`**
   - Replace `Global.game_mode` checks with GameStateManager
   - Emit narrative events through EventBus

4. **`/assets/autoload/Global.gd`** (lines 265-267, 297-299, 457-459)
   - Replace `get_node("/root/NarrativeManager")` with EventBus signals
   - Emit `narrative_choices_save_requested` event instead

### Medium Priority

5. **`/scripts/ui/FeedbackMenu.gd`**
   - Use GameStateManager accessors instead of Global methods

6. **`/scripts/systems/ShiftSummaryScreen.gd`**
   - Replace `get_node("/root/SceneLoader")` with proper dependency injection
   - Use EventBus for state changes

7. **`/scripts/utils/DragAndDropManager.gd`**
   - Replace `get_node("/root/CursorManager")` with dependency injection

## Best Practices for New Code

### 1. Emit Events, Don't Mutate State Directly

```gdscript
# Good
EventBus.request_score_add(100, "achievement_bonus")

# Avoid
Global.score += 100
```

### 2. Subscribe to Events for Side Effects

```gdscript
func _ready():
    EventBus.score_changed.connect(_on_score_changed)
    EventBus.strike_changed.connect(_on_strike_changed)

func _on_score_changed(new_score: int, delta: int, source: String):
    update_ui(new_score)
    if source == "perfect_hit":
        play_celebration_effect()
```

### 3. Use GameStateManager for State Reads

```gdscript
# Good
var current_score = GameStateManager.get_score()
var current_strikes = GameStateManager.get_strikes()

# Avoid (during migration period, still works for backward compatibility)
var current_score = Global.score
```

### 4. Include Metadata in Events

```gdscript
EventBus.request_score_add(points, "runner_stopped", {
    "streak": runner_streak,
    "was_perfect": true,
    "distance": explosion_distance
})
```

### 5. Debug Event Flow

```gdscript
# Check which systems are listening to events
var report = EventBus.get_connection_report()
print(report)
```

## Migration Checklist

- [x] Create EventBus autoload
- [x] Create GameStateManager autoload
- [x] Add to project.godot autoloads
- [x] Refactor BorderRunnerSystem key methods
- [x] Refactor Analytics to use GameStateManager and subscribe to EventBus
- [x] Refactor Global.gd to emit narrative events and use get_node_or_null
- [x] Remove hardcoded `/root/` paths from project files ✅ **COMPLETED**
- [x] Update NarrativeManager to use EventBus
- [x] Refactor level_list_manager.gd to emit events
- [x] Fix ShiftSummaryScreen hardcoded paths
- [ ] Create unit tests for EventBus
- [ ] Document all event types and their payloads
- [ ] Gradually deprecate direct Global mutations
- [ ] Consider deprecating Global.gd in favor of GameStateManager

## Backward Compatibility

The current implementation maintains backward compatibility:

1. **Global still works** - GameStateManager syncs state back to Global
2. **Old code still runs** - Direct Global mutations are still functional
3. **Gradual migration** - Refactor one system at a time
4. **No breaking changes** - All existing functionality preserved

## Benefits Achieved

1. **Decoupled Systems** - BorderRunnerSystem no longer directly modifies Global
2. **Auditable State Changes** - All changes flow through events with metadata
3. **Easier Testing** - Mock EventBus signals instead of entire Global singleton
4. **Clear Data Flow** - Events make dependencies explicit
5. **Extensibility** - New systems can subscribe to existing events

## Next Steps

1. Continue refactoring files in the priority list
2. Add event validation and type safety
3. Create comprehensive test suite for EventBus
4. Monitor performance impact of event overhead
5. Document all event types with payload schemas
6. Consider TypedSignals for better IDE support

## References

- EventBus: `/assets/autoload/EventBus.gd`
- GameStateManager: `/assets/autoload/GameStateManager.gd`
- Example refactoring: `/scripts/systems/BorderRunnerSystem.gd` (lines 591-617, 1140-1217)
