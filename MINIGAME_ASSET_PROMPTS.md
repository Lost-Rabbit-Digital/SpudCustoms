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
**Suggested filename:** `minigame_success_chiptune.mp3`

```
Satisfying mechanical cash register "cha-ching" with subtle digital processing, bureaucratic office style
```
**Suggested filename:** `minigame_success_cashregister.mp3`

```
Short celebratory brass fanfare with typewriter bell ding at end, 1 second, Soviet-era propaganda victory style
```
**Suggested filename:** `minigame_success_fanfare.mp3`

#### Timeout/Failure Sounds (play when time runs out)
```
Gentle descending synth whomp, non-punishing game over tone, soft buzzer with reverb, 1 second
```
**Suggested filename:** `minigame_timeout_whomp.mp3`

```
Old mechanical clock winding down and stopping, followed by soft disappointed "bwong" tone, 1.5 seconds
```
**Suggested filename:** `minigame_timeout_clock.mp3`

```
Vintage office intercom buzz followed by sad trombone "wah wah", comedic but not harsh, 2 seconds
```
**Suggested filename:** `minigame_timeout_trombone.mp3`

---

### Border Chase (Orange/Industrial Theme)

#### Conveyor Belt Loop
```
Industrial factory conveyor belt mechanical loop, rhythmic metal rollers and rubber belt movement, steady pace, 4 second seamless loop
```
**Suggested filename:** `border_chase_conveyor_loop.mp3`

#### Item Grab (catching contraband)
```
Quick satisfying grab sound with slight suction pop, arcade-style pickup, 0.3 seconds
```
**Suggested filename:** `border_chase_item_grab.mp3`

#### Contraband Alert
```
Short urgent radar ping with slight static, security scanner detection beep, industrial warning tone, 0.5 seconds
```
**Suggested filename:** `border_chase_contraband_alert.mp3`

#### Item Miss (contraband escapes)
```
Quick mechanical whoosh past with slight disappointment tone, item sliding away, 0.4 seconds
```
**Suggested filename:** `border_chase_item_miss.mp3`

#### Approved Item Pass
```
Soft pleasant chime indicating safe passage, green light approval ding, subtle and non-distracting, 0.3 seconds
```
**Suggested filename:** `border_chase_item_pass.mp3`

---

### Code Breaker (Green/Security Theme)

#### Digit Input
```
Retro computer keyboard key press with slight electronic processing, hacker movie terminal input, 0.15 seconds
```
**Suggested filename:** `code_breaker_digit_input.mp3`

#### Code Submit
```
Electronic processing whir with data transmission beeps, computer analyzing input, 0.8 seconds
```
**Suggested filename:** `code_breaker_submit.mp3`

#### Correct Position (green dot feedback)
```
Positive electronic blip, successful lock tumbler click with digital enhancement, 0.2 seconds
```
**Suggested filename:** `code_breaker_correct_position.mp3`

#### Wrong Position (yellow dot feedback)
```
Neutral electronic tone, partial match indicator, subtle question mark feeling, 0.2 seconds
```
**Suggested filename:** `code_breaker_wrong_position.mp3`

#### Incorrect Digit (gray dot feedback)
```
Soft electronic negative buzz, gentle rejection beep, not harsh, 0.2 seconds
```
**Suggested filename:** `code_breaker_incorrect_digit.mp3`

#### Code Cracked (all correct)
```
Electronic lock disengaging with satisfying mechanical click sequence, vault door unlocking sound, triumphant, 1 second
```
**Suggested filename:** `code_breaker_cracked.mp3`

---

### Document Scanner (Purple/UV Theme)

#### UV Light Activation
```
Soft electrical hum with slight purple/ultraviolet frequency buzz, fluorescent light turning on, 0.5 seconds
```
**Suggested filename:** `document_scanner_uv_activate.mp3`

#### UV Light Ambient Loop
```
Gentle electronic UV lamp humming loop, subtle electrical buzz with slight oscillation, 3 second seamless loop
```
**Suggested filename:** `document_scanner_uv_loop.mp3`

#### Hidden Element Reveal
```
Magical discovery shimmer with subtle whoosh, secret revealed sparkle sound, mysterious and satisfying, 0.6 seconds
```
**Suggested filename:** `document_scanner_reveal.mp3`

#### Element Confirmed (clicked on revealed item)
```
Confirmation beep with stamp-like finality, document annotation sound, official marking, 0.3 seconds
```
**Suggested filename:** `document_scanner_confirm.mp3`

#### Scanning Movement
```
Soft paper surface being examined, gentle UV light movement across document, subtle friction, 0.4 seconds
```
**Suggested filename:** `document_scanner_movement.mp3`

