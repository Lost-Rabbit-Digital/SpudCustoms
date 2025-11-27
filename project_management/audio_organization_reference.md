# Audio File Organization - Complete Reference

## ✅ Files Successfully Organized

All 28 new SFX files have been moved to appropriate subdirectories!

## 📁 Directory Structure

### `assets/audio/emotes/` (4 files)
- `emote_alert.mp3` - Exclamation/alert emote sound
- `emote_angry.mp3` - Angry/frustrated emote (popping veins)
- `emote_confused.mp3` - Confused emote (question mark)
- `emote_happy.mp3` - Happy/excited emote sound

### `assets/audio/document_sfx/` (4 files)
- `document_blocked.mp3` - Can't drop document here
- `document_grab.mp3` - Hand gripping document
- `document_return.mp3` - Document returning to table
- `document_whoosh.mp3` - Fast document drag

### `assets/audio/gameplay/` (11 files)
- `citation_added.mp3` - Strike/citation added (forgiving feedback)
- `combo_activate.mp3` - Combo multiplier activation
- `missile_launch.mp3` - Missile launch sound
- `missile_perfect_hit.mp3` - Perfect hit bonus
- `potato_queue_enter.mp3` - Potato entering queue
- `potato_wiggle.mp3` - Potato wiggle/click
- `runner_escaped.mp3` - Runner escaped (negative feedback)
- `score_popup.mp3` - Score pop-up text
- `stamp_ink_splatter.mp3` - Ink flecks from stamping
- `stamp_ink_spray.mp3` - Stamp ink spray
- `strike_removed.mp3` - Strike removed (positive)

### `assets/audio/ui_feedback/` (7 new files)
- `achievement_unlocked.mp3` - Achievement unlocked fanfare
- `high_score_achieved.mp3` - High score celebration
- `tooltip_appear.mp3` - Tooltip pop-in
- `ui_hover_button.mp3` - General button hover
- `ui_hover_megaphone.mp3` - Megaphone hover
- `ui_hover_stamp_bar.mp3` - Stamp bar button hover
- `ui_slider_tick.mp3` - Volume slider ticks

### `assets/audio/ambient/` (3 new files)
- `ambient_clock_tick_loop.mp3` - Clock ticking (pressure/tension)
- `ambient_office_loop.mp3` - Office background ambience
- `lights_toggle.mp3` - Border wall room lights toggle

## 🔧 Implementation Guide

### Where to Use These Sounds

#### Emote System
**File:** `scripts/systems/emote_system.gd` or `scripts/entities/PotatoPerson.gd`

```gdscript
# Preload emote sounds
var emote_sounds = {
	"happy": preload("res://assets/audio/emotes/emote_happy.mp3"),
	"angry": preload("res://assets/audio/emotes/emote_angry.mp3"),
	"confused": preload("res://assets/audio/emotes/emote_confused.mp3"),
	"alert": preload("res://assets/audio/emotes/emote_alert.mp3")
}

func play_emote_sound(emote_type: String):
	if emote_sounds.has(emote_type):
		var player = AudioStreamPlayer.new()
		player.stream = emote_sounds[emote_type]
		player.bus = "SFX"
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)
```

#### Document Drag & Drop
**File:** `scripts/systems/drag_and_drop/drag_and_drop_manager.gd`

```gdscript
# Preload document sounds
var document_grab_sound = preload("res://assets/audio/document_sfx/document_grab.mp3")
var document_whoosh_sound = preload("res://assets/audio/document_sfx/document_whoosh.mp3")
var document_return_sound = preload("res://assets/audio/document_sfx/document_return.mp3")
var document_blocked_sound = preload("res://assets/audio/document_sfx/document_blocked.mp3")

func _on_document_grabbed():
	play_sound(document_grab_sound)

func _on_document_dragging():
	# Play whoosh during fast movement
	if drag_velocity > threshold:
		play_sound(document_whoosh_sound)

func _on_document_dropped(valid: bool):
	if valid:
		play_sound(document_return_sound)
	else:
		play_sound(document_blocked_sound)
```

#### UI Hover Sounds
**Files:** Various UI scripts in `scenes/menus/` and `scripts/ui/`

```gdscript
# In button scripts
@onready var hover_sound = preload("res://assets/audio/ui_feedback/ui_hover_button.mp3")

func _on_mouse_entered():
	var player = AudioStreamPlayer.new()
	player.stream = hover_sound
	player.bus = "SFX"
	player.volume_db = -10  # Subtle
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
```

#### Scoring System
**File:** `scripts/systems/scoring_system.gd` or via EventBus

```gdscript
var score_popup_sound = preload("res://assets/audio/gameplay/score_popup.mp3")
var combo_activate_sound = preload("res://assets/audio/gameplay/combo_activate.mp3")

func _on_score_added(points: int):
	play_sound(score_popup_sound)

func _on_combo_activated(multiplier: int):
	play_sound(combo_activate_sound)
```

