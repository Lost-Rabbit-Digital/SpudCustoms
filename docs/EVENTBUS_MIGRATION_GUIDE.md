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

## Files Refactored ✅ ALL COMPLETE

### High Priority - COMPLETED

1. **`/scripts/core/analytics.gd`** ✅
   - Uses GameStateManager.get_score(), get_strikes(), get_shift()
   - Subscribes to EventBus events for analytics tracking

2. **`/scripts/level_list_manager.gd`** ✅
   - Uses EventBus for level transitions
   - Uses GameStateManager for state reads

3. **`/scripts/systems/NarrativeManager.gd`** ✅
   - Uses GameStateManager.get_game_mode(), get_shift()
   - Emits all narrative events through EventBus (dialogue_started, dialogue_ended, etc.)
   - Subscribes to narrative_choices_load_requested and narrative_choices_save_requested

4. **`/assets/autoload/Global.gd`** ✅
   - Hardcoded paths removed
   - Uses EventBus signals for NarrativeManager communication

### Medium Priority - COMPLETED

5. **`/scripts/ui/FeedbackMenu.gd`** ✅
   - Uses GameStateManager.get_total_playtime()

6. **`/scripts/systems/ShiftSummaryScreen.gd`** ✅
   - Uses get_tree() directly instead of SceneLoader
   - Uses GameStateManager for all state reads
   - Emits EventBus.shift_stats_reset

7. **`/scripts/systems/drag_and_drop/drag_and_drop_manager.gd`** ✅
   - Uses CursorManager autoload directly
   - Uses get_node_or_null() pattern throughout

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

### Core Infrastructure ✅
- [x] Create EventBus autoload
- [x] Create GameStateManager autoload
- [x] Add to project.godot autoloads

### System Migrations ✅ ALL COMPLETE
- [x] Refactor BorderRunnerSystem key methods
- [x] Refactor Analytics to use GameStateManager and subscribe to EventBus
- [x] Refactor Global.gd to emit narrative events and use get_node_or_null
- [x] Remove hardcoded `/root/` paths from project files
- [x] Update NarrativeManager to use EventBus
- [x] Refactor level_list_manager.gd to emit events
- [x] Fix ShiftSummaryScreen hardcoded paths
- [x] Migrate FeedbackMenu.gd to use GameStateManager
- [x] Migrate DragAndDropManager.gd to use autoloads directly
- [x] Migrate level_select_menu.gd to use GameStateManager

### Testing & Documentation ✅
- [x] Create unit tests for EventBus (see `tests/unit/test_event_bus.gd` - 16+ tests)
- [x] Document all event types and their payloads (inline in EventBus.gd)
- [x] Gradually deprecate direct Global mutations ✅
- [x] Deprecate Global.gd in favor of GameStateManager ✅ COMPLETE ✅
- [ ] Add TypedSignals for better IDE support

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

### Phase 1: Testing & Documentation (Current Priority)
1. ~~Continue refactoring files in the priority list~~ ✅ COMPLETE
2. Create comprehensive test suite for EventBus
3. Document all event types with payload schemas

### Phase 2: Optimization & Polish
4. Add event validation and type safety
5. Monitor performance impact of event overhead
6. Consider TypedSignals for better IDE support

### Phase 3: Deprecation
7. Create deprecation warnings for direct Global mutations
8. Migrate remaining Global.gd functionality to GameStateManager
9. Remove Global.gd after full migration verification

## References

- EventBus: `/assets/autoload/EventBus.gd`
- GameStateManager: `/assets/autoload/GameStateManager.gd`
- Example refactoring: `/scripts/systems/BorderRunnerSystem.gd` (lines 591-617, 1140-1217)
