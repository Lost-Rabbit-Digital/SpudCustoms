# Claude Code Prompts - Remaining Work

This file contains actionable one-liner prompts you can copy and paste directly to Claude Code to execute remaining project work.

**Usage:** Copy any prompt below and paste it directly to Claude Code. You can run multiple prompts in parallel by separating them with "AND ALSO:"

---

## 🔥 High Priority - EventBus Migration

### Fix Hardcoded Paths

```
[DONE] Fix all hardcoded /root/ paths in the codebase by replacing them with EventBus events or @onready references with unique names
```

### Core System Migrations (High Priority)

#### 1. Analytics System
```
Migrate godot_project/scripts/core/analytics.gd to use EventBus and GameStateManager:
- Replace all Global.score/strikes/shift reads with GameStateManager.get_*() methods
- Subscribe to EventBus.score_changed, EventBus.strike_changed, EventBus.shift_advanced for analytics tracking
- Use EventBus.analytics_event for emitting analytics data
- Remove all direct Global property access (11 instances found)
```

#### 2. Level List Manager
```
Migrate godot_project/scripts/level_list_manager.gd to use EventBus pattern:
- Replace Global.advance_shift() calls with EventBus.shift_advance_requested.emit()
- Subscribe to EventBus.shift_advanced for confirmation
- Replace Global.game_mode reads with GameStateManager.get_game_mode()
- Use GameStateManager.get_shift() instead of Global.shift
```

#### 3. Main Game Scene
```
Migrate godot_project/scenes/game_scene/mainG- [x] **analytics.gd** ✅ **COMPLETED**
  - [x] Replace `Global.score` with `GameStateManager.get_score()`
  - [x] Replace `Global.strikes` with `GameStateManager.get_strikes()`
  - [x] Subscribe to `EventBus` signals for tracking

- [x] **mainGame.gd** ✅ **COMPLETED**
  - [x] Replace `Global.score` updates with `EventBus.request_score_add()`
  - [x] Replace `Global.strikes` updates with `EventBus.request_strike_add()`
  - [x] Replace `Global.shift` advancement with `EventBus.shift_advance_requested`
  - [x] Subscribe to `EventBus` signals for UI updates

- [x] **level_list_manager.gd** ✅ **COMPLETED**
  - [x] Replace `Global.shift` reads
  - [x] Use EventBus for level transitionstead of direct UI manipulation
```

#### 4. Narrative Manager
```
[DONE] Migrate godot_project/scripts/systems/NarrativeManager.gd to use EventBus and GameStateManager:
- [x] Replace all Global.game_mode checks with GameStateManager.get_game_mode()
- [x] Replace all Global.shift reads with GameStateManager.get_shift()
- [x] All dialogue lifecycle events use EventBus (dialogue_started, dialogue_ended, etc.)
- [x] Subscribe to narrative_choices_load_requested and narrative_choices_save_requested
- [x] Emits achievement_unlocked, level_unlock_requested, story_state_changed events
```

#### 5. Global.gd Hardcoded Paths
```
[DONE] Remove hardcoded /root/NarrativeManager paths from godot_project/assets/autoload/Global.gd:
- Line ~270: Replace get_node("/root/NarrativeManager") with EventBus.narrative_choices_save_requested.emit()
- Line ~306: Replace get_node("/root/NarrativeManager") with EventBus.narrative_choices_load_requested.emit()
- Line ~470: Replace get_node("/root/NarrativeManager") with EventBus signal subscription
- Use get_node_or_null() pattern or EventBus for all cross-system communication
```

### UI System Migrations (Medium Priority) ✅ ALL COMPLETED

#### 6. Shift Summary Screen
```
[DONE] Migrate godot_project/scripts/systems/ShiftSummaryScreen.gd to use EventBus and dependency injection:
- [x] Removed get_node("/root/SceneLoader") - uses get_tree() directly
- [x] Uses GameStateManager.get_shift(), get_score(), get_strikes(), get_difficulty()
- [x] Uses GameStateManager.get_max_strikes(), get_build_type(), is_dev_mode()
- [x] Emits EventBus.shift_stats_reset on continue/restart/menu
- [x] Uses get_node_or_null() pattern for NarrativeManager
```

