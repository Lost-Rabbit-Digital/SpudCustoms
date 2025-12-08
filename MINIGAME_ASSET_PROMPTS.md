# Minigame Asset Generation Prompts

This document contains prompts for generating missing audio and visual assets for the SpudCustoms minigames using Imagen (images) and ElevenLabs (audio/SFX).

**Status:** Most assets have been generated. This file tracks remaining items and documents completed assets.

---

## REMAINING ASSETS TO GENERATE

### Audio (2 remaining)

| Filename | Duration | ElevenLabs Prompt |
|----------|----------|-------------------|
| `border_chase_contraband_alert.mp3` | 0.5s | Short urgent radar ping with slight static, security scanner detection beep, industrial warning tone, 0.5 seconds |
| `minigame_music_calm.mp3` | 30s (loop) | Gentle lo-fi electronic ambient loop, 80 BPM, focused concentration music, soft synth pads, mellow puzzle solving atmosphere, seamless loop |

**Note:** `minigame_music_slow.mp3` exists and may serve as an alternative to `minigame_music_calm.mp3`.

### Images (1 remaining)

| Filename | Size | Imagen Prompt |
|----------|------|---------------|
| `minigame_ui_title_banner.png` | 300x60 | 16-bit pixel art title banner template, parchment/paper scroll style, dotted border matching documents, gold corner decorations, space for title text, 300x60 pixels, transparent background |

### Typo Fix Needed

The file `fingerprint_match_indictators.png` should be renamed to `fingerprint_match_indicators.png`.

---

## COMPLETED ASSETS

### Audio - All Minigame Sounds (31 completed)

#### Universal Sounds (6)
- `minigame_success_chiptune.mp3` - Triumphant 8-bit victory jingle
- `minigame_success_cashregister.mp3` - Satisfying cash register sound
- `minigame_success_fanfare.mp3` - Short celebratory brass fanfare
- `minigame_timeout_whomp.mp3` - Gentle descending synth
- `minigame_timeout_clock.mp3` - Clock winding down
- `minigame_timeout_trombone.mp3` - Comedic sad trombone

#### Border Chase (4)
- `border_chase_conveyor_loop.mp3` - Industrial conveyor belt loop
- `border_chase_item_grab.mp3` - Quick grab sound
- `border_chase_item_miss.mp3` - Item sliding away
- `border_chase_item_pass.mp3` - Safe passage chime

#### Code Breaker (6)
- `code_breaker_digit_input.mp3` - Keyboard key press
- `code_breaker_submit.mp3` - Electronic processing whir
- `code_breaker_correct_position.mp3` - Positive blip
- `code_breaker_wrong_position.mp3` - Neutral tone
- `code_breaker_incorrect_digit.mp3` - Soft negative buzz
- `code_breaker_cracked.mp3` - Lock disengaging

#### Document Scanner (5)
- `document_scanner_uv_activate.mp3` - UV light turning on
- `document_scanner_uv_loop.mp3` - UV lamp humming
- `document_scanner_reveal.mp3` - Discovery shimmer
- `document_scanner_confirm.mp3` - Confirmation beep
- `document_scanner_movement.mp3` - Scanning movement

#### Fingerprint Match (5)
- `fingerprint_match_scan.mp3` - Biometric scanner
- `fingerprint_match_correct.mp3` - Match success
- `fingerprint_match_incorrect.mp3` - Mismatch indicator
- `fingerprint_match_round_complete.mp3` - Case file closing
- `fingerprint_match_hover.mp3` - Magnification sound

#### Stamp Sorting (5)
- `stamp_sorting_grab.mp3` - Stamp pickup
- `stamp_sorting_drop.mp3` - Paper landing in tray
- `stamp_sorting_correct.mp3` - Approval chime
- `stamp_sorting_wrong.mp3` - Error buzz
- `stamp_sorting_falling.mp3` - Paper fluttering

#### Music (1)
- `minigame_music_fast.mp3` - Tense electronic chiptune loop

---

### Images - All Minigame Textures (27 completed)

#### Border Chase (4)
- `border_chase_conveyor_belt.png` - Tileable conveyor belt
- `border_chase_contraband_items.png` - Contraband sprite sheet
- `border_chase_approved_items.png` - Approved items sprite sheet
- `border_chase_scanner_frame.png` - Scanner frame border

#### Code Breaker (4)
- `code_breaker_terminal_frame.png` - Retro CRT terminal
- `code_breaker_keypad_buttons.png` - Number keypad buttons
- `code_breaker_feedback_dots.png` - Green/yellow/gray dots
- `code_breaker_lock_animation.png` - Vault lock animation

#### Document Scanner (4)
- `document_scanner_document_base.png` - Government document base
- `document_scanner_uv_lamp.png` - Handheld UV lamp
- `document_scanner_hidden_elements.png` - Secret elements
- `document_scanner_desk_background.png` - Wooden desk texture

#### Fingerprint Match (4)
- `fingerprint_match_cards.png` - Fingerprint card variants
- `fingerprint_match_reference_frame.png` - Reference card holder
- `fingerprint_match_scanner_frame.png` - Biometric scanner frame
- `fingerprint_match_indictators.png` - Match indicators (needs rename)

#### Stamp Sorting (5)
- `stamp_sorting_approved_stamp.png` - Green APPROVED stamp
- `stamp_sorting_denied_stamp.png` - Red DENIED stamp
- `stamp_sorting_bins.png` - Sorting bins
- `stamp_sorting_falling_animation.png` - Falling animation
- `stamp_sorting_desk_background.png` - Office desk surface

#### Shared UI (4)
- `minigame_ui_timer_bar.png` - Countdown timer bar
- `minigame_ui_score_frame.png` - Score display frame
- `minigame_ui_result_splash_success.png` - Success splash
- `minigame_ui_result_splash_failure.png` - Failure splash

---

## EXISTING ASSETS THAT CAN BE REUSED

The following existing audio files in the project can supplement minigame sounds:

### Success Sounds
- `assets/audio/gameplay/combo_activate.mp3`
- `assets/audio/gameplay/score_popup.mp3`
- `assets/audio/ui_feedback/achievement_unlocked.mp3`

### Stamp-Related (for Stamp Sorting)
- `assets/audio/gameplay/stamp_ink_splatter.mp3`
- `assets/audio/gameplay/stamp_ink_spray.mp3`
- `assets/audio/mechanical/stamp_sound_1.mp3` through `stamp_sound_5.mp3`

### Paper Sounds (for Document Scanner)
- `assets/audio/paper/paper_fold_1.mp3` through `paper_fold_6.mp3`

### UI Feedback
- `assets/audio/ui_feedback/tooltip_appear.mp3`
- `assets/audio/ui_feedback/ui_hover_button.mp3`

### Mechanical Sounds
- `assets/audio/mechanical/lever_pull_01.mp3`

---

## TECHNICAL SPECIFICATIONS

### Audio Format Requirements
- Format: MP3 or OGG (Godot compatible)
- Sample Rate: 44100 Hz
- Bit Rate: 128-192 kbps
- Channels: Mono (SFX) or Stereo (music)

### Image Format Requirements
- Format: PNG (with transparency if needed)
- Color depth: 24-bit RGB or 32-bit RGBA

### Asset Locations
- Audio: `godot_project/assets/audio/minigames/`
- Images: `godot_project/assets/minigames/textures/`

---

## SUMMARY

| Category | Completed | Remaining |
|----------|-----------|-----------|
| Audio Files | 31 | 2 |
| Image Files | 27 | 1 |
| **Total** | **58** | **3** |

---

*Last Updated: December 2024*
