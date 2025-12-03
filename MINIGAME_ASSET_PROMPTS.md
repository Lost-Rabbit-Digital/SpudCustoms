# Minigame Asset Generation Prompts

This document contains one-liner prompts for generating missing audio and visual assets for the SpudCustoms minigames using Imagen (images) and ElevenLabs (audio/SFX).

## Overview

The game has **5 minigames**, each with a distinct theme:
1. **Border Chase** - Orange/Industrial (conveyor belt contraband catching)
2. **Code Breaker** - Green/Security (Mastermind-style code guessing)
3. **Document Scanner** - Purple/UV (reveal hidden marks with UV light)
4. **Fingerprint Match** - Blue/Forensic (match fingerprint patterns)
5. **Stamp Sorting** - Gold/Official (sort approved/denied stamps)

---

## AUDIO ASSETS - ElevenLabs Sound Effects Prompts

### Universal Minigame Sounds

#### Success Sounds (play on minigame completion)
```
Triumphant 8-bit chiptune victory jingle, short 1.5 second fanfare, retro arcade style, happy uplifting tone
```

```
Satisfying mechanical cash register "cha-ching" with subtle digital processing, bureaucratic office style
```

```
Short celebratory brass fanfare with typewriter bell ding at end, 1 second, Soviet-era propaganda victory style
```

#### Timeout/Failure Sounds (play when time runs out)
```
Gentle descending synth whomp, non-punishing game over tone, soft buzzer with reverb, 1 second
```

```
Old mechanical clock winding down and stopping, followed by soft disappointed "bwong" tone, 1.5 seconds
```

```
Vintage office intercom buzz followed by sad trombone "wah wah", comedic but not harsh, 2 seconds
```

---

### Border Chase (Orange/Industrial Theme)

#### Conveyor Belt Loop
```
Industrial factory conveyor belt mechanical loop, rhythmic metal rollers and rubber belt movement, steady pace, 4 second seamless loop
```

#### Item Grab (catching contraband)
```
Quick satisfying grab sound with slight suction pop, arcade-style pickup, 0.3 seconds
```

#### Contraband Alert
```
Short urgent radar ping with slight static, security scanner detection beep, industrial warning tone, 0.5 seconds
```

#### Item Miss (contraband escapes)
```
Quick mechanical whoosh past with slight disappointment tone, item sliding away, 0.4 seconds
```

#### Approved Item Pass
```
Soft pleasant chime indicating safe passage, green light approval ding, subtle and non-distracting, 0.3 seconds
```

---

### Code Breaker (Green/Security Theme)

#### Digit Input
```
Retro computer keyboard key press with slight electronic processing, hacker movie terminal input, 0.15 seconds
```

#### Code Submit
```
Electronic processing whir with data transmission beeps, computer analyzing input, 0.8 seconds
```

#### Correct Position (green dot feedback)
```
Positive electronic blip, successful lock tumbler click with digital enhancement, 0.2 seconds
```

#### Wrong Position (yellow dot feedback)
```
Neutral electronic tone, partial match indicator, subtle question mark feeling, 0.2 seconds
```

#### Incorrect Digit (gray dot feedback)
```
Soft electronic negative buzz, gentle rejection beep, not harsh, 0.2 seconds
```

#### Code Cracked (all correct)
```
Electronic lock disengaging with satisfying mechanical click sequence, vault door unlocking sound, triumphant, 1 second
```

---

### Document Scanner (Purple/UV Theme)

#### UV Light Activation
```
Soft electrical hum with slight purple/ultraviolet frequency buzz, fluorescent light turning on, 0.5 seconds
```

#### UV Light Ambient Loop
```
Gentle electronic UV lamp humming loop, subtle electrical buzz with slight oscillation, 3 second seamless loop
```

#### Hidden Element Reveal
```
Magical discovery shimmer with subtle whoosh, secret revealed sparkle sound, mysterious and satisfying, 0.6 seconds
```

#### Element Confirmed (clicked on revealed item)
```
Confirmation beep with stamp-like finality, document annotation sound, official marking, 0.3 seconds
```

#### Scanning Movement
```
Soft paper surface being examined, gentle UV light movement across document, subtle friction, 0.4 seconds
```

---

### Fingerprint Match (Blue/Forensic Theme)

#### Fingerprint Scan
```
Biometric scanner processing sound, laser line sweep with digital analysis beeps, CSI forensic equipment, 0.7 seconds
```

#### Match Correct
```
Positive identification confirmed chime, biometric match success, satisfying lock-in sound, 0.4 seconds
```

#### Match Incorrect
```
Soft rejection buzz, fingerprint mismatch indicator, gentle negative tone without harshness, 0.3 seconds
```

#### Round Complete
```
Case file closing sound with slight paper rustle and stamp, forensic analysis complete, professional, 0.8 seconds
```

#### Fingerprint Hover
```
Subtle digital magnification sound, forensic lens focusing, quiet examination tone, 0.2 seconds
```

---

### Stamp Sorting (Gold/Official Theme)

#### Stamp Grab
```
Paper and rubber stamp pickup sound, light grip with slight paper crinkle, office material handling, 0.2 seconds
```

#### Stamp Drop in Bin
```
Paper landing in wooden/metal tray, satisfying sort completion, light thump with paper settling, 0.3 seconds
```

