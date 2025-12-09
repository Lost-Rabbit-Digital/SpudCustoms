# Spud Customs - Asset Generation Prompts

This document contains prompts for generating music, sound effects, and cutscene art for the narrative system.

**Status:** Most assets have been generated. This file tracks remaining items only.

---

## REMAINING MUSIC TRACKS (ElevenLabs)

| Filename | Duration | BPM | ElevenLabs Prompt |
|----------|----------|-----|-------------------|
| `assets/music/narrative/viktor_grief_main.mp3` | 1:30 | 60 | Melancholic piano piece with soft strings. Reflective, grieving atmosphere. Minor key with occasional major resolutions suggesting hope. Eastern European folk influence. Gentle, intimate, and deeply sorrowful. A husband mourning his lost wife. Stars and night sky feeling. |

---

## REMAINING CUTSCENE ART (Image Generation)

### Format Guidelines
- **Style**: Stylized illustration, anthropomorphic potato characters, dystopian/noir atmosphere
- **Color Palette**: Muted browns, grays, purple (Root Reserve), chartreuse (hope/resistance), crimson (danger)
- **Aspect Ratio**: 16:9 (1920x1080)

### Missing Images

| Filename | Priority | Referenced In | Prompt |
|----------|----------|---------------|--------|
| `assets/narrative/wife_photo.png` | High | shift3_intro.dtl:65 | Worn photograph of Maris Piper, an anthropomorphic potato woman. Portrait style, warm sepia-toned, slightly faded edges. Young potato with gentle features, kind eyes, and a warm genuine smile. Soft lighting, hopeful expression. The photo appears old and well-loved, with slight creases and wear marks. Nostalgic, intimate feeling. Close-up portrait composition like a beloved family photo. |
| `assets/narrative/yellow_emblem.png` | Medium | loyalist_ending.dtl:196 | Close-up of wall with scratched yellow spud resistance emblem. Secret symbol of hope. Crude but meaningful. Graffiti on institutional concrete. A spark of defiance. |
| `assets/narrative/sasha_quarters_raid.png` | Medium | shift8_end.dtl:22 | Security forces kicking down Sasha's door. Raid in progress. Dramatic action. Anthropomorphic potato guards in tactical gear breaching a modest living quarters. |
| `assets/narrative/player_confronts_guards.png` | Medium | shift8_end.dtl:90 | Player stepping forward to confront guards during Sasha's arrest. Brave but foolish. POV shot of anthropomorphic potato officer standing up to authority. |
| `assets/narrative/storage_room.png` | Medium | shift8_end.dtl:142 | Small, dim storage room. Crates and supplies. Secret meeting place. Industrial checkpoint storage area with harsh overhead lighting. Covert resistance meeting spot. |
| `assets/narrative/cafeteria_evening.png` | Medium | shift2_end.dtl:31 | Checkpoint cafeteria at evening. Officers eating. Root Reserve cups on tables. Ominous purple supplements. Anthropomorphic potato workers in a institutional dining hall. |

---

## COMPLETED ASSETS

The following assets have been generated and are available in the project:

### Music Tracks (7 completed)
- `rescue_chase_main.mp3` - Intense orchestral chase music
- `maris_theme_main.mp3` - Delicate, haunting piano melody
- `truth_revealed_sting.mp3` - Dissonant horror sting
- `hollow_victory_march.mp3` - Ironic military victory march
- `new_dawn_theme.mp3` - Bittersweet orchestral piece
- `victory_aftermath_main.mp3` - Contemplative post-victory music
- `storm_thunder_ambience.mp3` - Distant thunder and rain

### Atmosphere Tracks (1 completed)
- `processing_plant_ambient.mp3` - Industrial horror ambiance

### Sound Effect Stings (6 completed)
- `failure_sting.mp3`, `grief_piano.mp3`, `heroic_moment.mp3`
- `victory_swell.mp3`, `emotional_sting.mp3`, `decision_weight.mp3`

### Mechanical Sounds (2 completed)
- `conveyor_grind.mp3`, `processing_vat_bubble.mp3`

### Character Sounds (2 completed)
- `viktor/grief_sigh.mp3`, `murphy/determined_grunt.mp3`

### Narrative Images (All High Priority completed)
All high-priority emotional and action scenes have been generated, including:
- `sasha_capture.png`, `sasha_rescue.png`, `sasha_arrest.png`, `sasha_saves.png`
- `memorial_wall.png`, `victory_feast.png`, `checkpoint_roof.png`
- `viktor_rescue.png`, `viktor_standoff.png`
- `murphy_sacrifice.png`, `murphy_distraction.png`
- `cornered.png`, `rescue_fail.png`, `facility_malfunction.png`
- `processing_facility.png`, `final_chaos.png`, `idaho_confrontation.png`
- `guard_betrayal.png`, `guards_threatening.png`, `justice_hall.png`
- `reckoning.png`, `uprising_victory.png`, `new_spud_flag.png`
- `credits.png`, `credits_sasha.png`
- All loyalist ending images (`loyalist_ceremony.png`, `loyalist_future.png`, etc.)
- `idaho_arrival.png`, `official_arrival.png`, `aftermath.png`, `sasha_memory.png`

---

## File Generation Checklist

- [x] Generate all music tracks (1 remaining)
- [x] Generate all sound effects (complete)
- [ ] Generate remaining cutscene art (6 remaining - 1 high priority)
- [x] Test audio levels in-game
- [x] Verify image aspect ratios and formats

---

*Last Updated: December 2024*
