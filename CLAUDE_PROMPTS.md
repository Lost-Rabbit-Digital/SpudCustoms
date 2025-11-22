# Claude Code Prompts - Remaining Work

This file contains actionable one-liner prompts you can copy and paste directly to Claude Code to execute remaining project work.

**Usage:** Copy any prompt below and paste it directly to Claude Code. You can run multiple prompts in parallel by separating them with "AND ALSO:"

---

## 🔥 High Priority - EventBus Migration

### Fix Hardcoded Paths

```
[DONE] Fix all hardcoded /root/ paths in the codebase by replacing them with EventBus events or @onready references with unique names
```

### Migrate Remaining Files

```
[DONE] Migrate godot_project/scripts/level_list_manager.gd to use EventBus pattern instead of direct Global.advance_shift() calls
```

```
[DONE] Migrate godot_project/assets/autoload/NarrativeManager.gd to use EventBus pattern and GameStateManager instead of direct Global access
```

```
[DONE] Remove hardcoded /root/NarrativeManager paths from godot_project/assets/autoload/Global.gd lines 270, 306, and 470
```

```
[DONE] Migrate godot_project/scripts/systems/ShiftSummaryScreen.gd to use EventBus and dependency injection instead of get_node("/root/SceneLoader")
```

```
[DONE] Migrate godot_project/scripts/utils/cursor_manager.gd to use EventBus for NarrativeManager communication
```

---

## 🧪 Unit Tests for Untested Systems

```
[DONE] Create comprehensive unit tests for godot_project/assets/autoload/TutorialManager.gd in tests/unit/test_tutorial_manager.gd
```

```
[DONE] Create comprehensive unit tests for godot_project/assets/autoload/AccessibilityManager.gd in tests/unit/test_accessibility_manager.gd
```

```
[DONE] Create comprehensive unit tests for godot_project/assets/autoload/SaveManager.gd in tests/unit/test_save_manager.gd
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

### Phase 1: Complete EventBus Migration (1-2 hours)
1. Fix all hardcoded /root/ paths
2. Migrate level_list_manager.gd
3. Migrate NarrativeManager.gd
4. Migrate ShiftSummaryScreen.gd
5. Update EventBus migration guide

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

**Total Estimated Time:** 7-11 hours to complete all prompts
**Current Progress:** EventBus architecture 70% migrated, 125+ tests created
**Next Priority:** Complete EventBus migration (Phase 1)
