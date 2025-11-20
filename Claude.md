# Spud Customs - Development Guidelines

## Project Overview

**Spud Customs** is a dystopian document thriller game built with **Godot 4.5** (Forward Plus renderer). Players take on the role of a customs officer in a world of anthropomorphic potatoes, processing documents and making decisions that affect narrative outcomes.

**Key Technical Stack:**
- **Engine**: Godot 4.5 with Forward Plus rendering
- **Language**: GDScript (GDScript 2.0)
- **Dialogue System**: Dialogic 2
- **Steam Integration**: GodotSteam
- **Testing**: GUT (Godot Unit Test) v9.3.0
- **CI/CD**: GitHub Actions with gdformat, gdlint, gdradon

**Reference Documentation:**
- Game Design Document: `project_management/spud_customs_design_document.md`
- Pre-release Testing: `project_management/testing/prerelease_test_procedure.md`
- Steam Patch Notes: `steam_patch_notes/`
- **EventBus Migration Guide**: `docs/EVENTBUS_MIGRATION_GUIDE.md`
- **Claude Code Commands**: `.claude/commands/` (slash commands for common tasks)

---

## Project Structure

```
SpudCustoms/
├── godot_project/
│   ├── assets/
│   │   ├── autoload/          # Global singletons (SaveManager, SteamManager, etc.)
│   │   ├── narrative/         # Dialogic characters and timelines
│   │   ├── styles/            # UI themes and audio bus layouts
│   │   └── ...
│   ├── scenes/
│   │   ├── game_scene/        # Main gameplay scenes
│   │   ├── menus/             # UI menus
│   │   └── ...
│   ├── scripts/
│   │   ├── core/              # Core utilities (analytics)
│   │   ├── systems/           # Game systems (QueueManager, PotatoFactory, etc.)
│   │   ├── ui/                # UI controllers
│   │   └── utils/             # Helper utilities (cursor, juicy buttons)
│   ├── tests/                 # GUT unit tests
│   └── translations/          # Localization files
├── project_management/        # Documentation and planning
└── addons/                    # Shared Godot addons
```

---

## Godot 4.5 Best Practices

### Scene Composition Over Inheritance

**DO:**
```gdscript
# Compose scenes from reusable components
var stamp_system: StampSystem = preload("res://scripts/systems/stamp/stamp_system.gd").new()
```

**DON'T:**
```gdscript
# Avoid deep inheritance hierarchies
class_name SpecialPotatoFromRegularPotatoFromBasePotato extends BasePotato
```

### Type Safety

**DO:**
```gdscript
# Use explicit type annotations
var potatoes: Array[PotatoPerson] = []
var score: int = 0
var difficulty_level: String = "Normal"

func calculate_bonus(stats: ShiftStats) -> int:
    return stats.get_missile_bonus() + stats.get_accuracy_bonus()
```

**DON'T:**
```gdscript
# Avoid untyped variables when type is known
var potatoes = []
var score = 0

func calculate_bonus(stats):
    return stats.get_missile_bonus() + stats.get_accuracy_bonus()
```

### Signal Patterns

**DO:**
```gdscript
# Define signals with typed parameters
signal score_updated(new_score: int)
signal high_score_achieved(difficulty: String, score: int)
signal save_completed(success: bool)

# Connect signals safely
func _ready() -> void:
    if not some_signal.is_connected(_on_some_signal):
        some_signal.connect(_on_some_signal)
```

**DON'T:**
```gdscript
# Avoid untyped signals
signal score_updated

# Avoid string-based connections (deprecated)
connect("score_updated", self, "_on_score_updated")
```

### Resource Management

**DO:**
```gdscript
# Preload resources at the top of scripts
var PotatoPerson: PackedScene = preload("res://scripts/systems/PotatoPerson.tscn")
var explosion_vfx: PackedScene = preload("res://scenes/explosion.tscn")

# Use resource paths consistently
const GAMESTATE_SAVE_PATH: String = "user://gamestate.save"
const HIGHSCORES_SAVE_PATH: String = "user://highscores.save"
```