---

### Fingerprint Match (Blue/Forensic Theme)

#### Fingerprint Scan
```
Biometric scanner processing sound, laser line sweep with digital analysis beeps, CSI forensic equipment, 0.7 seconds
```
**Suggested filename:** `fingerprint_match_scan.mp3`

#### Match Correct
```
Positive identification confirmed chime, biometric match success, satisfying lock-in sound, 0.4 seconds
```
**Suggested filename:** `fingerprint_match_correct.mp3`

#### Match Incorrect
```
Soft rejection buzz, fingerprint mismatch indicator, gentle negative tone without harshness, 0.3 seconds
```
**Suggested filename:** `fingerprint_match_incorrect.mp3`

#### Round Complete
```
Case file closing sound with slight paper rustle and stamp, forensic analysis complete, professional, 0.8 seconds
```
**Suggested filename:** `fingerprint_match_round_complete.mp3`

#### Fingerprint Hover
```
Subtle digital magnification sound, forensic lens focusing, quiet examination tone, 0.2 seconds
```
**Suggested filename:** `fingerprint_match_hover.mp3`

---

### Stamp Sorting (Gold/Official Theme)

#### Stamp Grab
```
Paper and rubber stamp pickup sound, light grip with slight paper crinkle, office material handling, 0.2 seconds
```
**Suggested filename:** `stamp_sorting_grab.mp3`

#### Stamp Drop in Bin
```
Paper landing in wooden/metal tray, satisfying sort completion, light thump with paper settling, 0.3 seconds
```
**Suggested filename:** `stamp_sorting_drop.mp3`

#### Correct Sort
```
Pleasant official approval chime, bureaucratic success indicator, subtle gold star feeling, 0.3 seconds
```
**Suggested filename:** `stamp_sorting_correct.mp3`

#### Wrong Sort
```
Soft administrative error buzz, paperwork mistake indicator, gentle enough to not frustrate, 0.3 seconds
```
**Suggested filename:** `stamp_sorting_wrong.mp3`

#### Stamp Falling (ambient during gameplay)
```
Light paper fluttering descent, document falling through air, gentle gravity, 0.6 seconds
```
**Suggested filename:** `stamp_sorting_falling.mp3`

---

## VISUAL ASSETS - Pixel Art Imagen Prompts

**Art Style Reference:** 16-bit pixel art, warm color palette (browns, tans, oranges), Papers Please inspired bureaucratic aesthetic, cute potato characters, wood desk textures, official government document styling with dotted borders.

---

### BORDER CHASE - Conveyor Belt Assets

#### Conveyor Belt Sprite Sheet (Tileable)
**Filename:** `border_chase_conveyor_belt.png`
```
16-bit pixel art industrial conveyor belt sprite sheet, dark gray metal rollers with rubber belt texture, orange warning stripes on edges, 4-frame animation cycle, top-down perspective, warm industrial colors, game asset, transparent background, 64x32 pixels per frame
```

#### Contraband Items Sprite Sheet
**Filename:** `border_chase_contraband_items.png`
```
16-bit pixel art contraband items sprite sheet for border checkpoint game, suspicious packages, hidden weapons, fake documents, forbidden produce, each item 32x32 pixels, red warning glow effect, Papers Please inspired, warm color palette, transparent background
```

#### Approved Items Sprite Sheet
**Filename:** `border_chase_approved_items.png`
```
16-bit pixel art approved cargo items sprite sheet, legitimate luggage, proper documents, fresh vegetables, clean packages, each item 32x32 pixels, green checkmark overlay option, Papers Please inspired, transparent background
```

#### Scanner Frame/Border
**Filename:** `border_chase_scanner_frame.png`
```
16-bit pixel art security scanner frame, industrial metal border with orange warning lights, checkpoint aesthetic, dark gray and orange colors, 400x300 pixel frame border, Papers Please inspired, transparent center
```

---

### CODE BREAKER - Terminal Assets

#### Retro Computer Terminal Frame
**Filename:** `code_breaker_terminal_frame.png`
```
16-bit pixel art retro computer terminal frame, CRT monitor with thick bezel, green phosphor glow effect, Soviet-era electronics aesthetic, dark gray metal casing, 400x300 pixels, warm brown desk reflection at bottom, transparent screen area
```

#### Keypad Buttons Sprite Sheet
**Filename:** `code_breaker_keypad_buttons.png`
```
16-bit pixel art number keypad buttons 0-9, chunky mechanical keys, green backlit numbers, 3 states per button (normal, hover, pressed), each button 48x48 pixels, retro terminal aesthetic, transparent background
```