#### Correct Sort
```
Pleasant official approval chime, bureaucratic success indicator, subtle gold star feeling, 0.3 seconds
```

#### Wrong Sort
```
Soft administrative error buzz, paperwork mistake indicator, gentle enough to not frustrate, 0.3 seconds
```

#### Stamp Falling (ambient during gameplay)
```
Light paper fluttering descent, document falling through air, gentle gravity, 0.6 seconds
```

---

## VISUAL ASSETS - Imagen Prompts

### Document Scanner - Document Textures

#### Official Government Document
```
Aged cream-colored official government document texture, subtle paper grain, faded bureaucratic form with empty fields, stamp marks in corners, Soviet-era aesthetic, top-down flat scan, 300x400 pixels, game asset
```

#### Passport Page Texture
```
Worn passport inner page texture, cream paper with subtle security pattern watermark, faded blue and red accents, official document aesthetic, vintage travel document, flat scan perspective, game asset
```

#### Customs Declaration Form
```
Vintage customs declaration form texture, yellowed paper with typed text fields, official stamps partially visible, border checkpoint aesthetic, aged government paperwork, flat lay photograph style, game asset
```

#### Identification Card Background
```
Retro ID card background texture, laminated paper effect, subtle holographic pattern, government-issued document aesthetic, cream and gray tones, flat scan, game asset
```

---

### Background Textures (Optional Enhancement)

#### Border Chase - Industrial Background
```
Dark industrial control room texture, metal panels with rivets, orange warning stripe accents, conveyor belt facility aesthetic, grungy factory environment, game background asset
```

#### Code Breaker - Digital Security Background
```
Dark computer terminal screen texture, green phosphor CRT monitor aesthetic, subtle scan lines, hacker movie mainframe, retro computing environment, game background asset
```

#### Document Scanner - Investigation Desk Background
```
Wooden detective desk texture with subtle UV lamp glow reflection, forensic investigation aesthetic, dark purple ambient lighting, examination table surface, game background asset
```

#### Fingerprint Match - Forensic Lab Background
```
Clean forensic laboratory surface texture, stainless steel with subtle blue lighting reflection, CSI crime lab aesthetic, clinical examination environment, game background asset
```

#### Stamp Sorting - Bureaucratic Office Background
```
Vintage wooden desk texture with official seal impression, golden brown tones, government office aesthetic, official paperwork processing station, warm lamp lighting, game background asset
```

---

## MUSIC (Optional) - Minigame Background Tracks

### Fast-Paced Minigame Loop (30 seconds)
```
Tense electronic chiptune loop, 120 BPM, urgent but not stressful, puzzle game intensity, synthwave influenced, retro arcade feel, seamless loop
```

### Calm Minigame Loop (30 seconds)
```
Gentle lo-fi electronic ambient loop, 80 BPM, focused concentration music, soft synth pads, mellow puzzle solving atmosphere, seamless loop
```

---

## EXISTING ASSETS THAT CAN BE REUSED

The following existing audio files in the project could be assigned to minigames without generating new assets:

### Success Sounds (already in project)
- `assets/audio/gameplay/combo_activate.mp3` - Good for success
- `assets/audio/gameplay/score_popup.mp3` - Good for success
- `assets/audio/ui_feedback/achievement_unlocked.mp3` - Good for success

### Stamp-Related (for Stamp Sorting)
- `assets/audio/gameplay/stamp_ink_splatter.mp3`
- `assets/audio/gameplay/stamp_ink_spray.mp3`
- `assets/audio/mechanical/stamp_sound_1.mp3` through `stamp_sound_5.mp3`

### Paper Sounds (for Document Scanner)
- `assets/audio/paper/paper_fold_1.mp3` through `paper_fold_6.mp3`

### UI Feedback
- `assets/audio/ui_feedback/tooltip_appear.mp3` - Could work for reveals
- `assets/audio/ui_feedback/ui_hover_button.mp3` - For hover states

### Mechanical Sounds
- `assets/audio/mechanical/lever_pull_01.mp3` - Could work for confirmations

---

## PRIORITY LIST

### High Priority (Essential)
1. Universal success sound (1 needed)
2. Universal timeout sound (1 needed)

### Medium Priority (Enhances gameplay feel)
3. Border Chase: Conveyor belt loop, item grab
4. Code Breaker: Digit input, code cracked
5. Document Scanner: UV light hum, element reveal
6. Fingerprint Match: Scan sound, match correct
7. Stamp Sorting: Grab sound, correct sort

### Low Priority (Polish)
8. Document textures for Document Scanner
9. Background textures for all minigames
10. Background music loops

---

## TECHNICAL SPECIFICATIONS

### Audio Format Requirements
- Format: MP3 or OGG (Godot compatible)
- Sample Rate: 44100 Hz
- Bit Rate: 128-192 kbps
- Channels: Mono (SFX) or Stereo (music)

### Image Format Requirements
- Format: PNG (with transparency if needed)
- Document textures: 300x400 pixels
- Background textures: 800x600 pixels or tileable
- Color depth: 24-bit RGB or 32-bit RGBA

---

## USAGE

After generating assets, place them in:
- Audio: `godot_project/assets/audio/minigames/`
- Images: `godot_project/assets/minigames/textures/`

Then configure the minigame scenes to reference these new assets.