**DON'T:**
```gdscript
# Avoid loading resources in frequently called functions
func spawn_potato() -> void:
    var potato = load("res://scripts/systems/PotatoPerson.tscn").instantiate()  # BAD
```

### Node References

**DO:**
```gdscript
# Use @onready for node references
@onready var queue_manager: QueueManager = %QueueManager
@onready var stamp_bar: Control = $UI/StampBar

# Use unique names (%) for important nodes
func _ready() -> void:
    path_node_path = %SpuddyQueue.get_path()
```

**DON'T:**
```gdscript
# Avoid get_node() in _process()
func _process(delta: float) -> void:
    var manager = get_node("/root/QueueManager")  # BAD: Called every frame
```

### Memory Management

**DO:**
```gdscript
# Always validate instances before use
if is_instance_valid(potato):
    potato.update_appearance()

# Clean up properly
func remove_potato() -> Dictionary:
    if potatoes.size() > 0:
        var potato: PotatoPerson = potatoes.pop_back()
        var info: Dictionary = potato.get_potato_info()
        potato.queue_free()
        return info
    return {}

# Use object pooling for frequently created/destroyed objects
# (See GDD: Performance Optimization Needs - Footprint System)
```

**DON'T:**
```gdscript
# Avoid memory leaks
var particle = GPUParticles2D.new()
add_child(particle)
# Never queue_free() - MEMORY LEAK
```

---

## Common Godot Anti-Patterns to AVOID

### 1. God Objects / Bloated Autoloads

**PROBLEM:** Putting too much functionality in Global autoload.

**CURRENT STATE:** The project is actively migrating from god object pattern to EventBus architecture.

**Autoload Structure (21 total):**
- `EventBus.gd` - **NEW** Centralized event system for decoupled communication
- `GameStateManager.gd` - **NEW** Single source of truth for game state
- `Global.gd` - Legacy state manager (being phased out, kept for backward compatibility)
- `SaveManager.gd` - Persistence layer
- `SteamManager.gd` - Steam API integration
- `UIManager.gd` - UI effects (screen shake, alerts)
- `NarrativeManager.gd` - Story tracking
- `LawValidator.gd` - Rule validation
- `AccessibilityManager.gd` - Accessibility features
- `TutorialManager.gd` - Tutorial progression
- Plus managers for: Localization, Scene Transitions, Audio, Cursor, Analytics

**MIGRATION IN PROGRESS:** See `docs/EVENTBUS_MIGRATION_GUIDE.md` for details.

**NEW CODE:** Always use EventBus pattern instead of direct Global mutations.

### 2. Hardcoded Magic Numbers

**BAD:**
```gdscript
if score > 10000:
    unlock_achievement()

var timeout = 5.0  # What is this?
```

**GOOD:**
```gdscript
const HIGH_SCORE_THRESHOLD: int = 10000
const NETWORK_TIMEOUT_SECONDS: float = 5.0

if score > HIGH_SCORE_THRESHOLD:
    unlock_achievement()
```

### 3. Using _process() for Everything

**BAD:**
```gdscript
func _process(delta: float) -> void:
    check_achievements()  # Expensive, runs 60+ times/sec
    update_leaderboards()  # Network call every frame!
```

**GOOD:**
```gdscript
# Use timers for periodic checks
var achievement_check_timer: Timer

func _ready() -> void:
    achievement_check_timer = Timer.new()
    achievement_check_timer.wait_time = 1.0
    achievement_check_timer.timeout.connect(_check_achievements)
    add_child(achievement_check_timer)
    achievement_check_timer.start()

# Use signals for event-driven updates
func _on_score_changed(new_score: int) -> void:
    _check_score_achievements(new_score)
```

### 4. Tight Coupling Between Systems

**BAD:**
```gdscript
# Direct access to internals
func approve_potato() -> void:
    Global.score += 100
    SteamManager.stats["approvals"] += 1
    %QueueManager.potatoes.pop_back()
```

