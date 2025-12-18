# Audio Design - Comprehensive Strategy

> **Back to:** [GDD Index](README.md) | **Previous:** [UI Layout](07_ui_layout.md)

## Audio Philosophy

### Core Principles

- Audio reinforces gameplay feedback (every action has sound)
- Music adapts to narrative tension and gameplay intensity
- Diegetic sounds prioritized (in-world audio sources)
- Accessibility through visual alternatives for critical audio cues

### Audio Pillars

1. **Clarity**: Player always understands what sound means
2. **Immersion**: Sounds believable within dystopian potato world
3. **Feedback**: Immediate audio response to player actions
4. **Atmosphere**: Music and ambience support narrative tone

## Music System ✓ (Implemented)

**7 Custom ElevenLabs-Generated Music Tracks** integrated with dynamic switching throughout story and gameplay.

### Dynamic Music Layers

#### Main Menu

- Ambient, slightly ominous loop ✓
- Parallax mouse background effect accompanies music
- Volume: -10dB to allow for clear menu navigation

#### Gameplay - Story Mode

- **Dynamic music switches** integrated into DTL narrative files ✓
- Context-aware track changes based on story beats
- Character sound_moods for chatter audio ✓
- Audio levels normalized to -5 dB

#### Gameplay - Endless/Score Attack

- Upbeat, chiptune-style track (currently: chiptune_work_work_work_main.mp3)
- Emphasizes competitive nature
- Faster tempo: 120-140 BPM
- Volume: -10dB to maintain focus

#### Narrative Scenes (Dialogic)

- Contextual music per scene ✓
- Dramatic audio events integrated into timeline files ✓
- Fade transitions (2s) between tracks
- Lower volume to prioritize dialogue
- Emotional matching: tense, mysterious, hopeful

#### Shift Summary

- **Success**: Triumphant fanfare (15s), then cheerful loop
- **Failure**: Somber, descending progression (10s), fade to silence
- **Perfect Performance**: Extra flourish, celebratory brass

### Music Implementation

- All tracks looped seamlessly
- Crossfade between layers: 1.5-2s
- Bus routing: "Music" bus (separate from SFX for volume control)
- Format: MP3 (OGG Vorbis for compatibility)

## Sound Effects Catalog

### UI Sounds

#### Menu Navigation

- Hover: Subtle tick (mechanical switch) - 0.05s
- Click: Satisfying clunk (stamp impression) - 0.1s
- Back/Cancel: Softer click, slightly lower pitch
- Error/Disabled: Dull thud, no resonance
- Volume: -5dB (audible but not intrusive)

#### Sliders/Adjustments

- Volume sliders: Tick sound every 5% increment
- Toggle switches: Mechanical flip sound
- Checkbox: Light tap

#### Notifications

- Achievement unlock: Bright chime + whoosh (celebration)
- Citation warning: Single beep (cautionary)
- Strike issued: Alarm siren (2s, urgent)
- Message received: Typewriter ding

### Gameplay Sounds

#### Document Handling

- **Pick up document**: Paper rustle + subtle grip sound
  - Variations: 3 samples to avoid repetition
  - Volume: -8dB
- **Drag document**: Light paper slide (looping while dragged)
  - Low-pass filter applied for smoothness
  - Volume: -12dB
- **Drop document**: Paper flutter + soft impact
  - Pitch varies slightly based on drop height
  - Volume: -8dB
- **Document whoosh**: Quick paper movement sound
  - For fast drags or returns
  - Volume: -6dB

#### Stamping

- **Stamp pull**: Mechanical slide, slight squeak
  - When opening stamp bar
  - Volume: -7dB
- **Stamp impact**: Heavy thud + ink squelch
  - Variations for approved vs rejected (pitch difference)
  - Perfect placement: Extra satisfying "clunk" + chime
  - Volume: -5dB (prominent feedback)
- **Stamp return**: Mechanical slide reversed
  - When closing stamp bar
  - Volume: -7dB

#### Megaphone/Calling

- **Megaphone click**: Button press sound
  - Volume: -6dB
- **Megaphone broadcast**: Distorted "Next!" callout (potato voice)
  - Optional: Procedural potato voice generator
  - Volume: -4dB

#### Booth Operations

- **Lever pull**: Mechanical chain sound (currently: chain 2.wav)
  - Duration: 1.5s
  - Volume: -10dB
- **Shutter open**: Metal grinding, upward pitch shift
  - Duration: 2s
  - Volume: -8dB
- **Shutter close**: Metal grinding, downward pitch shift
  - Duration: 2s
  - Volume: -8dB

#### Potato Sounds

- **Footsteps (grass)**: Soft rustle, organic
  - Variations: 4 samples
  - Volume: -10dB
- **Footsteps (concrete)**: Harder impact, echo (currently: Concrete Walk samples)
  - Variations: 4 samples
  - Volume: -8dB
- **Emote sounds**: Contextual reactions
  - Anger: Low growl/rumble
  - Fear: High-pitched squeak
  - Confusion: Questioning chirp
  - Volume: -9dB
- **Breathing (in booth)**: Subtle, rhythmic
  - Only when potato is waiting
  - Very quiet: -18dB