#### Feedback Dots Sprite Sheet
**Filename:** `code_breaker_feedback_dots.png`
```
16-bit pixel art feedback indicator dots, green dot (correct position), yellow dot (wrong position), gray dot (incorrect), each 16x16 pixels, slight glow effect, code-breaking game feedback, transparent background
```

#### Lock/Unlock Animation
**Filename:** `code_breaker_lock_animation.png`
```
16-bit pixel art vault lock sprite sheet, 6-frame unlock animation, heavy metal door mechanism, green indicator light when open, industrial security aesthetic, each frame 64x64 pixels, transparent background
```

---

### DOCUMENT SCANNER - UV Light Assets

#### Scannable Document Base
**Filename:** `document_scanner_document_base.png`
```
16-bit pixel art official government document, cream/tan paper texture matching SpudCustoms Entry Visa style, dotted border frame, empty form fields, potato republic seal watermark, 300x400 pixels, warm parchment colors
```

#### UV Light Cursor/Tool
**Filename:** `document_scanner_uv_lamp.png`
```
16-bit pixel art handheld UV lamp sprite, purple glow emanating from lens, 3 states (off, on, scanning), each 48x48 pixels, forensic investigation tool aesthetic, transparent background
```

#### Hidden Elements Sprite Sheet (revealed under UV)
**Filename:** `document_scanner_hidden_elements.png`
```
16-bit pixel art hidden document elements sprite sheet, secret watermark seal, forged stamp mark, hidden signature, concealed barcode, invisible ink text, each element 32x32 pixels, purple/violet glow effect when revealed, transparent background
```

#### Document Desk Surface
**Filename:** `document_scanner_desk_background.png`
```
16-bit pixel art wooden examination desk texture, dark reddish-brown wood grain matching SpudCustoms main desk, subtle purple UV ambient lighting reflection, 400x300 pixels, warm office aesthetic
```

---

### FINGERPRINT MATCH - Forensic Assets

#### Fingerprint Cards Sprite Sheet
**Filename:** `fingerprint_match_cards.png`
```
16-bit pixel art fingerprint cards sprite sheet, 8 different fingerprint patterns (loop, whorl, arch variants), cream card background with brown ridge patterns, each card 80x100 pixels, forensic evidence aesthetic, transparent background
```

#### Reference Card Frame
**Filename:** `fingerprint_match_reference_frame.png`
```
16-bit pixel art fingerprint reference card holder, metal clipboard frame, blue accent lighting, "REFERENCE" label at top, potato republic official seal, 120x150 pixels, forensic lab aesthetic
```

#### Scanner Device Frame
**Filename:** `fingerprint_match_scanner_frame.png`
```
16-bit pixel art biometric scanner frame, blue LED indicator lights, metal housing with glass scanning surface, police/forensic equipment aesthetic, 400x300 pixels, transparent scan area
```

#### Match Indicators
**Filename:** `fingerprint_match_indicators.png`
```
16-bit pixel art match result indicators, green checkmark for correct match, red X for incorrect, question mark for processing, each 32x32 pixels, slight glow effect, transparent background
```

---

### STAMP SORTING - Bureaucratic Assets

#### Approved Stamp Sprite
**Filename:** `stamp_sorting_approved_stamp.png`
```
16-bit pixel art "APPROVED" rubber stamp, green ink color, worn stamp texture, matching SpudCustoms stamp style, 80x50 pixels, slight rotation variants, transparent background
```

#### Denied Stamp Sprite
**Filename:** `stamp_sorting_denied_stamp.png`
```
16-bit pixel art "DENIED" rubber stamp, red ink color matching existing game stamps, dotted border frame like Entry Visa, 80x50 pixels, slight rotation variants, transparent background
```

#### Sorting Bins Sprite Sheet
**Filename:** `stamp_sorting_bins.png`
```
16-bit pixel art document sorting bins, wooden office trays, green bin labeled "APPROVED" on left, red bin labeled "DENIED" on right, each bin 100x80 pixels, warm brown wood matching main desk, transparent background
```

#### Falling Stamps Animation Sheet
**Filename:** `stamp_sorting_falling_animation.png`
```
16-bit pixel art stamp falling animation, 4-frame rotation cycle for approved stamp, 4-frame rotation cycle for denied stamp, paper flutter effect, each frame 80x50 pixels, transparent background
```

#### Office Desk Background
**Filename:** `stamp_sorting_desk_background.png`
```
16-bit pixel art bureaucratic desk surface, dark reddish-brown wood grain matching SpudCustoms main scene, paper stack decorations in corners, official seal embossed, 400x300 pixels, warm lamp lighting
```

