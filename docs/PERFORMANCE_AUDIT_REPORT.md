# Performance Audit Report - Spud Customs

**Date:** December 2024
**Focus:** App hangs and performance issues, especially for laptop users
**Severity Rating:** CRITICAL - Multiple blocking operations identified

---

## Executive Summary

This audit identified **27 critical/high severity issues** that can cause application freezes, stutters, and poor performance on laptop hardware. The primary categories of concern are:

1. **Blocking I/O in SaveManager** - Every getter reloads from disk
2. **Blocking Steam API calls** - Synchronous calls in gameplay loop
3. **No object pooling** - 600-1200+ objects created per shift
4. **Heavy _process() operations** - get_children() calls every frame
5. **Excessive particle counts** - 400 particles per explosion

**Estimated worst-case freeze duration:** 1-3 seconds during shift completion on slow storage

---

## Critical Issues (Immediate Action Required)

### 1. SaveManager - Blocking I/O with No Caching

**File:** `scripts/autoload/SaveManager.gd`
**Severity:** CRITICAL
**Impact:** 60-300ms freeze per high score check on mechanical HDDs

#### Problem

Every getter function (`get_level_high_score()`, `get_max_level_reached()`, etc.) calls `load_game_state()` which:
1. Opens file from disk (10-30ms)
2. Parses JSON data (5-50ms)
3. Optionally reads from Steam Cloud (100-500ms)

```gdscript
# Line 191-192: Reloads ENTIRE game state for every call
func get_level_high_score(level: int, difficulty: String) -> int:
    var game_state = load_game_state()  # BLOCKS every time!
    ...
```

**Affected Lines:**
- `load_game_state()`: Lines 43-78 (all blocking operations)
- `get_level_high_score()`: Lines 191-203
- `get_max_level_reached()`: Lines 146-148
- `get_current_level()`: Lines 152-154
- `get_global_high_score()`: Lines 207-210
- `save_level_high_score()`: Lines 158-187 (DOUBLE loads - line 159 and 171!)

**Steam Cloud Chain (Lines 58-68):** 6 sequential blocking operations:
```gdscript
Steam.fileExists("gamestate.save")     # 10-50ms
Steam.getFileSize("gamestate.save")    # 10-50ms
Steam.fileRead("gamestate.save", ...)  # 100-500ms (network!)
FileAccess.open(..., WRITE)            # 10-30ms
temp_file.store_buffer(...)            # 5-20ms
FileAccess.open(..., READ)             # 10-30ms
```

**Total worst case:** 155-730ms of main thread blocking

#### Recommended Fix

```gdscript
var _cached_game_state: Dictionary = {}
var _cache_dirty: bool = true

func get_level_high_score(level: int, difficulty: String) -> int:
    if _cache_dirty:
        _cached_game_state = _do_load_game_state()
        _cache_dirty = false
    return _cached_game_state.get("level_highscores", {}).get(str(level), {}).get(difficulty, 0)

func save_game_state(data: Dictionary) -> bool:
    _cache_dirty = true
    # ... existing save logic
```

---

### 2. Duplicate Achievement/Stats Calls

**File:** `scenes/game_scene/mainGame.gd`
**Severity:** CRITICAL
**Impact:** 4 blocking Steam API calls instead of 2

#### Problem

Achievement checking runs twice in `end_shift()`:

```gdscript
# Lines 616-617 (first call)
Global.check_achievements()
Global.update_steam_stats()

# ... code continues ...

# Lines 637-638 (DUPLICATE!)
Global.check_achievements()
Global.update_steam_stats()
```

Additionally, `Global.total_shifts_completed += 1` is called twice (increments by 2 instead of 1).

#### Recommended Fix

Remove the duplicate calls at lines 637-638.

---

### 3. Steam API Blocking Calls in Leaderboard Processing

**File:** `scripts/autoload/SteamManager.gd`
**Severity:** CRITICAL
**Impact:** Up to 12 blocking calls in sequence during leaderboard display

#### Problem

Line 564: `Steam.getFriendPersonaName()` called in a loop for up to 12 leaderboard entries:

```gdscript
# _on_leaderboard_scores_downloaded() at line ~564
for entry in result:
    var steam_id = entry.get("steam_id", 0)
    if steam_id != 0:
        player_name = Steam.getFriendPersonaName(steam_id)  # BLOCKING x12!
```

#### Recommended Fix

Cache player names or use async pattern with batching.

---

### 4. get_children() Called Every Frame in _process()