**GOOD (Using EventBus Pattern):**
```gdscript
# Emit events through EventBus for decoupled communication
func approve_potato() -> void:
    var info: Dictionary = %QueueManager.remove_front_potato()
    EventBus.request_score_add(100, "potato_approved", {
        "potato_type": info.type,
        "accuracy": stamp_accuracy
    })
    EventBus.emit_potato_approved(info)
    # GameStateManager and other systems handle updates via subscriptions
```

**EventBus Pattern Benefits:**
- Decoupled systems (no direct dependencies)
- Auditable state changes (all events logged with metadata)
- Easier testing (mock EventBus signals)
- Clear data flow (events make dependencies explicit)

### 5. Ignoring Null Safety

**BAD:**
```gdscript
func get_potato_name() -> String:
    return current_potato.name  # Crashes if null!
```

**GOOD:**
```gdscript
func get_potato_name() -> String:
    if current_potato == null:
        return ""
    return current_potato.name

# Or use null coalescing
var name: String = current_potato.name if current_potato else "Unknown"
```

### 6. String-Based Node Paths in Logic

**BAD:**
```gdscript
func _on_button_pressed() -> void:
    if button.name == "ApproveButton":
        approve()
    elif button.name == "RejectButton":
        reject()
```

**GOOD:**
```gdscript
@onready var approve_button: Button = $ApproveButton
@onready var reject_button: Button = $RejectButton

func _ready() -> void:
    approve_button.pressed.connect(approve)
    reject_button.pressed.connect(reject)
```

### 7. Blocking Operations in Main Thread

**BAD:**
```gdscript
func save_game() -> void:
    var huge_data = serialize_world()  # Blocks for 500ms
    file.store_var(huge_data)  # Game freezes
```

**GOOD:**
```gdscript
func save_game() -> void:
    # Use call_deferred for non-critical operations
    call_deferred("_perform_save")

# Or use async patterns
func _perform_save() -> void:
    await get_tree().process_frame
    # Save logic here
```

### 8. Mutating Arrays While Iterating

**BAD:**
```gdscript
for potato in potatoes:
    if potato.is_invalid():
        potatoes.erase(potato)  # Modifies array during iteration!
```

**GOOD:**
```gdscript
# Iterate backwards when removing
var i: int = potatoes.size() - 1
while i >= 0:
    if not is_instance_valid(potatoes[i]):
        potatoes.remove_at(i)
    i -= 1

# Or collect indices first
var to_remove: Array[int] = []
for i in range(potatoes.size()):
    if potatoes[i].is_invalid():
        to_remove.append(i)
to_remove.reverse()
for idx in to_remove:
    potatoes.remove_at(idx)
```

---

## Project-Specific Conventions

### Naming Conventions

```gdscript
# Classes: PascalCase with descriptive names
class_name QueueManager
class_name PotatoPerson
class_name ShiftStats

# Variables: snake_case
var potato_walk_speed: int = 150
var current_story_state: int = 0

# Constants: SCREAMING_SNAKE_CASE
const GAMESTATE_SAVE_PATH: String = "user://gamestate.save"
const DEV_MODE: bool = false

# Signals: snake_case, past tense for events
signal score_updated(new_score: int)
signal potato_approved(info: Dictionary)
signal save_completed(success: bool)

# Private methods: prefix with underscore
func _perform_save() -> void:
func _restore_narrative_choices_deferred() -> void:
```

### File Organization

```
# Scripts follow their system domain
scripts/systems/QueueManager.gd
scripts/systems/PotatoFactory.gd
scripts/systems/stamp/stamp_system.gd
scripts/systems/drag_and_drop/draggable_document.gd

# Autoloads are global managers
assets/autoload/SaveManager.gd
assets/autoload/SteamManager.gd
assets/autoload/Global.gd

# Tests mirror source structure
tests/unit/test_shift_stats.gd
tests/unit/test_law_validator.gd
```

### Documentation Standards

