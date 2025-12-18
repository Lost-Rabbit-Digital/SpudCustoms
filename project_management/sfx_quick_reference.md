# 🎵 SFX Reference Guide

This document tracks audio assets for game feedback sounds.

---

## ✅ Available Sounds (Already Exist)

### Office Shutter Lever
**Status:** ✅ EXISTS
**Location:** `godot_project/assets/audio/mechanical/`
**Files:**
- `lever big 1.wav`
- `lever big 2.wav`
- `lever big 3.wav`

**Implementation:**
- File: `godot_project/scripts/systems/OfficeShutterController.gd`
- Add AudioStreamPlayer and play on lever click

---

### Stamp Bar Slide Sound
**Status:** ✅ EXISTS
**Location:** `godot_project/assets/audio/gameplay/stamp_bar_slide.mp3`

**Implementation:**
- File: `godot_project/scripts/systems/stamp/StampBarController.gd`
- Play when stamp bar opens/closes

---

### Potato Emote - Happy
**Status:** ✅ EXISTS
**Location:** `godot_project/assets/audio/emotes/emote_happy.mp3`

**Implementation:**
- File: `godot_project/scripts/systems/PotatoPerson.gd`
- Play when `show_emote()` is called with happy state

---

### Potato Emote - Angry
**Status:** ✅ EXISTS
**Location:** `godot_project/assets/audio/emotes/emote_angry.mp3`

**Implementation:**
- File: `godot_project/scripts/systems/PotatoPerson.gd`
- Play when `show_emote()` is called with angry state

---

### UI Hover Button
**Status:** ✅ EXISTS
**Location:** `godot_project/assets/audio/ui_feedback/ui_hover_button.mp3`

**Implementation:**
- Can be used for megaphone hover and other UI elements

---

## ⚠️ Sounds Needing Implementation

The sounds above exist but may not be wired up in the code yet. Here's what needs to be connected:

### 1. Office Shutter Lever Sound
```gdscript
# In OfficeShutterController.gd
var lever_sounds = [
    preload("res://assets/audio/mechanical/lever big 1.wav"),
    preload("res://assets/audio/mechanical/lever big 2.wav"),
    preload("res://assets/audio/mechanical/lever big 3.wav"),
]

func _on_lever_pulled():
    $AudioStreamPlayer.stream = lever_sounds.pick_random()
    $AudioStreamPlayer.play()
```

### 2. Potato Emote Sounds
```gdscript
# In PotatoPerson.gd
var emote_happy_sound = preload("res://assets/audio/emotes/emote_happy.mp3")
var emote_angry_sound = preload("res://assets/audio/emotes/emote_angry.mp3")

func show_emote(emote_type: String):
    match emote_type:
        "happy":
            $EmoteSFX.stream = emote_happy_sound
            $EmoteSFX.play()
        "angry":
            $EmoteSFX.stream = emote_angry_sound
            $EmoteSFX.play()
```

### 3. Megaphone Hover Sound
```gdscript
# In mainGame.gd or megaphone controller
var hover_sound = preload("res://assets/audio/ui_feedback/ui_hover_button.mp3")

func _on_megaphone_mouse_entered():
    $HoverSFX.stream = hover_sound
    $HoverSFX.play()
```

---

## 📁 Audio Directory Structure

```
assets/audio/
├── emotes/
│   ├── emote_alert.mp3
│   ├── emote_angry.mp3
│   ├── emote_confused.mp3
│   └── emote_happy.mp3
├── gameplay/
│   └── stamp_bar_slide.mp3
├── mechanical/
│   ├── lever big 1.wav
│   ├── lever big 2.wav
│   └── lever big 3.wav
├── minigames/
│   └── fingerprint_match_hover.mp3
└── ui_feedback/
    ├── ui_hover_button.mp3
    ├── accept_green_alert.wav
    ├── decline_red_alert.wav
    └── achievement_unlocked.mp3
```

---

## 🎯 Implementation Priority

1. **High:** Connect lever sounds to OfficeShutterController
2. **High:** Connect emote sounds to PotatoPerson
3. **Medium:** Add hover sounds to megaphone and stamp bar
4. **Low:** Consider adding more emote variations

---

**Note:** Prefer `.mp3` format for new sounds (smaller file size, good quality).
