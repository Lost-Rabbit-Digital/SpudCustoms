# Spud Customs - Development Guidelines

> **Last Updated:** December 2024 | **Version:** 1.2.0 | **Engine:** Godot 4.5

## Project Overview

**Spud Customs** is a dystopian document thriller game built with **Godot 4.5** (Forward Plus renderer). Players take on the role of a customs officer in a world of anthropomorphic potatoes, processing documents and making decisions that affect narrative outcomes.

**Key Technical Stack:**
- **Engine**: Godot 4.5 with Forward Plus rendering
- **Language**: GDScript (GDScript 2.0)
- **Dialogue System**: Dialogic 2
- **Steam Integration**: GodotSteam (custom template)
- **Testing**: GUT (Godot Unit Test) v9.3.0
- **CI/CD**: GitHub Actions with gdformat, gdlint, gdradon
- **Error Tracking**: Sentry integration
- **Localization**: All Steam-supported languages (29 languages)

**Reference Documentation:**
- Game Design Document: `project_management/spud_customs_design_document.md`
- Pre-release Testing: `project_management/testing/prerelease_test_procedure.md`
- Steam Patch Notes: `project_management/steam_patch_notes/`
- **EventBus Migration Guide**: `docs/EVENTBUS_MIGRATION_GUIDE.md`
- **Test Documentation**: `godot_project/tests/README.md`

---

## Project Structure

```
SpudCustoms/
├── godot_project/                    # Main Godot 4.5 project
│   ├── addons/                       # Third-party plugins (Dialogic, GUT, Maaack's Template)
│   ├── assets/                       # Game assets (23 subdirectories)
│   │   ├── narrative/                # Dialogic characters (.dch) and timelines (.dtl)
│   │   ├── potatoes/                 # Potato character sprites
│   │   ├── audio/                    # Sound effects
│   │   ├── music/                    # Background music
│   │   ├── fonts/                    # Modern_DOS_Font_Variation
│   │   ├── styles/                   # UI themes and audio bus layouts
│   │   └── ...
│   ├── scenes/                       # Scene files (48 .tscn files)
│   │   ├── game_scene/               # Main gameplay scenes
│   │   ├── menus/                    # UI menus (main, options, level select)
│   │   ├── loading_screen/           # Loading screens
│   │   └── ...
│   ├── scripts/                      # GDScript source code (~80 files)
│   │   ├── autoload/                 # Global singletons (23 files)
│   │   ├── core/                     # Core game logic and level loading
│   │   ├── systems/                  # Game systems (~34 files)
│   │   ├── ui/                       # UI controllers
│   │   └── utils/                    # Helper utilities
│   ├── tests/                        # GUT unit & integration tests
│   │   ├── unit/                     # 14 unit test files
│   │   └── integration/              # 10 integration test files
│   ├── translations/                 # Localization files (458 .translation files)
│   ├── project.godot                 # Main project configuration
│   ├── export_presets.cfg            # Windows export configuration
│   └── steam_appid.txt               # Steam App ID: 3291880
├── docs/                             # Technical documentation
│   └── EVENTBUS_MIGRATION_GUIDE.md   # Architecture migration guide
├── project_management/               # Documentation and planning
├── .github/workflows/                # CI/CD automation
│   └── automated_tests.yml           # Static checks + unit tests
├── .gdlintrc                         # GDScript linting configuration
├── .gdformatrc                       # GDScript formatting configuration
└── .gutconfig.json                   # GUT test configuration
```

**Key Stats:**
- **GDScript files:** ~80 source files
- **Scene files:** 48 .tscn files
- **Autoload singletons:** 28 total (23 custom + 5 from plugins)
- **Supported languages:** 29 (all Steam-supported languages)
- **Unit tests:** 14 test files (400+ test cases)
- **Integration tests:** 10 test files

---

## Autoload Architecture

The project uses 28 autoload singletons for global state management. New code should use the EventBus pattern.

### Core Architecture (Active Migration)

| Autoload | Purpose | Notes |
|----------|---------|-------|
| `EventBus` | Centralized signal hub | **NEW** - Use for all inter-system communication |
| `GameStateManager` | Single source of truth for game state | **NEW** - Subscribes to EventBus events |
| `Global` | Legacy state manager | Being phased out - kept for backward compatibility |

### Specialized Managers