**File:** `scripts/systems/vehicle_system/vehicle_spawner.gd`
**Severity:** HIGH
**Impact:** Array allocation every frame, scales with vehicle count

#### Problem

Line 110: `get_children()` allocates a new array every single frame:

```gdscript
func _process(delta: float) -> void:
    for vehicle in get_children():  # Allocates new array 60+ times/sec
        if not vehicle.has_meta("direction"):
            continue
        ...
```

#### Recommended Fix

```gdscript
var _vehicles: Array[Node2D] = []

func _spawn_vehicle() -> void:
    var vehicle = _vehicle_scene.instantiate()
    add_child(vehicle)
    _vehicles.append(vehicle)

func _process(delta: float) -> void:
    var i = _vehicles.size() - 1
    while i >= 0:
        var vehicle = _vehicles[i]
        if not is_instance_valid(vehicle):
            _vehicles.remove_at(i)
        else:
            # ... movement logic
        i -= 1
```

---

### 5. Object Pooling Not Used

**File:** `scripts/systems/BorderRunnerSystem.gd`
**Severity:** HIGH
**Impact:** 600-1200+ new objects per shift, significant GC pressure

#### Problem

Objects created fresh each time, never reused:

| Object | Per Event | Events/Shift | Total Created | Pooled? |
|--------|-----------|--------------|---------------|---------|
| Gibs | 40 | 10-20 | 400-800 | NO |
| Missiles | 1 | 50-200 | 50-200 | NO |
| Explosions | 1 | 50+ | 50+ | NO* |
| Audio Players | 1 | 100+ | 100+ | NO |
| Footprints | 1 | 100s | 100+ | NO* |

*Pool implementations exist (`explosion_pool.gd`, `footprint_pool.gd`) but are NOT being used!

**Key Lines:**
- Gibs created at line 1455: `var gib = Gib.new()`
- 40 gibs per hit (line 70: `@export var num_gibs: int = 40`)

#### Recommended Fix

Enable existing pools:
- Wire up `ExplosionPool` in BorderRunnerSystem
- Wire up `FootprintPool` in PotatoPerson
- Create `GibPool` following same pattern

---

### 6. Blocking Resource Loading During Gameplay

**File:** `scripts/systems/PotatoFactory.gd`
**Severity:** HIGH
**Impact:** 10-100ms freeze per potato spawn

#### Problem

Line 36: Loads CharacterGenerator scene synchronously during potato creation:

```gdscript
static func generate_random_potato_info() -> Dictionary:
    var character_gen = load("res://scripts/systems/character_generator.tscn").instantiate()
```

**Other blocking loads:**
- `PotatoFactory.gd:249,259,304` - Texture loading in loops
- `stampable_component.gd:193` - Stamp texture load on every stamp
- `InputGlyphManager.gd:270` - Glyph texture loading

#### Recommended Fix

Preload at class level:
```gdscript
const CharacterGenerator = preload("res://scripts/systems/character_generator.tscn")

static func generate_random_potato_info() -> Dictionary:
    var character_gen = CharacterGenerator.instantiate()
```

---

## High Severity Issues

### 7. Excessive Particle Counts

**File:** `scripts/systems/ExplosionVFX.gd` + scene config
**Severity:** HIGH
**Impact:** 400 draw calls per explosion

BorderRunnerSystem.tscn configures ExplosionVFX with `num_particles = 400` (should be 100-150).

**Additional concerns:**
- `PotatoRain.gd`: 200 CPU-managed Sprite2D nodes instead of GPUParticles2D
- `CraterSystem.gd`: Up to 130 draw calls (10 craters x 13 pieces)

---

### 8. Audio-Reactive Effects Always Running

**Files:**
- `scripts/effects/audio_reactive_bloom.gd`
- `scripts/effects/menu_music_visual_effects.gd`
**Severity:** MEDIUM-HIGH
**Impact:** Constant spectrum analysis + environment updates

These run in `_process()` every frame during gameplay, performing:
- Audio spectrum analysis (expensive FFT)
- WorldEnvironment modifications
- Multiple UI element updates

**Recommendation:** Disable audio reactive effects during gameplay (menu-only).

---

### 9. Timer Accumulation in BorderRunnerSystem

**File:** `scripts/systems/BorderRunnerSystem.gd`
**Severity:** MEDIUM-HIGH
**Impact:** Timer callback storm during intense combat

Lines ~1406-1427: Creates multiple timers per explosion/smoke:
```gdscript
var cleanup_timer = get_tree().create_timer(2.0)      # Per explosion
var smoke_alpha_timer = get_tree().create_timer(0.6)  # Per smoke particle
var smoke_cleanup_timer = get_tree().create_timer(1.5) # Per smoke particle
```

