# Performance Analysis Report

> **Generated:** December 2025 | **Analyzed Files:** ~80 GDScript files

## Executive Summary

This analysis identified **32 performance anti-patterns** across the codebase, categorized by severity:

| Severity | Count | Impact |
|----------|-------|--------|
| **CRITICAL** | 6 | Frame drops, visible stuttering |
| **HIGH** | 12 | Cumulative performance degradation |
| **MEDIUM** | 14 | Memory overhead, initialization delays |

---

## CRITICAL Issues (Fix Immediately)

### 1. Disk I/O on Every Stamp Action

**Files:**
- `scripts/systems/stamp/stamp_system.gd:334-339`
- `scripts/systems/stamp/StampBarController.gd:430-436`

**Problem:** Audio files are loaded from disk inside a loop every time `play_random_stamp_sound()` is called.

```gdscript
# CURRENT (BAD) - stamp_system.gd:334
func play_random_stamp_sound():
    var sound_files = []
    for sound_path in stamp_sounds:
        var sound = load(sound_path)  # DISK I/O every stamp!
        if sound:
            sound_files.append(sound)
```

**Impact:** Causes frame hitches every time the player stamps a document - the core gameplay action.

**Fix:**
```gdscript
# Preload in class body or _ready()
var _cached_stamp_sounds: Array[AudioStream] = []

func _ready() -> void:
    for sound_path in stamp_sounds:
        var sound = load(sound_path)
        if sound:
            _cached_stamp_sounds.append(sound)

func play_random_stamp_sound():
    if _cached_stamp_sounds.is_empty():
        return
    var random_sound = _cached_stamp_sounds.pick_random()
    # ... play the sound
```

---

### 2. Missile Texture Reload on Every Creation

**File:** `scripts/systems/PotatoFactory.gd:316-329`

**Problem:** `create_missile_sprite()` reloads the same 2 missile textures every time a missile is created.

```gdscript
# CURRENT (BAD)
static func create_missile_sprite() -> AnimatedSprite2D:
    var missile_frames = []
    for i in range(1, 3):
        var texture_path = "res://assets/missiles/rocket_frame_%d.png" % i
        var texture = load(texture_path)  # Called for EVERY missile
```

**Impact:** Border runner gameplay creates multiple missiles; each creation causes disk I/O.

**Fix:** Add static caching like the existing explosion frame pattern:
```gdscript
static var _missile_frames_cache: Array = []
static var _missile_frames_loaded: bool = false

static func create_missile_sprite() -> AnimatedSprite2D:
    if not _missile_frames_loaded:
        for i in range(1, 3):
            var texture = load("res://assets/missiles/rocket_frame_%d.png" % i)
            if texture:
                _missile_frames_cache.append(texture)
        _missile_frames_loaded = true
    # Use _missile_frames_cache instead
```

---

### 3. Blocking Steam Cloud I/O on Game Load

**File:** `scripts/autoload/SaveManager.gd:72-81`

**Problem:** Cloud save loading uses synchronous Steam API calls that block the main thread.

```gdscript
var cloud_file_exists = Steam.fileExists("gamestate.save")  # Blocks
var file_size = Steam.getFileSize("gamestate.save")         # Blocks
var file_content = Steam.fileRead("gamestate.save", file_size)  # Blocks
```

**Impact:** Game startup is blocked during Steam cloud sync; players see a freeze.

**Fix:** Use async Steam API or defer to a background thread. Consider showing a loading indicator.

---

### 4. Scene Loading Without Caching

**File:** `scripts/systems/ShiftSummaryScreen.gd:958`

**Problem:** Scene files loaded and instantiated synchronously without caching.

```gdscript
var new_scene = load(scene_path).instantiate()  # Blocks frame
```

**Impact:** Scene transitions within the summary screen cause visible stutters.

**Fix:** Preload known scenes or use `ResourceLoader.load_threaded_request()`.

---

### 5. Signal Connection Imbalance (Memory Leak Risk)

**Scope:** Entire codebase

**Problem:** 185 signal connections but only 4 disconnections across all scripts.

**Top Offenders:**
| File | Connections | Disconnections |
|------|-------------|----------------|
| `SentryManager.gd` | 18 | 0 |
| `NarrativeManager.gd` | 12 | 4 |
| `BorderRunnerSystem.gd` | 12 | 0 |
| `GameStateManager.gd` | 12 | 0 |
| `analytics.gd` | 12 | 0 |

**Impact:** Signal handlers accumulate over time, causing memory leaks and phantom callbacks.

**Fix:** Implement cleanup in `_exit_tree()`:
```gdscript
func _exit_tree() -> void:
    if EventBus.score_add_requested.is_connected(_on_score_add_requested):
        EventBus.score_add_requested.disconnect(_on_score_add_requested)
```