#### Missile Defense

- **Missile launch**: Whoosh + rocket ignition
  - Doppler effect as missile travels
  - Volume: -6dB
- **Missile hit**: Explosion + splat
  - Particle sounds (debris falling)
  - Volume: -4dB (impactful)
- **Miss**: Distant explosion (off-screen)
  - Volume: -10dB
- **Runner escape**: Alarm beep + negative chime
  - Indicates strike
  - Volume: -5dB

#### X-Ray Scanner

- **Activate**: Electric hum + charging sound
  - Duration: 0.5s
  - Volume: -7dB
- **Scanning**: Continuous low hum (looped)
  - Slightly unsettling frequency
  - Volume: -12dB
- **Detection found**: Alert ping + highlight sound
  - Volume: -6dB
- **Deactivate**: Discharge sound, hum fades
  - Duration: 0.3s
  - Volume: -7dB

#### Document Scanner (UV Light Mini-game) ✓

- Uses drag interaction to reveal hidden elements
- Click to mark discovered elements for bonus points
- Audio integrated into mini-game system

**Note**: The X-Ray Scanner (above) is used in story mode for in-world scanning machines. The Document Scanner mini-game uses UV light theming for the puzzle gameplay.

### Ambient Sounds

#### Customs Office (Interior)

- Low background hum (machinery, ventilation)
  - Continuous loop, -20dB
- Distant radio chatter (muffled)
  - Occasional bursts, unintelligible
  - Volume: -22dB
- Fluorescent light hum
  - Subtle, high frequency
  - Volume: -25dB

#### Border Area (Exterior)

- Wind ambience (plains, desolate)
  - Varies in intensity
  - Volume: -18dB
- Distant industrial sounds (factories)
  - Reinforces dystopian setting
  - Volume: -20dB
- Birds chirping (occasionally)
  - Fly away when clicked
  - Sound: Flapping wings + chirp
  - Volume: -15dB

#### Queue Area

- Potato murmurs (crowd ambience)
  - Low, indistinct conversation
  - Volume scales with queue size
  - Base volume: -16dB

### Voice/Dialogue

#### Dialogic Scenes

- **Typing effect**: Currently uses keyboard mechanical typing 1.mp3
  - **ISSUE**: Audio desync noted in GDD
  - **Fix**: Use Dialogic built-in typing sounds OR custom tailored files
  - Sync with text speed setting
  - Volume: 0dB (per current timeline, needs adjustment to -10dB)

#### Potato Voices (Planned)

- Procedural pitch-shifted vocal sounds
- Contextual emotional inflection
- Short phrases during document inspection
  - "Here's my papers..."
  - "Please, I need to get through..."
  - Terry Pratchett-inspired humor

#### Supervisor Russet

- Distinct voice (lower pitch, authoritative)
- Radio filter effect (talking through intercom)
- Volume: -8dB

## Audio Buses & Mixing

```
Master Bus (0dB)
├── Music Bus (-5dB)
│   ├── Menu Music
│   ├── Gameplay Music (layers)
│   └── Narrative Music
├── SFX Bus (-3dB)
│   ├── UI Sounds
│   ├── Gameplay Sounds
│   ├── Ambient Sounds
│   └── Feedback Sounds
└── Voice Bus (-2dB)
    ├── Dialogue
    ├── Potato Voices
    └── Typing Effects
```

### Player Controls

- Master volume slider (0-100%)
- Music volume slider (0-100%)
- SFX volume slider (0-100%)
- Voice volume slider (0-100%)
- Mute all toggle

## Audio Implementation Technical Details

### Audio Format

- Music: MP3 or OGG Vorbis (streaming)
- SFX: WAV (short samples, loaded into memory)
- Voice: OGG Vorbis (streaming for dialogue)

### Optimization

- Pool frequently used sounds (footsteps, document rustles)
- Limit simultaneous sound instances (max 32 active sounds)
- Distance-based volume attenuation for off-screen sounds
- Priority system: Feedback > Gameplay > Ambient

### 3D Audio (Future Consideration)

- Spatial audio for runner positions
- Panning for off-screen events
- Currently: Stereo 2D audio sufficient for scope

## Audio Feedback for Accessibility

### Visual Alternatives

- Subtitle system for all dialogue
- Visual indicators for off-screen sounds (directional arrows)
- Haptic feedback (Steam Deck / controller rumble)
  - Stamp placement: Short rumble
  - Strike: Strong rumble
  - Perfect combo: Pulsing rumble

### Audio Cues Settings

- Toggle to enhance critical audio (louder strikes, runners)
- Mono audio option (for hearing impairment)
- Reduce background ambience option (focus on gameplay sounds)

## Environmental Details

- Birds on ground that fly away on interaction (sound: flapping + chirp)
- Animated lights in customs office and Border Wall (subtle hum)
- Footstep system (concrete steps smaller/darker than grass, louder/softer audio)
- Shift-start animation: Player potato walks into office (footsteps + door open)
- Shadow rendering fixes for new potato models (no audio impact)

---

> **Next:** [Technical Implementation](09_technical.md)