```gdscript
## Manages the queue of potatoes waiting at the border checkpoint.
##
## Handles spawning, positioning, and removal of PotatoPerson instances
## along a defined Path2D curve.
class_name QueueManager
extends Node2D

## Maximum number of potatoes that can be in the queue simultaneously.
var max_potatoes: int

## Spawns a new potato at the queue entrance if space is available.
## Returns early if dialogue is active or queue is full.
func spawn_new_potato() -> void:
    if %NarrativeManager.is_dialogue_active():
        return
    # ...
```

---

## Testing Requirements

### Unit Testing with GUT

All core systems must have unit tests. See `tests/unit/` for examples.

**Test Structure:**
```gdscript
extends GutTest

var stats: ShiftStats

func before_each() -> void:
    stats = ShiftStats.new()

func test_get_missile_bonus_with_multiple_perfect_hits() -> void:
    stats.perfect_hits = 5
    var bonus: int = stats.get_missile_bonus()
    assert_eq(bonus, 750, "Should calculate 150 points per perfect hit")

func test_reset_clears_all_stats() -> void:
    stats.missiles_fired = 10
    stats.score = 1000
    stats.reset()
    assert_eq(stats.missiles_fired, 0)
    assert_eq(stats.score, 0)
```

**Priority Systems to Test:**
- Score calculation (ShiftStats, StatsManager)
- Rule validation (LawValidator)
- Character generation (PotatoFactory)
- Save/Load functionality (SaveManager)
- Narrative choice tracking (NarrativeManager)

### Running Tests

```bash
# Local: Run via Godot editor or CLI
cd godot_project
godot --headless --script res://tests/run_tests.gd

# CI: Tests run automatically on push via GitHub Actions
# See: .github/workflows/automated_tests.yml
```

### Code Quality Checks

```bash
# Format code (check only)
gdformat --check godot_project/scripts/

# Lint code
gdlint godot_project/scripts/

# Cyclomatic complexity analysis
gdradon cc godot_project/scripts/
```

---

## Performance Guidelines

### Z-Index Management

The project has documented z-index issues. Use the centralized system:

```gdscript
# Reference the constant z-indexes
ConstantZIndexes.DOCUMENT_LAYER
ConstantZIndexes.UI_LAYER
ConstantZIndexes.PARTICLE_LAYER

# Always set z-index explicitly for new visual elements
particle_effect.z_index = ConstantZIndexes.PARTICLE_LAYER
```

### Object Pooling

For frequently spawned objects (footprints, particles, gibs):

```gdscript
# Implement pooling to avoid create/destroy overhead
class_name ObjectPool
extends Node

var _pool: Array[Node] = []
var _scene: PackedScene

func get_instance() -> Node:
    if _pool.size() > 0:
        return _pool.pop_back()
    return _scene.instantiate()

func return_instance(instance: Node) -> void:
    instance.visible = false
    _pool.append(instance)
```

### Signal Optimization

```gdscript
# Prefer signals over polling
signal quota_reached()

# Emit once, let systems react
func update_quota(new_value: int) -> void:
    quota_met = new_value
    if quota_met >= quota_target:
        quota_reached.emit()
```

---

## Steam Integration Patterns

### Achievement Tracking

```gdscript
# Track stats centrally in Global
var total_shifts_completed: int = 0
var total_runners_stopped: int = 0
var perfect_hits: int = 0

# Trigger achievements via SteamManager
func check_border_defender_achievement() -> void:
    if Global.total_runners_stopped >= 50:
        SteamManager.unlock_achievement("border_defender")
```

### Leaderboard Submission

```gdscript
# Submit scores after shift completion
func submit_score(score: int, difficulty: String) -> void:
    if Steam.isSteamRunning():
        var leaderboard_name: String = "shift_%d_%s" % [shift, difficulty.to_lower()]
        SteamManager.submit_leaderboard_score(leaderboard_name, score)
```

### Cloud Saves

```gdscript
# Always check Steam availability
if not DEV_MODE and Steam.isSteamRunning():
    SteamManager.upload_cloud_saves()
else:
    # Fall back to local save
    _save_local()
```