#### 7. Drag and Drop Manager
```
[DONE] Migrate godot_project/scripts/systems/drag_and_drop/drag_and_drop_manager.gd to use dependency injection:
- [x] Uses CursorManager autoload directly instead of get_node("/root/CursorManager")
- [x] Uses get_node_or_null() for all scene references
- [x] Clean signal-based communication with drag_system
```

#### 8. Feedback Menu
```
[DONE] Migrate godot_project/scripts/ui/FeedbackMenu.gd to use GameStateManager:
- [x] Uses GameStateManager.get_total_playtime() for system info
- [x] Simple self-contained feedback form (no Global dependencies)
```

#### 9. Level Select Menu
```
[DONE] Migrate godot_project/scenes/menus/level_select_menu/level_select_menu.gd to use EventBus:
- [x] Uses GameStateManager.get_shift() and GameStateManager.set_shift()
- [x] Uses GameStateManager.switch_game_mode() for mode changes
- [x] Uses GameStateManager.get_difficulty() for high score lookups
- [x] Emits level_selected signal for parent coordination
```

### Already Completed ✅

```
[DONE] Migrate godot_project/scripts/utils/cursor_manager.gd to use EventBus for NarrativeManager communication
```

---

## 🎯 Quick Reference: Migration Priority Order

Copy these prompts in order for systematic EventBus migration:

**Phase 1 - Core Systems (Critical):**
1. `analytics.gd` - 11 Global references, core metrics tracking
2. `mainGame.gd` - 78 Global references, main game loop
3. `level_list_manager.gd` - Shift progression logic
4. `NarrativeManager.gd` - Partial migration needed
5. `Global.gd` - Remove 3 hardcoded paths

**Phase 2 - UI Systems (Important):**
6. `ShiftSummaryScreen.gd` - End of shift UI
7. `level_select_menu.gd` - Level selection UI
8. `FeedbackMenu.gd` - User feedback form
9. `DragAndDropManager.gd` - Document interaction

**Estimated Total Work:** 4-6 hours for all migrations

---

## 📝 EventBus Migration Templates

Use these templates to migrate any system to use EventBus. Replace `{FILE_PATH}` and `{SYSTEM_NAME}` with actual values.

### Template 1: Migrate Single File to EventBus

```
Migrate {FILE_PATH} to use EventBus for {SYSTEM_NAME} communication
```

**Examples:**
```
Migrate godot_project/scripts/systems/StampSystem.gd to use EventBus for score and achievement communication
```
```
Migrate godot_project/scripts/ui/PauseMenu.gd to use EventBus for game state changes
```

### Template 2: Remove Direct Global Access

```
Replace all direct Global.{property} access in {FILE_PATH} with GameStateManager getters and EventBus events
```

**Examples:**
```
Replace all direct Global.score and Global.strikes access in godot_project/scripts/systems/PotatoPerson.gd with GameStateManager getters and EventBus events
```

### Template 3: Remove Hardcoded Paths

```
Remove all hardcoded /root/{NodeName} paths from {FILE_PATH} and replace with EventBus subscriptions or dependency injection
```

**Examples:**
```
Remove all hardcoded /root/NarrativeManager paths from godot_project/assets/autoload/Global.gd and replace with EventBus subscriptions
```

### Template 4: Full System Refactor

```
Refactor {FILE_PATH} to follow EventBus pattern:
1. Remove direct Global mutations
2. Replace with EventBus.request_* emissions
3. Subscribe to relevant EventBus signals in _ready()
4. Use GameStateManager for state reads
```

**Examples:**
```
Refactor godot_project/scripts/systems/RunnerSpawner.gd to follow EventBus pattern:
1. Remove direct Global mutations
2. Replace with EventBus.request_* emissions
3. Subscribe to relevant EventBus signals in _ready()
4. Use GameStateManager for state reads
```

### Migration Checklist Template

When migrating a file, ensure:
- [ ] No direct references to `Global.{mutable_property}`
- [ ] No `get_node("/root/...")` calls
- [ ] Emits events instead of mutating state
- [ ] Subscribes to EventBus signals in `_ready()`
- [ ] Uses `GameStateManager.get_*()` for state reads
- [ ] Includes metadata in event emissions
- [ ] Tests updated to use EventBus mocking