| Autoload | Purpose | Location |
|----------|---------|----------|
| `SaveManager` | Game state persistence | `scripts/autoload/` |
| `SteamManager` | Steam API (achievements, leaderboards, cloud) | `scripts/autoload/` |
| `UIManager` | UI effects (screen shake, alerts) | `scripts/autoload/` |
| `LawValidator` | Rule validation engine | `scripts/autoload/` |
| `TutorialManager` | Tutorial progression and overlays | `scripts/autoload/` |
| `AccessibilityManager` | Accessibility features | `scripts/autoload/` |
| `LocalizationManager` | Language management | `scripts/autoload/` |
| `LogManager` | Logging system | `scripts/autoload/` |
| `SentryManager` | Error reporting to Sentry | `scripts/autoload/` |
| `Analytics` | Analytics tracking | `scripts/autoload/` |
| `ControllerManager` | Gamepad support | `scripts/autoload/` |
| `SteamInputManager` | Steam Controller integration | `scripts/autoload/` |
| `VirtualCursor` | Custom cursor management | `scripts/autoload/` |
| `CursorManager` | Cursor behavior | `scripts/autoload/` |
| `InputGlyphManager` | Input prompt display | `scripts/autoload/` |
| `TwitchIntegrationManager` | Twitch streaming features | `scripts/autoload/` |
| `JuicyButtons` | Button juice/polish effects | `scripts/autoload/` |
| `ConstantZIndexes` | Z-index layering constants | `scripts/autoload/` |
| `DebugCommandManager` | Developer console commands | `scripts/autoload/` |
| `SceneTransitionManager` | Scene loading transitions | `scripts/autoload/` |

### Plugin Autoloads

| Autoload | Source |
|----------|--------|
| `Dialogic` | Dialogic 2 plugin |
| `AppConfig` | Maaack's Game Template |
| `SceneLoader` | Maaack's Game Template |
| `ProjectMusicController` | Maaack's Game Template |
| `ProjectUISoundController` | Maaack's Game Template |

---

## Godot 4.5 Best Practices

### Type Safety

**DO:**
```gdscript
# Use explicit type annotations everywhere
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
```

---

## EventBus Architecture Pattern

### Overview

The project is actively migrating from direct Global singleton mutations to an EventBus-driven architecture. This decouples systems and makes state changes auditable and testable.

### Core Components

1. **EventBus** (`scripts/autoload/EventBus.gd`) - Centralized signal hub with 50+ defined events
2. **GameStateManager** (`scripts/autoload/GameStateManager.gd`) - Subscribes to events, manages state
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
- ✅ EventBus integration tests added

**High Priority (needs migration):**
- ⚠️ `analytics.gd` (15+ Global reads)
- ⚠️ `level_list_manager.gd` (advance_shift calls)
- ⚠️ `NarrativeManager.gd` (game_mode checks)

**See:** `docs/EVENTBUS_MIGRATION_GUIDE.md` for complete migration guide.

---

## Common Anti-Patterns to AVOID

### 1. Direct Global Mutations

**BAD:**
```gdscript
func approve_potato() -> void:
    Global.score += 100
    SteamManager.stats["approvals"] += 1
```

**GOOD:**
```gdscript
func approve_potato() -> void:
    var info: Dictionary = %QueueManager.remove_front_potato()
    EventBus.request_score_add(100, "potato_approved", {
        "potato_type": info.type
    })
```

### 2. Hardcoded Magic Numbers

**BAD:**
```gdscript
if score > 10000:
    unlock_achievement()
```

**GOOD:**
```gdscript
const HIGH_SCORE_THRESHOLD: int = 10000

if score > HIGH_SCORE_THRESHOLD:
    unlock_achievement()
```

### 3. Using _process() for Everything

**BAD:**
```gdscript
func _process(delta: float) -> void:
    check_achievements()  # Expensive, runs 60+ times/sec
```

**GOOD:**
```gdscript
# Use timers or signals instead
func _ready() -> void:
    EventBus.score_changed.connect(_check_score_achievements)
```

### 4. Ignoring Null Safety

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
```

### 5. Mutating Arrays While Iterating

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

# Autoloads are in scripts/autoload/
scripts/autoload/SaveManager.gd
scripts/autoload/SteamManager.gd
scripts/autoload/EventBus.gd

# Tests mirror source structure
tests/unit/test_shift_stats.gd
tests/unit/test_event_bus.gd
tests/integration/test_eventbus_score_flow.gd
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
```

---

## Testing Requirements

### Test Framework: GUT v9.3.0

All core systems must have unit tests. Full documentation at `godot_project/tests/README.md`.

### Test Structure

```
tests/
├── run_tests.gd                      # CI/CD test runner
├── unit/                             # Unit tests (14 files)
│   ├── test_accessibility_manager.gd
│   ├── test_drag_and_drop_manager.gd
│   ├── test_event_bus.gd             # EventBus pattern tests
│   ├── test_law_validator.gd
│   ├── test_narrative_manager.gd
│   ├── test_potato_factory.gd
│   ├── test_queue_manager.gd
│   ├── test_save_manager.gd
│   ├── test_shift_stats.gd
│   ├── test_stamp_system.gd
│   ├── test_stats_manager.gd
│   ├── test_tutorial_manager.gd
│   └── test_ui_manager.gd
└── integration/                      # Integration tests (10 files)
    ├── test_achievement_flow.gd
    ├── test_border_runner_flow.gd
    ├── test_document_processing_flow.gd
    ├── test_eventbus_game_flow.gd    # EventBus integration
    ├── test_eventbus_score_flow.gd   # EventBus integration
    ├── test_eventbus_strike_flow.gd  # EventBus integration
    ├── test_narrative_choice_flow.gd
    ├── test_save_load_flow.gd
    └── test_shift_completion_flow.gd
```