---

## Dialogic Integration

### Timeline Management

```gdscript
# Check dialogue state before game actions
if %NarrativeManager.is_dialogue_active():
    return  # Don't spawn potatoes during dialogue

# Start dialogue properly
Dialogic.start("shift1_intro")

# Track choices via NarrativeManager
NarrativeManager.record_choice("initial_response", "eager")
```

### Variable Synchronization

```gdscript
# Sync Dialogic variables with Global state
func _restore_narrative_choices_deferred() -> void:
    for key in narrative_choices.keys():
        Dialogic.VAR.set(key, narrative_choices[key])
```

---

## Accessibility Considerations

Reference: `AccessibilityManager.gd`

### Required Features (from GDD)

- **Colorblind modes**: Protanopia, Deuteranopia, Tritanopia
- **Font scaling**: Small, Medium, Large, Extra Large
- **UI scaling**: 80%, 100%, 120%, 150%
- **High contrast mode**: Enhanced borders and highlights
- **Dyslexia-friendly fonts**: Optional alternative

### Implementation Pattern

```gdscript
# Use AccessibilityManager for all accessibility features
func apply_colorblind_filter(mode: String) -> void:
    AccessibilityManager.set_colorblind_mode(mode)

# Ensure stamps use shape + color differentiation
func create_stamp_indicator(approved: bool) -> Sprite2D:
    var indicator := Sprite2D.new()
    if approved:
        indicator.texture = checkmark_texture  # Shape differentiator
        indicator.modulate = Color.GREEN
    else:
        indicator.texture = x_mark_texture  # Shape differentiator
        indicator.modulate = Color.RED
    return indicator
```

---

## Known Issues to Consider

When working on this codebase, be aware of these documented issues:

### Critical (Blocking Release)
- Leaderboards not loading in Steam public_test build
- Steam Cloud Save verification incomplete
- Multiple ending branches not fully implemented
- Z-index rendering issues (documents, particles, corpses)

### Drag and Drop System (DaDS)
- Documents don't layer correctly when dragged
- Viewport masking needed for stamps
- Return-to-table buffers broken

### Audio System
- Keyboard audio desync in Dialogic scenes
- Missing SFX: lever, hover sounds, emotes
- Music bus routing needs verification

See `project_management/spud_customs_design_document.md#11-known-issues--action-items` for complete list.

---

## Git Workflow

### Branch Naming
```
feature/add-uv-lamp-scanning
fix/leaderboard-loading
refactor/queue-manager-pooling
docs/update-gdd-endings
```

### Commit Messages
```
Add UV lamp scanning mini-game

- Implement shader-based reveal effect
- Add bonus points for detection
- Integrate with rule validation system
```

### Pre-Commit Checks
- Run gdformat to ensure consistent formatting
- Run gdlint to catch common issues
- Run unit tests for affected systems
- Verify no orphan nodes in scenes

---

## Security Considerations

### Input Validation
```gdscript
# Sanitize user input
func set_player_name(name: String) -> void:
    var sanitized: String = name.strip_edges().substr(0, 32)
    player_name = sanitized
```

### Save Data Integrity
```gdscript
# Validate loaded data
func load_game_state() -> Dictionary:
    var data: Dictionary = {}
    # ... load logic ...
    if not _validate_save_data(data):
        push_error("Corrupted save data detected")
        return _get_default_state()
    return data
```

### Steam API Safety
```gdscript
# Always check Steam availability
if Steam.isSteamRunning():
    # Safe to call Steam APIs
    pass
else:
    # Graceful fallback
    pass
```

---

## Development Tools

### Debug Controls (Dev Builds Only)

See GDD section "Critical Debug Controls" for comprehensive keybinds:
- F1: Toggle debug overlay
- F2: Skip current shift
- F5: Toggle god mode
- etc.

**Critical**: All debug features must be disabled in release builds.