---

### SHARED UI ELEMENTS

#### Minigame Timer Bar
**Filename:** `minigame_ui_timer_bar.png`
```
16-bit pixel art countdown timer bar, bronze/gold metal frame, red fill that depletes, warning state when low (flashing), 200x24 pixels, bureaucratic office aesthetic, transparent background
```

#### Score Counter Frame
**Filename:** `minigame_ui_score_frame.png`
```
16-bit pixel art score display frame, matching SpudCustoms HUD style, dark panel with gold trim, space for 4-digit number, 120x40 pixels, transparent background
```

#### Minigame Title Banner
**Filename:** `minigame_ui_title_banner.png`
```
16-bit pixel art title banner template, parchment/paper scroll style, dotted border matching documents, gold corner decorations, space for title text, 300x60 pixels, transparent background
```

#### Success/Failure Splash
**Filename:** `minigame_ui_result_splash.png`
```
16-bit pixel art result splash screens sprite sheet, "SUCCESS" with green glow and potato celebration, "TIME UP" with red glow and sad potato, each 200x100 pixels, transparent background
```

---

### SPRITE SHEET CUTTING GUIDE

When creating these assets, consider organizing them as single sprite sheets that can be cut:

**border_chase_items.png** (256x128)
- Row 1: Contraband items (8x 32x32)
- Row 2: Approved items (8x 32x32)
- Row 3: Conveyor belt animation (4x 64x32)

**code_breaker_ui.png** (256x256)
- Rows 1-2: Keypad buttons normal state (10x 48x48 + extras)
- Row 3: Keypad buttons pressed state
- Row 4: Feedback dots, lock icons, misc UI

**document_scanner_elements.png** (256x128)
- Row 1: Hidden elements (8x 32x32)
- Row 2: UV lamp states, confirm icons
- Row 3: Document overlay elements

**fingerprint_cards.png** (320x200)
- 8 fingerprint card variants (each 80x100)
- Match indicators below

**stamp_sorting_sprites.png** (256x200)
- Approved stamps (4 rotation variants)
- Denied stamps (4 rotation variants)
- Bin sprites
- Falling animation frames

---

## MUSIC (Optional) - Minigame Background Tracks

### Fast-Paced Minigame Loop (30 seconds)
```
Tense electronic chiptune loop, 120 BPM, urgent but not stressful, puzzle game intensity, synthwave influenced, retro arcade feel, seamless loop
```
**Suggested filename:** `minigame_music_fast.mp3`

### Calm Minigame Loop (30 seconds)
```
Gentle lo-fi electronic ambient loop, 80 BPM, focused concentration music, soft synth pads, mellow puzzle solving atmosphere, seamless loop
```
**Suggested filename:** `minigame_music_calm.mp3`

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

---

## QUICK REFERENCE - All PNG Filenames

### Border Chase
| Asset | Filename | Size |
|-------|----------|------|
| Conveyor Belt | `border_chase_conveyor_belt.png` | 256x32 (4 frames) |
| Contraband Items | `border_chase_contraband_items.png` | 256x32 (8 items) |
| Approved Items | `border_chase_approved_items.png` | 256x32 (8 items) |
| Scanner Frame | `border_chase_scanner_frame.png` | 400x300 |

### Code Breaker
| Asset | Filename | Size |
|-------|----------|------|
| Terminal Frame | `code_breaker_terminal_frame.png` | 400x300 |
| Keypad Buttons | `code_breaker_keypad_buttons.png` | 480x144 (30 buttons) |
| Feedback Dots | `code_breaker_feedback_dots.png` | 48x16 (3 dots) |
| Lock Animation | `code_breaker_lock_animation.png` | 384x64 (6 frames) |

### Document Scanner
| Asset | Filename | Size |
|-------|----------|------|
| Document Base | `document_scanner_document_base.png` | 300x400 |
| UV Lamp | `document_scanner_uv_lamp.png` | 144x48 (3 states) |
| Hidden Elements | `document_scanner_hidden_elements.png` | 160x32 (5 elements) |
| Desk Background | `document_scanner_desk_background.png` | 400x300 |

### Fingerprint Match
| Asset | Filename | Size |
|-------|----------|------|
| Fingerprint Cards | `fingerprint_match_cards.png` | 320x200 (8 cards) |
| Reference Frame | `fingerprint_match_reference_frame.png` | 120x150 |
| Scanner Frame | `fingerprint_match_scanner_frame.png` | 400x300 |
| Match Indicators | `fingerprint_match_indicators.png` | 96x32 (3 icons) |