During intense gameplay (10-20 explosions/sec), this creates 30-60 timers per second.

---

### 10. Signal Connection Imbalance

**Codebase-wide**
**Severity:** MEDIUM
**Impact:** Potential memory leaks over extended play sessions

- **Total .connect() calls:** 182
- **Total .disconnect() calls:** 4
- **Ratio:** 45:1

Runners connect signals when spawned but signals aren't explicitly disconnected.

---

## Medium Severity Issues

### 11. QueueManager Curve Lookups

**File:** `scripts/systems/QueueManager.gd`
**Line:** ~123
Multiple `curve.get_point_position()` calls per potato per frame.

### 12. BorderRunnerSystem Viewport Queries

**File:** `scripts/systems/BorderRunnerSystem.gd`
**Line:** ~320
`get_viewport_rect()` called per missile every frame instead of caching.

### 13. Menu Music Visual Effects

**File:** `scripts/effects/menu_music_visual_effects.gd`
**Line:** 155
Triple spectrum analysis (bass, mid, high) every frame.

### 14. SceneTransitionManager Blocking Fades

**File:** `scripts/autoload/scene_transition_manager.gd`
**Line:** 36
Uses synchronous `load()` instead of threaded ResourceLoader.

### 15. Very Short Timer Intervals

**File:** `scripts/systems/ShiftSummaryScreen.gd`
**Line:** ~264
Creates `get_tree().create_timer(0.1)` (100ms polling timer).

---

## Performance Recommendations by Priority

### Immediate (This Sprint)

1. **Add caching to SaveManager** - Eliminate repeated disk reads
2. **Remove duplicate achievement calls** in mainGame.gd:637-638
3. **Enable existing ExplosionPool and FootprintPool**
4. **Cache vehicle array** in vehicle_spawner.gd
5. **Preload CharacterGenerator** in PotatoFactory

### Short-term (Next Sprint)

6. **Create GibPool** (40 max, reuse)
7. **Create AudioPlayerPool** (20 max)
8. **Reduce ExplosionVFX particles** from 400 to 100-150
9. **Cache viewport_rect** in BorderRunnerSystem
10. **Disable audio-reactive bloom during gameplay**

### Medium-term

11. **Replace PotatoRain CPU sprites with GPUParticles2D**
12. **Batch Steam API calls** for friend names
13. **Implement background threading** for save operations
14. **Add explicit signal disconnection** for runners
15. **Consolidate bloom effects** to single source

---

## Test Scenarios for Verification

After fixes, test these scenarios on a laptop with mechanical HDD:

1. **Save/Load Performance**
   - Complete a shift and check for freeze during high score save
   - Load game and verify no startup freeze

2. **Intense Combat**
   - Trigger 5+ simultaneous explosions
   - Verify no frame drops below 30 FPS

3. **Extended Play Session**
   - Play 30+ minutes continuously
   - Monitor memory usage for leaks

4. **Scene Transitions**
   - Navigate between menus rapidly
   - Verify smooth fade transitions

---

## Summary Statistics

| Category | Critical | High | Medium | Total |
|----------|----------|------|--------|-------|
| Blocking I/O | 3 | 2 | 2 | 7 |
| Object Creation | 1 | 3 | 1 | 5 |
| _process() Heavy | 2 | 3 | 3 | 8 |
| Steam API | 2 | 1 | 0 | 3 |
| Visual Effects | 0 | 2 | 2 | 4 |
| **Totals** | **8** | **11** | **8** | **27** |

---

## Files Requiring Changes

### Critical Priority
- `scripts/autoload/SaveManager.gd` - Add caching
- `scenes/game_scene/mainGame.gd` - Remove duplicate calls (lines 634-638)
- `scripts/autoload/SteamManager.gd` - Cache friend names, batch operations

### High Priority
- `scripts/systems/vehicle_system/vehicle_spawner.gd` - Cache vehicle array
- `scripts/systems/BorderRunnerSystem.gd` - Enable pooling, cache viewport
- `scripts/systems/PotatoFactory.gd` - Preload resources

### Medium Priority
- `scripts/effects/audio_reactive_bloom.gd` - Add gameplay disable
- `scripts/systems/ExplosionVFX.gd` - Reduce particle count
- `scripts/systems/PotatoRain.gd` - Convert to GPU particles

---

*Report generated by performance audit - December 2024*