### Console Commands (Dev Only)
```
/skip_to_shift <number>
/reset_narrative
/spawn_runner
/stress_test <count>
```

---

## EventBus Architecture Pattern

### Overview

The project is actively migrating from direct Global singleton mutations to an EventBus-driven architecture. This decouples systems and makes state changes auditable and testable.

### Core Components

1. **EventBus** (`assets/autoload/EventBus.gd`) - Centralized signal hub with 50+ defined events
2. **GameStateManager** (`assets/autoload/GameStateManager.gd`) - Subscribes to events, manages state
3. **Global** (legacy) - Kept in sync for backward compatibility during migration

### Event Categories

```gdscript
# Score & Game State
EventBus.request_score_add(points, source, metadata)
EventBus.score_changed.connect(_on_score_changed)

# Strikes & Penalties
EventBus.request_strike_add(reason, metadata)
EventBus.strike_changed.connect(_on_strike_changed)

# Gameplay Events
EventBus.emit_runner_escaped(type, data)
EventBus.emit_runner_stopped(type, data)
EventBus.emit_perfect_hit_achieved(bonus_points)

# UI Feedback
EventBus.show_alert(message, is_positive, duration)
EventBus.show_screen_shake(intensity, duration)

# Narrative Events
EventBus.emit_narrative_choice_made(choice_data)
EventBus.dialogue_started.connect(_on_dialogue_started)

# Analytics & Achievements
EventBus.track_event(event_name, data)
EventBus.emit_achievement_unlocked(achievement_id)
```

### Migration Pattern

**Before (Anti-pattern):**
```gdscript
func handle_score_increase(points: int):
    Global.score += points
    score_label.text = str(Global.score)
```

**After (EventBus pattern):**
```gdscript
func _ready():
    EventBus.ui_score_update_requested.connect(_update_score_ui)

func handle_score_increase(points: int):
    EventBus.request_score_add(points, "gameplay_action", {
        "action_type": "perfect_stamp",
        "combo": current_combo
    })

func _update_score_ui(new_score: int):
    score_label.text = str(new_score)
```

### State Access

**Use GameStateManager for reads:**
```gdscript
# Preferred (new code)
var score = GameStateManager.get_score()
var strikes = GameStateManager.get_strikes()
var difficulty = GameStateManager.get_difficulty()

# Legacy (still works during migration)
var score = Global.score
```

### Migration Status

**Completed:**
- ✅ EventBus and GameStateManager created
- ✅ BorderRunnerSystem key methods migrated
- ✅ Analytics migrated to GameStateManager
- ✅ Global.gd emits narrative events

**High Priority (needs migration):**
- ⚠️ `analytics.gd` (15+ Global reads)
- ⚠️ `level_list_manager.gd` (advance_shift calls)
- ⚠️ `NarrativeManager.gd` (game_mode checks)
- ⚠️ `Global.gd` hardcoded paths (lines 265-267, 297-299, 457-459)

**See:** `docs/EVENTBUS_MIGRATION_GUIDE.md` for complete migration guide.

---

## Dependency Injection Pattern

### When to Use DI

Use dependency injection instead of direct autoload access when:
1. Unit testing with mocked dependencies
2. Creating reusable components
3. Reducing coupling to specific autoloads
4. Building new systems (use DI from the start)

### DI Patterns

**1. Constructor Injection:**
```gdscript
class_name MySystem
extends Node

var _save_manager: SaveManager
var _event_bus: Node

func _init(save_manager: SaveManager = null, event_bus: Node = null):
    _save_manager = save_manager if save_manager else get_node("/root/SaveManager")
    _event_bus = event_bus if event_bus else get_node("/root/EventBus")
```

**2. Property Injection:**
```gdscript
@export var save_manager: SaveManager
@export var steam_manager: SteamManager

func _ready():
    if not save_manager:
        save_manager = get_node_or_null("/root/SaveManager")
```

**3. EventBus Decoupling (Preferred):**
```gdscript
# Instead of direct calls:
SteamManager.unlock_achievement("achievement_id")

# Use events:
EventBus.emit_achievement_unlocked("achievement_id")
# SteamManager subscribes to this event
```