---

### 6. Dynamic Timer Creation in Hover Handler

**File:** `scripts/autoload/juicy_buttons.gd:198`

**Problem:** A new Timer is created every time the mouse enters a button.

```gdscript
func _on_button_mouse_entered(button: Control, hover_defaults: Dictionary) -> void:
    var timer = Timer.new()  # NEW TIMER EVERY HOVER
    timer.wait_time = 0.016
    button.add_child(timer)
```

**Impact:** Rapid mouse movements create timer accumulation; if button is freed during hover, timer orphans.

**Fix:** Reuse a single Timer per button or use `Tween` instead.

---

## HIGH Priority Issues

### 7. Expensive Operations in _process()

**Files and specific issues:**

| File | Line | Issue |
|------|------|-------|
| `cursor_manager.gd` | 78, 101 | `get_tree().paused` and `get_viewport().get_mouse_position()` every frame |
| `parallax_mouse_background.gd` | 29-30 | `get_viewport_rect().size` + `get_viewport().get_mouse_position()` every frame |
| `BorderRunnerSystem.gd` | 334, 342 | `get_tree().paused` + `get_viewport_rect().grow(100)` creating new Rect2 every frame |
| `SteamManager.gd` | 166 | `Steam.isSteamRunning()` polled every frame |

**Fix:** Cache these values:
```gdscript
@onready var _viewport: Viewport = get_viewport()
var _cached_viewport_size: Vector2

func _ready() -> void:
    _cached_viewport_size = get_viewport_rect().size
    get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
    _cached_viewport_size = get_viewport_rect().size
```

---

### 8. Repeated get_nodes_in_group() Calls

**File:** `scripts/systems/BorderRunnerSystem.gd`

| Lines | Group | Calls |
|-------|-------|-------|
| 1038, 1121, 1413, 1423 | "PotatoPerson" | 4 times |
| 1413 | "Tween" | 1 time |

**File:** `scripts/systems/NarrativeManager.gd`

| Lines | Group |
|-------|-------|
| 381, 387, 1034, 1043 | "DialogueSkipButtons" (4 calls) |

**Impact:** `get_nodes_in_group()` traverses the scene tree; redundant calls waste CPU.

**Fix:** Cache results within the same function or frame:
```gdscript
func cleanup_and_process() -> void:
    var all_potatoes = get_tree().get_nodes_in_group("PotatoPerson")
    # Use all_potatoes multiple times instead of re-querying
```

---

### 9. Repeated find_children() Calls

**File:** `scripts/autoload/AccessibilityManager.gd:313-365`

**Problem:** `find_children()` called 9 times in `_apply_dyslexia_font_to_scene()` for the same scene.

**Fix:** Query once and iterate:
```gdscript
func _apply_dyslexia_font_to_scene(scene: Node) -> void:
    var labels = scene.find_children("*", "Label", true, false)
    var buttons = scene.find_children("*", "Button", true, false)
    var rich_texts = scene.find_children("*", "RichTextLabel", true, false)

    if not dyslexia_font_enabled:
        for label in labels:
            label.remove_theme_font_override("font")
        # ... etc
        return

    var font = get_dyslexia_font()
    for label in labels:
        label.add_theme_font_override("font", font)
    # ... etc
```

---

### 10. String Concatenation in Debug Function

**File:** `scripts/autoload/SteamManager.gd:676-693`

**Problem:** 18 string concatenations using `+=` operator.

```gdscript
var debug_info = "=== STEAM MANAGER DEBUG INFO ===\n"
debug_info += "Steam running: " + str(Steam.isSteamRunning()) + "\n"
debug_info += "Steam logged on: " + str(Steam.loggedOn()) + "\n"
# ... 15 more concatenations
```

**Impact:** Each `+=` creates a new string object; O(n²) memory allocation.

**Fix:**
```gdscript
func dump_debug_info() -> String:
    var parts: PackedStringArray = [
        "=== STEAM MANAGER DEBUG INFO ===",
        "Steam running: %s" % Steam.isSteamRunning(),
        "Steam logged on: %s" % Steam.loggedOn(),
        # ... etc
    ]
    return "\n".join(parts)
```

---

### 11. LogManager Flush on Every Write

**File:** `scripts/autoload/LogManager.gd:108-109`

**Problem:** Every log entry calls `flush()`, causing synchronous disk I/O.

```gdscript
_current_log_file.store_string(formatted_message)
_current_log_file.flush()  # Blocks on every log!
```

**Impact:** Heavy logging causes frame stutters.

