# 🎵 SFX Reference Guide

This document tracks audio assets for game feedback sounds.

**Status:** All core sounds are implemented and connected! ✅

---

## ✅ Implemented Sounds

### Office Shutter Lever
**Status:** ✅ CONNECTED
**Location:** `godot_project/assets/audio/mechanical/`
**Files:**
- `lever big 1.wav`
- `lever big 2.wav`
- `lever big 3.wav`

**Implementation:** `scripts/systems/office_shutter/office_shutter_controller.gd` (lines 180-195)
- Plays random lever sound with pitch variation on lever pull

---

### Stamp Bar Slide Sound
**Status:** ✅ CONNECTED
**Location:** `godot_project/assets/audio/gameplay/stamp_bar_slide.mp3`

**Implementation:** `scripts/systems/stamp/StampBarController.gd` (line 231)
- Plays when stamp bar opens/closes

---

### Stamp Bar Hover Sound
**Status:** ✅ CONNECTED
**Location:** `godot_project/assets/audio/ui_feedback/ui_hover_stamp_bar.mp3`

**Implementation:** `scripts/systems/stamp/StampBarController.gd` (lines 489-508)
- Plays when hovering over stamp bar toggle button

---

### Megaphone Hover Sound
**Status:** ✅ CONNECTED
**Location:** `godot_project/assets/audio/ui_feedback/ui_hover_megaphone.mp3`

**Implementation:** `scenes/game_scene/mainGame.gd` (lines 1245-1250)
- Plays when hovering over megaphone button

---

### Potato Emote Sounds
**Status:** ✅ CONNECTED
**Location:** `godot_project/assets/audio/emotes/`
**Files:**
- `emote_happy.mp3` - Happy face, hearts
- `emote_angry.mp3` - Angry face, popping vein
- `emote_confused.mp3` - Question mark, confusion
- `emote_alert.mp3` - Exclamation marks

**Implementation:** `scripts/systems/potato_emotes/potato_emote_system.gd` (lines 262-293)
- Automatically plays appropriate sound based on emote type
- Includes pitch variation for natural feel

---

### Potato Wiggle Sound
**Status:** ✅ CONNECTED
**Location:** `godot_project/assets/audio/gameplay/potato_wiggle.mp3`

**Implementation:** `scripts/systems/potato_emotes/potato_emote_system.gd` (lines 371-378)
- Plays during potato wiggle animations

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
│   ├── stamp_bar_slide.mp3
│   └── potato_wiggle.mp3
├── mechanical/
│   ├── lever big 1.wav
│   ├── lever big 2.wav
│   └── lever big 3.wav
└── ui_feedback/
    ├── ui_hover_button.mp3
    ├── ui_hover_megaphone.mp3
    ├── ui_hover_stamp_bar.mp3
    ├── accept_green_alert.wav
    ├── decline_red_alert.wav
    └── achievement_unlocked.mp3
```

---

## 🎯 Future Enhancements (Optional)

1. **Low:** Add more emote sound variations
2. **Low:** Add stamp impact sound variations
3. **Low:** Add ambient office sounds

---

**Note:** Prefer `.mp3` format for new sounds (smaller file size, good quality).