---

## 🧪 Unit Tests for Untested Systems

```
Create comprehensive unit tests for godot_project/assets/autoload/TutorialManager.gd in tests/unit/test_tutorial_manager.gd
```

```
Create comprehensive unit tests for godot_project/assets/autoload/AccessibilityManager.gd in tests/unit/test_accessibility_manager.gd
```

```
Create comprehensive unit tests for godot_project/assets/autoload/SaveManager.gd in tests/unit/test_save_manager.gd
```

```
Create comprehensive unit tests for godot_project/scripts/systems/QueueManager.gd in tests/unit/test_queue_manager.gd
```

```
Create comprehensive unit tests for godot_project/scripts/systems/PotatoFactory.gd in tests/unit/test_potato_factory.gd expanding on existing tests
```

```
Create comprehensive unit tests for godot_project/scripts/systems/stamp/StampSystem.gd in tests/unit/test_stamp_system.gd
```

```
Create comprehensive unit tests for godot_project/assets/autoload/UIManager.gd in tests/unit/test_ui_manager.gd
```

---

## 🔗 Integration Tests

```
Create integration test for narrative choice flow in tests/integration/test_narrative_choice_flow.gd testing dialogue → choice → save → load → verification
```

```
Create integration test for achievement unlocking flow in tests/integration/test_achievement_flow.gd testing action → stat tracking → unlock → Steam sync
```

```
Create integration test for save/load persistence in tests/integration/test_save_load_flow.gd testing all game state persists correctly
```

---

## ✨ Code Quality

```
Run gdformat check on godot_project/scripts/ and report all formatting violations with file paths and line numbers
```

```
Run gdlint analysis on godot_project/scripts/ and report all linting errors with severity levels
```

```
Analyze godot_project/scripts/ for functions with cyclomatic complexity >10 and suggest refactoring opportunities
```

```
Find all instances of magic numbers in godot_project/scripts/systems/ and suggest converting them to named constants
```

```
Search for all _process() functions that could be converted to signals or timers for better performance
```

---

## 📚 Documentation Updates

```
Update godot_project/tests/README.md to document the new EventBus tests and integration test structure
```

```
Update docs/EVENTBUS_MIGRATION_GUIDE.md to mark analytics.gd as completed and update the migration checklist
```

```
Create a new file docs/TESTING_GUIDE.md documenting how to run tests, write new tests, and interpret results
```

```
Review project_management/spud_customs_design_document.md and update known issues list to reflect completed EventBus migration
```

---

## ⚡ Performance Optimization

```
Implement object pooling for godot_project/scripts/systems/PotatoPerson.gd footprint system to prevent create/destroy overhead
```

```
Implement object pooling for explosion VFX in godot_project/scripts/systems/BorderRunnerSystem.gd
```

```
Optimize godot_project/scripts/systems/QueueManager.gd to batch spawn operations instead of spawning one potato per frame
```

---

## 🎮 Feature Implementation

```
Add viewport masking to godot_project/scripts/systems/stamp/StampSystem.gd to prevent stamps from appearing outside passport bounds
```

```
Fix z-index layering for explosions and corpses in godot_project/scripts/systems/BorderRunnerSystem.gd so corpses appear behind explosions
```

```
Add citation system as alternative to strikes in godot_project/assets/autoload/GameStateManager.gd for more forgiving gameplay
```

```
Implement combo multiplier system for consecutive perfect stamps with visual feedback in UI
```

---

## 🎮 Steam Integration

```
Debug Steam leaderboard loading issues in godot_project/assets/autoload/SteamManager.gd by adding detailed logging and timeout handling
```

```
Verify Steam Cloud Save paths in godot_project/assets/autoload/SteamManager.gd and ensure all save files are uploaded to cloud
```

```
Test all Steam achievements defined in godot_project/assets/autoload/Global.gd and verify unlock conditions work correctly
```

---

## ♿ Accessibility

```
Add colorblind mode filters to godot_project/scripts/systems/stamp/StampBarController.gd ensuring stamps use shape + color differentiation
```

