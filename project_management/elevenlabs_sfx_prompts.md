# ElevenLabs Sound Effects Prompts for Spud Customs

This document contains prompts for generating sound effects using ElevenLabs Sound Effects tool.

## 🎮 Gameplay SFX

### Office Shutter Lever
**Priority: HIGH** - Currently missing SFX

```
Mechanical lever pull sound, heavy industrial metal clunk with satisfying click at the end, short 0.5 second duration, clean studio quality
```

**Alternative prompt:**
```
Old-fashioned office window shutter lever being pulled down, metallic ratchet mechanism engaging with a solid thunk, vintage 1960s office equipment sound
```

---

## 🖱️ UI Interaction SFX

### Hover Sounds

**Megaphone Hover:**
```
Subtle metallic ping, soft and pleasant, very short 0.2 seconds, like hovering over a small metal object, clean and crisp
```

**Stamp Bar Button Hover:**
```
Gentle paper rustle with soft click, very brief 0.15 seconds, office desk sound, warm and inviting
```

**General UI Button Hover:**
```
Soft digital blip, friendly and subtle, 0.1 second duration, modern UI feedback sound, not intrusive
```

### Volume Slider Ticks
```
Soft mechanical tick sound, like a precision dial being adjusted, very short 0.05 seconds, satisfying tactile feedback, clean studio recording
```

---

## 😊 Emote System SFX

### Potato Emote Sounds
**Context:** Small sounds when potatoes display emotion bubbles

**Happy/Excited Emote:**
```
Cheerful little squeak, cartoonish and playful, 0.3 seconds, like a small rubber toy being squeezed, upbeat and positive
```

**Angry/Frustrated Emote (Popping Veins):**
```
Cartoon steam whistle, short angry puff sound, 0.4 seconds, comedic tension sound, like a pressure valve releasing
```

**Confused Emote:**
```
Quirky question mark sound, ascending pitch wobble, 0.3 seconds, playful and innocent, like a cartoon character scratching their head
```

**Exclamation/Alert Emote:**
```
Sharp attention sound, bright metallic ding with quick decay, 0.2 seconds, like a small bell being struck, clear and attention-grabbing
```

---

## 📄 Document Interaction SFX

### Hand Gripping Document
```
Paper grab sound, fingers gripping thick cardstock, quick 0.2 seconds, realistic office paper handling, subtle friction noise
```

**Alternative:**
```
Document pickup sound, hand grasping passport or paper with slight rustle, short and crisp, professional office environment
```

### Document Whoosh (Fast Drag)
```
Paper whooshing through air, quick swipe sound, 0.3 seconds, like flipping through pages quickly, dynamic and energetic
```

### Document Return to Table
```
Paper sliding and settling on wooden desk, soft thud with slight rustle, 0.5 seconds, satisfying placement sound, warm and tactile
```

---

## 🎨 Visual Feedback SFX

### Ink Flecks from Stamping
```
Tiny ink droplets spattering, quick splatter sound, 0.2 seconds, like fountain pen ink flicking, subtle and satisfying
```

**Alternative:**
```
Stamp ink spray, small droplets hitting paper, very brief 0.15 seconds, vintage office stamp sound, clean and crisp
```

### Score Pop-up Text
```
Bright positive chime, ascending pitch, 0.3 seconds, like coins being collected, rewarding and cheerful
```

### Combo Multiplier Activation
```
Energetic power-up sound, rising electronic tone with sparkle, 0.6 seconds, exciting and motivating, arcade game style
```

---

## 🚀 Missile System SFX (Enhancements)

### Missile Launch (If needed)
```
Compressed air launch, quick whoosh with mechanical release, 0.4 seconds, like a pneumatic tube system, powerful but not overwhelming
```

### Perfect Hit Bonus
```
Triumphant success chime, bright and celebratory, 0.5 seconds, like achieving a perfect score, rewarding and satisfying
```

---

## 🎯 Queue Interaction SFX

### Potato Wiggle (Click)
```
Soft squish sound, gentle and playful, 0.2 seconds, like poking a soft object, cute and non-intrusive
```

### Potato Tooltip Appear
```
Gentle pop-in sound, soft bubble appearance, 0.15 seconds, friendly UI feedback, subtle and pleasant
```

---

## 🏆 Achievement/Feedback SFX

### Citation Added (Forgiving Feedback)
```
Official stamp sound, authoritative but not harsh, 0.4 seconds, like receiving a warning ticket, professional office tone
```

### Strike Removed (Positive)
```
Eraser rubbing on paper, mistake being corrected, 0.5 seconds, satisfying removal sound, hopeful and relieving
```

---

## 🎵 Ambient Office SFX (Optional)

### Office Background Ambience
```
Distant office sounds, muffled typing and paper shuffling, subtle background loop, 10 seconds, creates atmosphere without distraction
```

### Border Wall Room Lights Toggle
```
Electrical switch flip, fluorescent light buzz starting up, 0.8 seconds, institutional building sound, realistic and atmospheric
```

---

## 📋 Usage Instructions

1. **Copy the prompt** for the desired sound effect
2. **Paste into ElevenLabs Sound Effects** generator
3. **Generate** and preview the sound
4. **Adjust duration** if needed (most prompts specify target duration)
5. **Download** as WAV or MP3
6. **Import to Godot** at `godot_project/assets/audio/ui_feedback/` or appropriate subfolder
7. **Create .import file** by importing in Godot editor
8. **Reference in code** using `preload()` or AudioStreamPlayer

---

## 🎨 Sound Design Notes

**Tone:** The game has a dystopian but slightly comedic tone (Papers Please meets potato people). Sounds should be:
- Professional and office-like for official actions (stamps, documents)
- Playful and cartoonish for potato interactions (emotes, wiggles)
- Satisfying and tactile for UI feedback (clicks, hovers)
- Retro/vintage for the 1960s-inspired setting (mechanical sounds)

**Volume:** All SFX should be normalized and balanced. UI sounds should be subtle, gameplay sounds more prominent.

**Format:** Export as WAV 44.1kHz 16-bit for best quality in Godot.

---

## ✅ Priority Order

1. **Office Shutter Lever** - Currently missing, blocks polish
2. **Hover Sounds** (Megaphone, Stamp Bar) - Improves UI feedback
3. **Emote Sounds** - Adds personality to potatoes
4. **Document Interaction** - Enhances drag-and-drop feel
5. **Volume Slider Ticks** - Nice-to-have polish
6. **Combo Multiplier** - Feature-dependent (if implemented)

---

**Total Sounds Needed:** ~20 unique SFX
**Estimated Generation Time:** 30-45 minutes
**Implementation Time:** 1-2 hours (import + wire up in code)