### Writing Tests

```gdscript
extends GutTest

var stats: ShiftStats

func before_each() -> void:
    stats = ShiftStats.new()

func after_each() -> void:
    stats.free()
    stats = null

func test_get_missile_bonus_with_multiple_perfect_hits() -> void:
    stats.perfect_hits = 5
    var bonus: int = stats.get_missile_bonus()
    assert_eq(bonus, 750, "Should calculate 150 points per perfect hit")
```

### Running Tests

```bash
# Local: Via command line
cd godot_project
godot --headless --script res://tests/run_tests.gd

# CI: Tests run automatically via GitHub Actions
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

## Localization System

### Supported Languages (All Steam Languages - 29)

The game supports all Steam-supported languages:

| Language | Code | Language | Code |
|----------|------|----------|------|
| Arabic | ar | Korean | ko |
| Bulgarian | bg | Dutch | nl |
| Czech | cs | Norwegian | no |
| Danish | da | Polish | pl |
| German | de | Portuguese | pt |
| Greek | el | Portuguese (Brazil) | pt-BR |
| English | en | Romanian | ro |
| Spanish | es | Russian | ru |
| Spanish (Latin America) | es-419 | Slovak | sk |
| Finnish | fi | Swedish | sv |
| French | fr | Thai | th |
| Hungarian | hu | Turkish | tr |
| Indonesian | id | Ukrainian | uk |
| Italian | it | Vietnamese | vi |
| Japanese | ja | Chinese (Simplified) | zh-CN |
|  |  | Chinese (Traditional) | zh-TW |

### Translation File Organization

```
translations/
├── per_language/                        # Per-language CSV files for editing
├── game.{locale}.translation            # General UI strings
├── rules.{locale}.translation           # Immigration rules
├── menus.{locale}.translation           # Menu labels
├── passport.{locale}.translation        # Document fields
├── violations.{locale}.translation      # Rule violations
├── bubble_dialogue.{locale}.translation # Speech bubbles
└── dialogic_*.{locale}.translation      # Dialogic timelines
```

### Adding Translations

1. Add translation keys in the appropriate category CSV file
2. Export translations for all locales
3. Test with `LocalizationManager.set_locale(locale_code)`

---

## Steam Integration

### Achievement Tracking

```gdscript
# Track via EventBus (preferred)
EventBus.emit_achievement_unlocked("border_defender")

# Or direct call
if Steam.isSteamRunning():
    SteamManager.unlock_achievement("border_defender")
```

### Leaderboard Submission

```gdscript
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

### Available Timelines (17)

- `shift1_intro`, `shift1_end` through `shift10_intro`
- `generic_shift_start`, `final_confrontation`, `tutorial`

---

## CI/CD Pipeline

### GitHub Actions Workflow

**File:** `.github/workflows/automated_tests.yml`

**Jobs:**
1. **static-checks** - gdformat, gdlint, gdradon analysis
2. **unit-tests** - GUT test suite execution (depends on static-checks)

**Triggers:**
- Push to `main` branch
- All pull requests

### Pre-Commit Checklist

1. Run `gdformat --check godot_project/scripts/`
2. Run `gdlint godot_project/scripts/`
3. Run unit tests for affected systems
4. Verify no orphan nodes in scenes

---

## Quick Reference

### Adding a New Game System

1. Create script in appropriate `scripts/systems/` subdirectory
2. Use `class_name` for registration
3. Add type hints to all variables and functions
4. **Use EventBus** for inter-system communication
5. Implement unit tests in `tests/unit/`
6. Document with `##` docstrings
7. Register as autoload only if truly global

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

## Linting Configuration

### gdlint Rules (`.gdlintrc`)

| Rule | Value |
|------|-------|
| Max line length | 180 characters |
| Max file lines | 1500 |
| Max function arguments | 10 |
| Max public methods | 20 |
| Max returns | 6 |
| Tab characters | 1 (tabs, not spaces) |

### Naming Conventions Enforced

- Classes: `PascalCase`
- Variables: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Functions: `snake_case` or `_on_EventName`
- Signals: `snake_case`

---

## Summary

**Core Principles:**
1. **Type safety** - Use explicit types everywhere
2. **EventBus-driven** - Use EventBus for inter-system communication
3. **Signal-driven** - Prefer events over polling
4. **Composition** - Build from reusable components
5. **Test coverage** - Unit test all core systems (target 80%)
6. **Performance aware** - Pool objects, optimize _process()
7. **Accessibility first** - Support all players
8. **Steam integration** - Graceful fallbacks for offline play

**Always Reference:**
- **EventBus Migration Guide** (`docs/EVENTBUS_MIGRATION_GUIDE.md`)
- **Test README** (`godot_project/tests/README.md`)
- Game Design Document for feature specifications
- CI/CD pipeline requirements before committing

This project targets a polished Steam release with 2-3 hour story campaign, multiple endings, and competitive modes. Every code change should support maintainability, performance, and player experience.