### Testing with DI

```gdscript
extends GutTest

class MockEventBus extends Node:
    signal score_changed(new_score: int, delta: int, source: String)

    func request_score_add(points: int, source: String, metadata: Dictionary = {}):
        score_changed.emit(100, points, source)

func test_score_update_with_mock():
    var mock_bus = MockEventBus.new()
    var system = MySystem.new(null, mock_bus)

    mock_bus.score_changed.connect(system._on_score_changed)
    mock_bus.request_score_add(50, "test")

    assert_eq(system.last_score_update, 100)
```

---

## Claude Code Slash Commands

The project includes slash commands for common development tasks. These consolidate project management workflows from `project_tasks.md`.

### Usage

Type `/` followed by the command name in Claude Code:

```
/test-system DragAndDropManager
/migrate-eventbus analytics.gd
/run-tests
/add-game-feature
```

### Available Commands

**Testing:**
- `/test-system` - Create unit tests for a system
- `/test-integration` - Create integration tests for user flows
- `/test-eventbus` - Create EventBus unit tests
- `/run-tests` - Run GUT test suite

**Architecture:**
- `/migrate-eventbus` - Migrate to EventBus pattern
- `/add-di-pattern` - Add dependency injection
- `/fix-hardcoded-paths` - Remove hardcoded /root/ paths

**Features:**
- `/add-game-feature` - Add new gameplay feature
- `/add-narrative-content` - Add Dialogic content
- `/add-achievement` - Add Steam achievement
- `/add-accessibility` - Add accessibility features
- `/add-localization` - Add localization

**Maintenance:**
- `/fix-z-index` - Fix z-index layering
- `/optimize-performance` - Optimize with pooling
- `/steam-integration` - Debug Steam features
- `/code-quality` - Run linting and formatting
- `/update-docs` - Update documentation

**See:** `.claude/commands/README.md` for complete command reference.

---

## Quick Reference

### Adding a New Game System

1. Create script in appropriate `scripts/systems/` subdirectory
2. Use `class_name` for registration
3. Add type hints to all variables and functions
4. **Use EventBus** for inter-system communication (not direct autoload access)
5. **Use dependency injection** where needed for testability
6. Implement unit tests in `tests/unit/`
7. Document with `##` docstrings
8. Register as autoload only if truly global

**Use slash command:** `/add-game-feature` for guided implementation

### Adding a New Potato Type

1. Create visual assets in `assets/potatoes/`
2. Update `PotatoFactory.gd` to include new type
3. Add localization keys in `translations/`
4. Update GDD documentation
5. Test with existing rule validation

### Adding a New Immigration Rule

1. Add rule definition in rule configuration
2. Implement validation logic in `LawValidator.gd`
3. Add corresponding unit tests
4. Add localization for rule description
5. Test with all potato types and edge cases

---

## Summary

**Core Principles:**
1. **Type safety** - Use explicit types everywhere
2. **EventBus-driven** - Use EventBus for inter-system communication
3. **Dependency injection** - Reduce coupling to autoload singletons
4. **Signal-driven** - Prefer events over polling
5. **Composition** - Build from reusable components
6. **Test coverage** - Unit test all core systems (target 80%)
7. **Performance aware** - Pool objects, optimize _process()
8. **Accessibility first** - Support all players
9. **Steam integration** - Graceful fallbacks for offline play

**Always Reference:**
- **EventBus Migration Guide** (`docs/EVENTBUS_MIGRATION_GUIDE.md`) for architecture patterns
- **Claude Code Commands** (`.claude/commands/`) for common tasks
- Game Design Document for feature specifications
- GUT test suite for expected behaviors
- CI/CD pipeline requirements before committing
- Known issues list to avoid reintroducing bugs

This project targets a polished Steam release with 2-3 hour story campaign, multiple endings, and competitive modes. Every code change should support maintainability, performance, and player experience.
