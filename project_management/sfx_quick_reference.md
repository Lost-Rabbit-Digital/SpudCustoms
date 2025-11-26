# 🎵 Quick SFX Generation Guide - Top 5 Priority

Copy these prompts directly into ElevenLabs Sound Effects generator.

---

## 1️⃣ Office Shutter Lever (CRITICAL - Missing)

```
Mechanical lever pull sound, heavy industrial metal clunk with satisfying click at the end, short 0.5 second duration, clean studio quality
```

**File name:** `office_shutter_lever.wav`  
**Location:** `godot_project/assets/audio/ui_feedback/`

---

## 2️⃣ Megaphone Hover Sound

```
Subtle metallic ping, soft and pleasant, very short 0.2 seconds, like hovering over a small metal object, clean and crisp
```

**File name:** `megaphone_hover.wav`  
**Location:** `godot_project/assets/audio/ui_feedback/`

---

## 3️⃣ Stamp Bar Hover Sound

```
Gentle paper rustle with soft click, very brief 0.15 seconds, office desk sound, warm and inviting
```

**File name:** `stamp_bar_hover.wav`  
**Location:** `godot_project/assets/audio/ui_feedback/`

---

## 4️⃣ Potato Emote - Happy

```
Cheerful little squeak, cartoonish and playful, 0.3 seconds, like a small rubber toy being squeezed, upbeat and positive
```

**File name:** `emote_happy.wav`  
**Location:** `godot_project/assets/audio/ui_feedback/`

---

## 5️⃣ Potato Emote - Angry (Popping Veins)

```
Cartoon steam whistle, short angry puff sound, 0.4 seconds, comedic tension sound, like a pressure valve releasing
```

**File name:** `emote_angry.wav`  
**Location:** `godot_project/assets/audio/ui_feedback/`

---

## 🚀 Quick Workflow

1. Open ElevenLabs Sound Effects
2. Copy prompt → Paste → Generate
3. Download as WAV (44.1kHz, 16-bit)
4. Save to `godot_project/assets/audio/ui_feedback/`
5. Open Godot → Import automatically creates `.import` file
6. Reference in code with `preload("res://assets/audio/ui_feedback/filename.wav")`

---

## 📋 Implementation Locations

**Office Shutter Lever:**
- File: `godot_project/scripts/systems/OfficeShutterController.gd`
- Add AudioStreamPlayer and play on lever click

**Hover Sounds:**
- File: `godot_project/scenes/game_scene/mainGame.gd`
- Connect to megaphone `mouse_entered` signal
- File: `godot_project/scripts/systems/stamp/StampBarController.gd`
- Connect to stamp button `mouse_entered` signals

**Emote Sounds:**
- File: `godot_project/scripts/systems/PotatoPerson.gd`
- Play when `show_emote()` is called

---

**Total Time:** 15-20 minutes to generate and implement these 5 critical sounds!