### Stamp Sorting
| Asset | Filename | Size |
|-------|----------|------|
| Approved Stamp | `stamp_sorting_approved_stamp.png` | 320x50 (4 rotations) |
| Denied Stamp | `stamp_sorting_denied_stamp.png` | 320x50 (4 rotations) |
| Sorting Bins | `stamp_sorting_bins.png` | 200x80 (2 bins) |
| Falling Animation | `stamp_sorting_falling_animation.png` | 320x100 (8 frames) |
| Desk Background | `stamp_sorting_desk_background.png` | 400x300 |

### Shared UI
| Asset | Filename | Size |
|-------|----------|------|
| Timer Bar | `minigame_ui_timer_bar.png` | 200x24 |
| Score Frame | `minigame_ui_score_frame.png` | 120x40 |
| Title Banner | `minigame_ui_title_banner.png` | 300x60 |
| Result Splash | `minigame_ui_result_splash.png` | 400x100 (2 states) |

**Total: 22 PNG files**

---

## QUICK REFERENCE - All MP3 Filenames

### Universal Sounds
| Asset | Filename | Duration |
|-------|----------|----------|
| Success (Chiptune) | `minigame_success_chiptune.mp3` | 1.5s |
| Success (Cash Register) | `minigame_success_cashregister.mp3` | 0.5s |
| Success (Fanfare) | `minigame_success_fanfare.mp3` | 1.0s |
| Timeout (Whomp) | `minigame_timeout_whomp.mp3` | 1.0s |
| Timeout (Clock) | `minigame_timeout_clock.mp3` | 1.5s |
| Timeout (Trombone) | `minigame_timeout_trombone.mp3` | 2.0s |

### Border Chase
| Asset | Filename | Duration |
|-------|----------|----------|
| Conveyor Belt Loop | `border_chase_conveyor_loop.mp3` | 4.0s (loop) |
| Item Grab | `border_chase_item_grab.mp3` | 0.3s |
| Contraband Alert | `border_chase_contraband_alert.mp3` | 0.5s |
| Item Miss | `border_chase_item_miss.mp3` | 0.4s |
| Approved Item Pass | `border_chase_item_pass.mp3` | 0.3s |

### Code Breaker
| Asset | Filename | Duration |
|-------|----------|----------|
| Digit Input | `code_breaker_digit_input.mp3` | 0.15s |
| Code Submit | `code_breaker_submit.mp3` | 0.8s |
| Correct Position | `code_breaker_correct_position.mp3` | 0.2s |
| Wrong Position | `code_breaker_wrong_position.mp3` | 0.2s |
| Incorrect Digit | `code_breaker_incorrect_digit.mp3` | 0.2s |
| Code Cracked | `code_breaker_cracked.mp3` | 1.0s |

### Document Scanner
| Asset | Filename | Duration |
|-------|----------|----------|
| UV Light Activation | `document_scanner_uv_activate.mp3` | 0.5s |
| UV Light Ambient Loop | `document_scanner_uv_loop.mp3` | 3.0s (loop) |
| Hidden Element Reveal | `document_scanner_reveal.mp3` | 0.6s |
| Element Confirmed | `document_scanner_confirm.mp3` | 0.3s |
| Scanning Movement | `document_scanner_movement.mp3` | 0.4s |

### Fingerprint Match
| Asset | Filename | Duration |
|-------|----------|----------|
| Fingerprint Scan | `fingerprint_match_scan.mp3` | 0.7s |
| Match Correct | `fingerprint_match_correct.mp3` | 0.4s |
| Match Incorrect | `fingerprint_match_incorrect.mp3` | 0.3s |
| Round Complete | `fingerprint_match_round_complete.mp3` | 0.8s |
| Fingerprint Hover | `fingerprint_match_hover.mp3` | 0.2s |

### Stamp Sorting
| Asset | Filename | Duration |
|-------|----------|----------|
| Stamp Grab | `stamp_sorting_grab.mp3` | 0.2s |
| Stamp Drop in Bin | `stamp_sorting_drop.mp3` | 0.3s |
| Correct Sort | `stamp_sorting_correct.mp3` | 0.3s |
| Wrong Sort | `stamp_sorting_wrong.mp3` | 0.3s |
| Stamp Falling | `stamp_sorting_falling.mp3` | 0.6s |

### Music (Optional)
| Asset | Filename | Duration |
|-------|----------|----------|
| Fast-Paced Loop | `minigame_music_fast.mp3` | 30s (loop) |
| Calm Loop | `minigame_music_calm.mp3` | 30s (loop) |

**Total: 33 MP3 files**