#### Strike System
**File:** Via EventBus listeners

```gdscript
var citation_added_sound = preload("res://assets/audio/gameplay/citation_added.mp3")
var strike_removed_sound = preload("res://assets/audio/gameplay/strike_removed.mp3")

func _ready():
	EventBus.strike_changed.connect(_on_strike_changed)
	EventBus.strike_removed.connect(_on_strike_removed)

func _on_strike_changed(current: int, max_val: int, delta: int):
	if delta > 0:  # Strike added
		play_sound(citation_added_sound)

func _on_strike_removed(current: int, max_val: int):
	play_sound(strike_removed_sound)
```

#### Border Runner System
**File:** `scripts/systems/BorderRunnerSystem.gd`

```gdscript
var missile_launch_sound = preload("res://assets/audio/gameplay/missile_launch.mp3")
var missile_perfect_hit_sound = preload("res://assets/audio/gameplay/missile_perfect_hit.mp3")
var runner_escaped_sound = preload("res://assets/audio/gameplay/runner_escaped.mp3")

func launch_missile():
	play_sound(missile_launch_sound)

func _on_perfect_hit():
	play_sound(missile_perfect_hit_sound)

func _on_runner_escaped():
	play_sound(runner_escaped_sound)
```

#### Queue System
**File:** `scripts/systems/QueueManager.gd`

```gdscript
var potato_queue_enter_sound = preload("res://assets/audio/gameplay/potato_queue_enter.mp3")
var potato_wiggle_sound = preload("res://assets/audio/gameplay/potato_wiggle.mp3")

func add_potato_to_queue(potato):
	play_sound(potato_queue_enter_sound)

func _on_potato_clicked(potato):
	play_sound(potato_wiggle_sound)
```

#### Achievements
**File:** Via EventBus or achievement system

```gdscript
var achievement_sound = preload("res://assets/audio/ui_feedback/achievement_unlocked.mp3")
var high_score_sound = preload("res://assets/audio/ui_feedback/high_score_achieved.mp3")

func _ready():
	EventBus.achievement_unlocked.connect(_on_achievement)
	EventBus.high_score_achieved.connect(_on_high_score)

func _on_achievement(achievement_id: String):
	play_sound(achievement_sound)

func _on_high_score(difficulty: String, score: int, shift: int):
	play_sound(high_score_sound)
```

#### Ambient Sounds
**File:** `scripts/systems/ambient_audio_manager.gd` (if exists) or main game scene

```gdscript
var office_ambience = preload("res://assets/audio/ambient/ambient_office_loop.mp3")
var clock_tick = preload("res://assets/audio/ambient/ambient_clock_tick_loop.mp3")
var lights_toggle = preload("res://assets/audio/ambient/lights_toggle.mp3")

@onready var ambience_player = $AmbiencePlayer

func _ready():
	# Play office ambience loop
	ambience_player.stream = office_ambience
	ambience_player.bus = "Ambient"
	ambience_player.volume_db = -15
	ambience_player.play()

func toggle_lights():
	play_sound(lights_toggle)
```

## 🎮 Next Steps

1. **Open Godot** - Let it reimport all moved files
2. **Check Console** - Verify no "file not found" errors
3. **Implement Sounds** - Add preload statements to appropriate scripts
4. **Test In-Game** - Verify each sound plays correctly
5. **Adjust Volumes** - Balance SFX levels (UI should be subtle, gameplay more prominent)

## 📊 Sound Design Guidelines

**Volume Levels (suggested):**
- UI Hover: -15 to -10 dB (very subtle)
- Tooltips: -12 to -8 dB (subtle)
- Document Sounds: -8 to -5 dB (moderate)
- Emotes: -8 to -5 dB (moderate, characterful)
- Gameplay (score, combo): -5 to 0 dB (prominent)
- Achievements: 0 to +3 dB (celebratory, loud)
- Ambient: -20 to -15 dB (background)

**Audio Bus Routing:**
- UI sounds → "SFX" bus
- Gameplay sounds → "SFX" bus
- Emotes → "SFX" bus
- Ambient → "Ambient" or "Music" bus
- Achievements → "SFX" bus (or dedicated "Achievements" bus)

## ✅ Completion Checklist

- [x] Created `emotes/` directory
- [x] Created `document_sfx/` directory
- [x] Created `gameplay/` directory
- [x] Moved 4 emote sounds
- [x] Moved 4 document sounds
- [x] Moved 11 gameplay sounds
- [x] Moved 7 UI feedback sounds
- [x] Moved 3 ambient sounds
- [ ] Implement sounds in code
- [ ] Test all sounds in-game
- [ ] Adjust volume levels
- [ ] Update SFX quick reference document

All files are now properly organized and ready to be implemented! 🎉