```
Implement font scaling support across all UI in godot_project/scenes/menus/ to support Small/Medium/Large/Extra Large sizes
```

```
Add keyboard navigation support to godot_project/scenes/menus/main_menu.tscn with visible focus indicators
```

---

## 🔧 Quick Fixes

```
Fix the DragAndDropManager return_item_to_table buffer issue documented in project_tasks.md line 63
```

```
Fix cursor not updating after document drag in godot_project/scripts/systems/drag_and_drop/drag_and_drop_manager.gd
```

```
Add SFX for office shutter lever in godot_project/scripts/systems/OfficeShutterController.gd
```

```
Fix music persistence bug when returning to main menu from Dialogic scene
```

---

## 📋 Running Multiple Prompts

To run multiple prompts in one session, separate them with "AND ALSO:":

```
Fix all hardcoded /root/ paths in the codebase by replacing them with EventBus events or @onready references with unique names

AND ALSO:

Create comprehensive unit tests for godot_project/assets/autoload/TutorialManager.gd in tests/unit/test_tutorial_manager.gd

AND ALSO:

Update docs/EVENTBUS_MIGRATION_GUIDE.md to mark analytics.gd as completed and update the migration checklist
```

---

## 🎯 Recommended Execution Order

### Phase 1: Complete EventBus Migration (4-6 hours)
1. Analytics System (30 min) - Core metrics tracking
2. Main Game Scene (2 hours) - Most complex, 78 Global references
3. Level List Manager (30 min) - Shift progression
4. Narrative Manager (45 min) - Finalize dialogue integration
5. Global.gd paths (30 min) - Remove hardcoded NarrativeManager paths
6. Shift Summary Screen (30 min) - End-of-shift UI
7. Level Select Menu (30 min) - Menu system
8. Feedback Menu (15 min) - Simple form
9. Drag and Drop Manager (30 min) - Document handling
10. Update EventBus migration guide (15 min)

### Phase 2: Test Coverage (2-3 hours)
1. Create TutorialManager tests
2. Create AccessibilityManager tests
3. Create SaveManager tests
4. Create integration tests for narrative flow
5. Create integration tests for achievements

### Phase 3: Code Quality (1 hour)
1. Run gdformat check
2. Run gdlint analysis
3. Find and fix magic numbers
4. Update documentation

### Phase 4: Performance & Features (2-3 hours)
1. Implement object pooling for footprints
2. Implement object pooling for explosions
3. Add viewport masking for stamps
4. Fix z-index issues
5. Add citation system

### Phase 5: Polish (1-2 hours)
1. Fix quick bugs
2. Add missing SFX
3. Implement accessibility features
4. Debug Steam integration

---

## ✅ Tracking Progress

After executing a prompt:
1. Mark it complete by adding `[DONE]` at the start of the line
2. Commit the changes
3. Move to the next prompt

Example:
```
[DONE] Fix all hardcoded /root/ paths in the codebase by replacing them with EventBus events or @onready references with unique names
```

---

## 💡 Tips

- **Short on time?** Pick any single prompt and run it (5-15 min)
- **Have an hour?** Run a complete phase
- **Batch work:** Run 3-5 related prompts together with "AND ALSO:"
- **Test often:** After migration prompts, run the related test prompt
- **Commit often:** Each prompt produces committable work

---

**Total Estimated Time:** 11-17 hours to complete all prompts
**Current Progress:**
- [x] Create EventBus.gd
- [x] Create GameStateManager.gd
- [x] Migrate Global.gd (Hardcoded paths fixed)
- [x] Migrate analytics.gd
- [x] Migrate level_list_manager.gd
- [x] Migrate mainGame.gd (MAJOR MILESTONE!)
- [x] Migrate NarrativeManager.gd ✅
- [x] Migrate ShiftSummaryScreen.gd ✅
- [x] Migrate level_select_menu.gd ✅
- [x] Migrate FeedbackMenu.gd ✅
- [x] Migrate DragAndDropManager.gd ✅

**Status:** 🎉 100% Complete - All Systems Migrated!
**Remaining Work:** Unit tests, event documentation, Global.gd deprecation plan