**Fix:** Batch writes and flush periodically:
```gdscript
var _log_buffer: PackedStringArray = []
const FLUSH_INTERVAL: float = 1.0

func _ready() -> void:
    var flush_timer = Timer.new()
    flush_timer.wait_time = FLUSH_INTERVAL
    flush_timer.timeout.connect(_flush_log_buffer)
    add_child(flush_timer)
    flush_timer.start()

func log_message(message: String) -> void:
    _log_buffer.append(message)

func _flush_log_buffer() -> void:
    if _log_buffer.is_empty():
        return
    _current_log_file.store_string("\n".join(_log_buffer))
    _current_log_file.flush()
    _log_buffer.clear()
```

---

### 12. Duplicate Giblet Texture Loading

**File:** `scripts/systems/BorderRunnerSystem.gd:302-308`

**Problem:** Giblet textures loaded in `_ready()` despite `PotatoFactory` already having `load_gib_textures()`.

**Fix:** Use the existing factory method:
```gdscript
func _ready() -> void:
    gib_textures = PotatoFactory.load_gib_textures()
```

---

## MEDIUM Priority Issues

### 13. Character Generator Instantiation/Destruction

**Files:** `PotatoFactory.gd:46`, `PotatoPerson.gd:85-87`

**Problem:** Character generator scene instantiated and immediately freed for each potato.

```gdscript
var character_gen = character_generator_scene.instantiate()
character_gen.randomise_character()
character_gen.queue_free()  # Immediate destruction
```

**Impact:** GC pressure from repeated allocations if potato spawning is frequent.

**Fix:** Implement object pooling for the character generator.

---

### 14. Missing is_instance_valid() Checks

**Files affected:**
- `ShiftSummaryScreen.gd` - Accesses potentially freed nodes
- `PotatoPerson.gd` - 6 `queue_free()` calls with minimal validation
- `TensionManager.gd` - Accesses Global without checks

**Fix:** Always validate before access:
```gdscript
if is_instance_valid(potato):
    potato.update_animation()
```

---

### 15. AtlasTexture Recreation

**Files:**
- `BorderRunnerSystem.gd:207, 227, 247`
- `PotatoFactory.gd:287`

**Problem:** New `AtlasTexture` objects created from same spritesheet repeatedly.

**Fix:** Cache generated atlas frames as static resources.

---

### 16. await get_tree() Patterns

**Files:**
- `ControllerManager.gd:373`
- `TensionManager.gd:375`
- `TutorialManager.gd:1024, 1088, 1129`
- `UIManager.gd:300`
- `ShiftSummaryScreen.gd:1121`

**Problem:** `await get_tree().create_timer(X).timeout` can become orphaned if node is freed.

**Fix:** Store timer reference and cancel on `_exit_tree()`, or use Tween with bound lifetime.

---

### 17. O(n²) Array Operations

**File:** `scripts/autoload/TwitchIntegrationManager.gd:349-352`

```gdscript
var available: Array[String] = []
for name in viewer_names:
    if name not in used_viewer_names:  # O(n) check for each element
        available.append(name)
```

**Fix:** Convert `used_viewer_names` to a Dictionary for O(1) lookups:
```gdscript
var used_set: Dictionary = {}
for name in used_viewer_names:
    used_set[name] = true

var available: Array[String] = []
for name in viewer_names:
    if not used_set.has(name):
        available.append(name)
```

---

### 18. Log Rotation I/O During Initialization

**File:** `scripts/autoload/LogManager.gd:69-95`

**Problem:** `_rotate_logs()` stats every log file during startup.

**Fix:** Cache results or defer to background thread.

---

## Recommendations Summary

### Immediate Actions (This Sprint)
1. **Cache stamp sounds** in both stamp files
2. **Cache missile textures** with static variables
3. **Add signal disconnection** to top 5 offending autoloads

### Short-Term (Next Sprint)
4. **Cache _process() values** (viewport, tree.paused)
5. **Consolidate get_nodes_in_group() calls**
6. **Batch LogManager writes**

### Medium-Term (Backlog)
7. **Implement object pooling** for character generator
8. **Add async loading** for Steam cloud saves
9. **Convert array checks to Dictionary** in TwitchIntegrationManager

---

## Metrics to Track

After implementing fixes, measure:
- **Frame time during stamping** (target: <16.6ms)
- **Startup time** (target: <3s to main menu)
- **Memory growth over 30-minute session** (target: <50MB growth)
- **GC pause frequency** (target: <1 per minute during gameplay)

---

## Related Documentation

- [CLAUDE.md](../CLAUDE.md) - Project coding standards
- [EVENTBUS_MIGRATION_GUIDE.md](EVENTBUS_MIGRATION_GUIDE.md) - Signal architecture
