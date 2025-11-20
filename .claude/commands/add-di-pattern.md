---
description: Refactor a system to use dependency injection instead of autoload singletons
---

Refactor the specified system to use dependency injection pattern instead of direct autoload references.

**Dependency Injection Patterns:**

1. **Constructor Injection** (for systems):
```gdscript
class_name MySystem
extends Node

var _save_manager: SaveManager
var _steam_manager: SteamManager

func _init(save_manager: SaveManager, steam_manager: SteamManager):
    _save_manager = save_manager
    _steam_manager = steam_manager
```

2. **Property Injection** (for scenes):
```gdscript
@export var save_manager: SaveManager
@export var event_bus: Node  # Can be set in editor or code

func _ready():
    if not save_manager:
        save_manager = get_node_or_null("/root/SaveManager")
```

3. **EventBus Decoupling** (preferred for cross-system communication):
```gdscript
# Instead of: SteamManager.unlock_achievement()
# Use: EventBus.emit_achievement_unlocked("achievement_name")
```

**Benefits:**
- Easier unit testing (mock dependencies)
- Clearer dependencies at call sites
- Reduced coupling to Global singletons
- Better encapsulation

**Systems to Refactor:**
- Anything calling multiple autoloads directly
- Systems that need testing with mocked dependencies
- New systems (always use DI from the start)

Ask the user which system they want to refactor if not specified.
