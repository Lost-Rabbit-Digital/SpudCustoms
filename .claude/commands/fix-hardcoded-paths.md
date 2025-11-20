---
description: Find and fix hardcoded /root/ node paths throughout the project
---

Find and eliminate hardcoded node paths of the form `get_node("/root/...")` throughout the project.

**Search for:**
- `get_node("/root/...)`
- `get_node_or_null("/root/...")`
- String paths in `connect()` calls
- Direct path references in autoloads

**Replacement Strategies:**

1. **Replace with EventBus** (preferred):
```gdscript
# Before: get_node("/root/NarrativeManager").record_choice()
# After: EventBus.emit_narrative_choice_made(choice_data)
```

2. **Use @onready with % (unique names)**:
```gdscript
# Before: get_node("/root/UIManager/HUD/ScoreLabel")
# After: @onready var score_label = %ScoreLabel
```

3. **Use optional chaining for autoloads**:
```gdscript
# Before: get_node("/root/SteamManager")
# After: var steam = get_node_or_null("/root/SteamManager")
if steam:
    steam.do_something()
```

**Known Locations** (from migration guide):
- `Global.gd` lines 265-267, 297-299, 457-459 (NarrativeManager)
- `ShiftSummaryScreen.gd` (SceneLoader)
- `DragAndDropManager.gd` (CursorManager)

Run a project-wide search and fix all instances.
