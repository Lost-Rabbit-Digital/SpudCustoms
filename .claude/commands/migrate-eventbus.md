---
description: Migrate a file to use EventBus pattern instead of direct Global mutations
---

Migrate the specified file to use the EventBus pattern following the guide in `docs/EVENTBUS_MIGRATION_GUIDE.md`.

**Migration Steps:**
1. **Identify Direct Mutations**: Find all instances of `Global.score`, `Global.strikes` direct modifications
2. **Replace with Events**: Convert to `EventBus.request_score_add()`, `EventBus.request_strike_add()`
3. **Replace Hardcoded Paths**: Change `get_node("/root/...")` to EventBus subscriptions
4. **Add Event Subscriptions**: Connect to EventBus signals in `_ready()`
5. **Use GameStateManager**: Replace `Global.score` reads with `GameStateManager.get_score()`
6. **Include Metadata**: Add relevant context to event emissions
7. **Test Thoroughly**: Verify functionality unchanged after migration

**High Priority Files** (from migration guide):
- `godot_project/scripts/core/analytics.gd` (15+ Global reads)
- `godot_project/scripts/level_list_manager.gd` (advance_shift calls)
- `godot_project/scripts/systems/NarrativeManager.gd` (game_mode checks)
- `godot_project/assets/autoload/Global.gd` (hardcoded NarrativeManager paths)

**Medium Priority Files:**
- `godot_project/scripts/ui/FeedbackMenu.gd`
- `godot_project/scripts/systems/ShiftSummaryScreen.gd`
- `godot_project/scripts/utils/DragAndDropManager.gd`

Ask the user which file they want to migrate if not specified.
