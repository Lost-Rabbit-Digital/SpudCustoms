# Spud Customs
## Game Design Document

### Table of Contents
1. [Game Overview](#1-game-overview)
2. [Core Gameplay](#2-core-gameplay)
3. [Story Mode](#3-story-mode)
4. [Game Modes](#4-game-modes)
5. [Features & Systems](#5-features--systems)
6. [Technical Implementation](#6-technical-implementation)
7. [Quality Assurance & Testing Strategy](#7-quality-assurance--testing-strategy)
8. [Steam Release Requirements](#8-steam-release-requirements)
9. [Development Timeline](#9-development-timeline)
10. [Post-Launch Support](#10-post-launch-support)
11. [Known Issues & Action Items](#11-known-issues--action-items)

---

## 1. Game Overview

### High Concept
"Spud Customs" is a dystopian document thriller game set in a world of anthropomorphic potatoes. Players take on the role of a customs officer, processing documents and making critical decisions that affect the narrative and outcome.

### Target Audience
- Primary: Fans of Papers, Please and narrative-driven games
- Secondary: Casual gamers interested in unique, story-rich experiences
- Age Rating: Teen (Dark humor, mild violence)

### Genre & Tags
- Primary Genre: Simulation
- Sub-Genres: Indie, Casual, Strategy
- Tags: Immigration, Potato, Customs, Paper Please, Bureaucracy, Time Management

---

## 2. Core Gameplay

### Basic Mechanics
- Document inspection and verification
- Time-pressured decision making
- Stamp-based approval/rejection system
- Consequence-driven progression
- Missile defense system against border runners
- X-ray scanning for hidden messages/contraband


### Difficulty Levels
1. Easy Mode:
   - 8 potato target score
   - 5 strikes allowed
   - 12 minute shift time
   
2. Normal Mode:
   - 10 potato target score
   - 3 strikes allowed
   - 10 minute shift time
   
3. Hard Mode:
   - 12 potato target score
   - 2 strikes allowed
   - 8 minute shift time

### Scoring System
- Perfect stamp placements award combo multipliers
- Missile kills on runners award points (negative points if approved potato killed)
- X-ray scanning detection awards bonus points

---

## 3. Story Mode

### Chapter Structure
Each chapter represents one work shift (10 total shifts)

#### Shift 1: "Peeling Back the Layers"
- Dynamic tutorial integration (replaces hard-coded screenshot tutorial)
- Introduction to border checkpoint operations
- Tutorial for gate raising mechanic
- Tutorial for runners with emote warnings
- Introduction of Supervisor Russet and key characters
- **Narrative Note**: Ending with "And remember, Glory to Spud!"

#### Shift 2-3: "The Underground Root Cellar"
- Discovery of resistance movement
- Introduction of coded messages via X-ray scanning
- Deeper conspiracy elements
- Moral choice integration
- Environmental storytelling begins (propaganda posters visible)

#### Shift 4: "The Mashing Fields"
- Major plot revelations
- Increased difficulty
- Character relationships deepen
- **Needs Work**: Ending is abrupt and jarring, requires smoother transition

#### Shift 10: "Mash or Be Mashed"
- Story climax with **4 distinct endings** (2 art pieces + 4 dialogue lines each)
- **Needs Revision**: Confusing narrative change in "stay" path regarding resistance members
- **Requires Implementation**: Multiple ending branches based on player choices
- Final confrontations
- Resolution of major plot threads

### Narrative Elements
- Dialogue system with choice consequences (tracked via NarrativeManager)
- Environmental storytelling through:
  - Propaganda posters (progressive display as shifts advance)
  - Radio broadcasts (audio integration needed)
  - Newspaper headlines (visible in background)
- Character relationships and reputation system
- **New**: Interactive potato conversations during document inspection (Terry Pratchett-inspired)
- **Technical Note**: Use OGV video files or Animated GIFs for StagNation artwork integration

### Choice Tracking System
- NarrativeManager must properly retain, track, save, and load player choices
- SaveManager integration required for narrative persistence
- All major story decisions must affect ending determination

---

## 4. Game Modes

### Story Mode
- 2-3 hour campaign
- Structured narrative progression
- Character development
- **4 distinct endings** based on player choices

### Endless / Score Attack Mode
- Infinite potato processing
- Progressive difficulty scaling
- High score tracking per difficulty per player
- Unlockable content system
- **Leaderboard Focus**: Primary leaderboard display (moved from story mode)

### Daily Challenge
- Unique daily rule sets
- Global leaderboards (primary focus)
- Fixed seed for fairness
- Special achievements
- **Leaderboard Structure**: Top 3 scores, player position with 3 above/3 below

---

## Progression Time Targets

### Player Expectation Setting

**Core Philosophy:**
- Respect player time with clear expectations
- Balance challenge with accessibility
- Provide meaningful progression without padding
- Optional content extends playtime without required grind

### Story Mode - Time Investment

**First Playthrough (Single Ending):**
- **Target**: 2-3 hours
- **Breakdown**:
  - Intro sequence: 5-8 minutes (narrative setup)
  - Shift 1 (with tutorial): 15-20 minutes
  - Shifts 2-9: 10-15 minutes each (varies by difficulty)
  - Shift 10 (finale): 15-20 minutes (includes ending cutscene)
  - Dialogic interludes: 2-5 minutes between shifts

**Per-Shift Time Targets (Difficulty-Based):**
- Easy Mode: 12 minutes per shift
- Normal Mode: 10 minutes per shift
- Hard Mode: 8 minutes per shift

**Completion Time Distribution:**
- **Fast players (Hard, no fails)**: ~90 minutes
- **Average players (Normal, 1-2 retries)**: ~150 minutes (2.5 hours)
- **Casual players (Easy, multiple retries, thorough)**: ~180 minutes (3 hours)

**Multiple Playthrough Investment (All Endings):**
- **4 endings total** (Revolution, Diplomatic, Loyalist, Savior)
- First playthrough: 2-3 hours
- Subsequent playthroughs: 1-1.5 hours each (can skip seen dialogue)
- **Total for 100% story completion**: ~6-8 hours

**Narrative Content Pacing:**
- Major story beats every 2-3 shifts
- Choice-heavy shifts take +2-3 minutes longer
- Cutscenes average 2-3 minutes each
- No artificial padding or forced waiting

### Endless / Score Attack Mode

**Session Lengths:**
- **Quick Session**: 10-15 minutes (reach first checkpoint)
- **Medium Session**: 30-45 minutes (competitive scoring)
- **Extended Session**: 60+ minutes (difficulty scaling, high score chasing)

**Difficulty Scaling:**
- Every 10 potatoes processed: +1 rule complexity
- Every 5 minutes: -5% time buffer for decisions
- New potato types unlock at intervals (visual variety)
- Score multiplier increases with consecutive perfects

**Progression Milestones:**
- First 100 potatoes: ~30 minutes
- First 500 potatoes: ~2 hours (cumulative across sessions)
- First 1000 potatoes: ~5 hours (long-term goal)

**High Score Chase:**
- Top 10% global rank: ~3-5 hours practice
- Top 1% global rank: ~10-15 hours mastery
- World record contention: ~20+ hours (speedrun tactics + optimization)

### Daily Challenge

**Per-Challenge Time:**
- **Single attempt**: 10-15 minutes
- **Competitive attempts** (3-5 retries): 30-60 minutes
- **Daily commitment**: 15-30 minutes for regular players

**Weekly/Monthly Investment:**
- Casual engagement: 2-3 hours per week (3-4 daily challenges)
- Dedicated engagement: 5-7 hours per week (daily participation)
- Competitive leaderboard climbing: 10+ hours per week

### Achievement Completion Time

**Quick Achievements (First Session):**
- First Day on the Job: ~20 minutes
- Best Served Hot: ~30 minutes

**Story-Based Achievements:**
- Single ending: 2-3 hours
- All endings: 6-8 hours

**Skill-Based Achievements:**
- Sharpshooter (10 runners): ~2 hours of gameplay
- Border Defender (50 runners): ~8-10 hours
- High Scorer (10,000 points): ~3-5 hours practice
- Score Legend (50,000 points): ~15-20 hours mastery

**100% Achievement Completion:**
- **Target**: 20-30 hours
- **Breakdown**:
  - Story completion (all endings): 6-8 hours
  - Skill achievements: 5-10 hours
  - Cumulative achievements: 8-12 hours (border defense, score milestones)

### Content Unlock Progression

**Potato Type Unlocks (Story Mode):**
- Start: Russet potato only
- Shift 3: Unlock second potato type
- Shift 6: Unlock third potato type
- Shift 9: Unlock fourth potato type
- **Instant variety vs. gradual unlock**: Balances early simplicity with late-game complexity

**Rule Complexity Curve:**
- Shift 1: 2-3 basic rules (age, country)
- Shift 2-4: 4-6 rules (add gender, race conditions)
- Shift 5-7: 7-9 rules (complex combinations)
- Shift 8-10: 10+ rules (maximum challenge)

**Time Investment Per Unlock:**
- ~20-30 minutes per new potato type
- ~15 minutes per major rule tier
- No grind required - all unlocks via natural story progression

### Replayability Time Estimates

**Reasons to Replay:**
1. **Multiple endings**: +6 hours total
2. **Higher difficulties**: +3-4 hours (replay campaign on Hard)
3. **Perfect runs**: +2-3 hours (S-rank all shifts)
4. **Speedrunning**: +10-20 hours (route optimization)
5. **Score attack mastery**: +15-30 hours (endless mode)
6. **Daily challenges**: Ongoing (15-30 min/day)

**Total Content Lifetime (For Dedicated Players):**
- Main story (all endings): 6-8 hours
- Endless mode mastery: 20-40 hours
- Daily challenges (3 months): 30-60 hours
- Speedrun community: 20-50 hours
- **Estimated total**: 75-150+ hours for completionists

### Player Segments & Time Expectations

**Casual Players (Story Only):**
- **Expectation**: 2-3 hours for satisfying conclusion
- **Actual playtime**: 3-5 hours (includes retries, exploration)
- **Completion rate target**: 60-70% finish one ending

**Core Players (Story + Some Endless):**
- **Expectation**: 5-10 hours of content
- **Actual playtime**: 10-20 hours (multiple endings, score attack)
- **Completion rate target**: 30-40% see multiple endings

**Dedicated Players (All Content):**
- **Expectation**: 15-30 hours for 100% completion
- **Actual playtime**: 30-75 hours (mastery, leaderboards, dailies)
- **Completion rate target**: 5-10% achieve 100% achievements

**Competitive Players (Leaderboard Chasers):**
- **Expectation**: Ongoing engagement (months)
- **Actual playtime**: 100+ hours (optimization, daily participation)
- **Retention target**: 1-3% remain active after 3 months

### Pacing & Flow Optimization

**Avoiding Player Fatigue:**
- Shift length capped at 12 minutes (Easy) to prevent tedium
- Story interludes provide mental breaks between gameplay
- Optional skip for repeated dialogue on replays
- Quick restart option for failed shifts (no menu navigation)

**Maintaining Engagement:**
- New mechanics introduced every 2-3 shifts
- Difficulty spikes balanced with narrative payoff
- Score attack mode provides different pacing (player-controlled session length)
- Daily challenges offer bite-sized content (15 min commitment)

**Onboarding Time:**
- Tutorial integrated into Shift 1: 5-7 minutes (interactive learning)
- No separate tutorial mode (friction reduction)
- New mechanic tutorials: 30-60 seconds each (contextual prompts)
- **Total learning curve**: ~20 minutes to competency

### Time Expectations vs. Steam Average

**Genre Comparison (Simulation/Indie):**
- Papers, Please: 8-12 hours average (Steam stats)
- Beholder: 10-15 hours average
- Not Tonight: 6-8 hours average
- **Spud Customs target**: 2-3 hours main story, 10-20 hours full completion

**Justification for 2-3 Hour Campaign:**
- Focused narrative without padding
- High replay value (4 endings, 3 difficulties)
- Endless mode extends playtime optionally
- Price point ($4.99) matches content volume
- Respects player time (modern design philosophy)

### Post-Launch Content Time Impact

**Month 1 Updates:**
- New potato types: +30 minutes per type (visual variety, no time extension)
- Additional rules: +0 minutes (integrated into existing shifts)
- Bug fixes/QoL: Improves pacing, reduces friction

**Months 2-3 Updates:**
- New mini-games: +1-2 hours per addition
- Challenge mode variants: +5-10 hours (new leaderboards)
- Quality of life improvements: Reduces completion time by ~10%

**Long-Term Content:**
- Seasonal events: +2-3 hours per event
- Community-created content: Potentially unlimited
- Multiplayer (if implemented): +20-50 hours (co-op/versus modes)

---

## 5. Features & Systems

### Core Systems

#### 1. Document Processing
- Passport verification
- Rule checking (40+ unique immigration rules at launch)
- Stamp application with visual feedback for combos
- Time management
- **New Documents**: Entry tickets, work permits, visas, marriage licenses, baggage
- **Viewport Masking**: Prevents stamps outside passport boundaries
- **Physics System**: Documents have gravity on suspect panel

#### 2. Mini-games
- **Border Runner Defense**: Missile system to intercept fleeing potatoes
  - Killing approved potatoes: -250 points + strike (Totneva Convention violation)
  - 0 strikes on kill should not display "Strike Removed!"
- **X-ray Scanning**: Special shader reveals inner contents of potatoes and belongings
- **UV Lamp Scanning**: Detect secret symbols/messages on documents for bonus points
- **Baggage Inspection**: Shake bags to reveal bugs, coins, or contraband
- **Interrogation**: Short, fun mini-game (design in progress)
- **Sapper Runners**: Time-bombs placed on walls requiring defusal mini-game or mouse-over
- **Document Physics**: Gravity-based interaction on suspect panel

#### 3. Progression System
- Character customization (hats, badges) - persistence via SaveManager
- **4 unlockable potato types** (down from 10):
  - Start: Russet only
  - Progressive unlock: New type every few shifts in story mode
- New rules and mechanics unlock
- Story achievements (in-game display from Main Menu and Pause Menu)
- Office/booth customization (saved in SaveManager)

#### 4. Emote System
- Potatoes display emotional responses:
  - Exclamation marks when missiles fired
  - Anger (POPPING_VEINS) when clicked 3+ times
  - Chance distribution skewed toward angry/confused
- Audio feedback for emotes
- Tooltips on hover showing potato info

#### 5. Visual Feedback Systems
- Animated score counters (incremental number display)
- Scores appear above respective actions
- Ink flecks from stamping
- Message queue system with delays (prevents override)
- Potato bobbing animation while walking
- Breathing animation for potato in office
- Slight wiggle animation for potatoes in queue
- Enhanced wiggle when clicked

### UI/UX Elements
- Customs office interface
- Document examination system with viewport masking
- Queue management with interaction system
- Time and score display
- Missile counter on LCD display (desk or UI)
- Office shutter with lever (needs SFX)
- **Accessibility Improvements Needed**:
  - Colorblind mode for stamp colors
  - Font size options
  - UI scaling options
  - Different dialogue font

---

## UI Layout - Comprehensive Design

### Screen Hierarchy & Layout Strategy

**Design Philosophy:**
- Diegetic UI where possible (in-world elements like desk items, wall displays)
- Non-diegetic UI only for critical information (timer, quota, strikes)
- Minimalist HUD to maintain immersion
- Screen space optimized for 16:9 aspect ratio (1920x1080 native)

### Main Gameplay Screen (Customs Office)

**Screen Regions:**

```
┌─────────────────────────────────────────────────┐
│  Timer: 10:00    Quota: 3/10    Strikes: ●●○   │ [Top HUD Bar]
├─────────────────────────────────────────────────┤
│                                                 │
│  [Queue]     [Border Wall Area]     [Missile]  │ [Top Third]
│   🥔🥔🥔      ─────────────────       Counter   │
│              │ Running Potatoes│                │
│              ─────────────────                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  [Customs Booth]    [Inspection Table]         │ [Middle Third]
│  ┌──────┐          ┌────────────────┐          │
│  │ 🥔   │          │   Passport     │          │
│  │Potato│          │   [Draggable]  │          │
│  └──────┘          └────────────────┘          │
│  [Lever]           [Suspect Panel]             │
│                    ┌────────────────┐          │
│                    │ Extra Docs     │          │
│                    └────────────────┘          │
├─────────────────────────────────────────────────┤
│                                                 │
│  [Megaphone] [Stamp Bar] [Rules Panel]        │ [Bottom Third]
│     📢         ✓  ✗       📋 Today's Rules     │
│                                                 │
│  Score: 1,250 (+150 Combo!)                    │
└─────────────────────────────────────────────────┘
```

**HUD Elements (Top Bar):**
- **Timer** (Top Left): MM:SS format, color-coded
  - Green: >5 minutes remaining
  - Yellow: 2-5 minutes
  - Red: <2 minutes, pulsing when <1 minute
- **Quota Counter** (Top Center): "Processed / Target" format
  - Updates immediately on each approval/rejection
  - Celebrates reaching quota with brief animation
- **Strike Indicator** (Top Right): Visual dots/badges
  - Filled dots = strikes taken
  - Empty dots = strikes remaining
  - Red flashing animation when strike added

**Interactive Zones:**

*Customs Booth Zone (Left Middle):*
- Potato display area (animated breathing, emotes)
- Shutter lever for opening/closing booth
- Background elements (propaganda posters, lights)
- Hover tooltips when gate closed

*Inspection Table Zone (Center Middle):*
- Primary document interaction area
- Viewport masking to prevent documents leaving bounds
- Drop zones for organizing multiple documents
- Physics-enabled document stacking
- Visual feedback for correct/incorrect placement

*Suspect Panel (Below Inspection Table):*
- Secondary document area
- Gravity physics for dropped documents
- Easy retrieval for comparison
- Prevents clutter on main inspection table

*Stamp Bar (Bottom Center):*
- Retractable UI element
- Shows when clicked/hovered
- Two stamps: Approved (green checkmark), Rejected (red X)
- Perfect placement target indicators
- Ink particle effects on stamp

*Rules Panel (Bottom Right):*
- Scrollable list of active rules
- Collapsible to save screen space
- Highlight rule when hovering over relevant document field
- Checkmark next to verified rules

*Megaphone (Bottom Left):*
- Diegetic control to call next potato
- Hover sound effect
- Disabled state when booth closed or potato present
- Visual feedback (megaphone tilts/animates on click)

*Missile Defense Zone (Top Right Background):*
- Border wall with running potatoes
- Click anywhere on runner to launch missile
- Target cursor on hover
- Explosion particle effects
- Kill counter display

**Floating Feedback Elements:**
- Score popups appear above action locations
  - Stamp: +50, +100 (perfect)
  - Missile kill: +150
  - X-ray detection: +100
- Message queue for supervisor notifications
- Animated combos ("Perfect x3!")
- Citation/strike warnings (modal overlays)

### Menu Screens

**Main Menu Layout:**
```
┌─────────────────────────────────────────────────┐
│                                                 │
│           SPUD CUSTOMS                          │
│        [Title Logo/Art]                         │
│                                                 │
│         ▶ Story Mode                            │
│           Endless Mode                          │
│           Daily Challenge                       │
│           Settings                              │
│           Achievements                          │
│           Quit                                  │
│                                                 │
│  [Walking Potatoes Background Animation]       │
│                                                 │
│  v1.1.0            [Social Icons]  [Steam Icon] │
└─────────────────────────────────────────────────┘
```

**Pause Menu (In-Game Overlay):**
- Semi-transparent background blur
- Centered modal panel
- Options: Resume, Settings, Main Menu, Quit
- Stats display (current shift performance)
- Achievement progress access

**Settings Menu:**
- Tabbed interface: Audio, Video, Controls, Accessibility
- Real-time preview for visual changes
- Volume sliders with tick sounds
- Keybind remapping interface
- Accessibility toggles (see AccessibilityManager)

**Shift Summary Screen:**
- Full-screen results display
- Animated stat counters
- Performance rating (F to S rank)
- Golden stamp awards (0-3)
- Bonus breakdown with tooltips
- Leaderboard position (if connected)
- Continue/Retry/Main Menu buttons

**Achievement Screen:**
- Grid layout of achievement icons
- Locked/unlocked states
- Progress bars for cumulative achievements
- Unlock percentage from global stats
- Filter options (All, Locked, Unlocked)

### Accessibility Features (Managed by AccessibilityManager)

**UI Scaling:**
- 80%, 100%, 120%, 150% options
- Maintains aspect ratio and layout integrity
- Dynamic font resizing
- Adjusts clickable area sizes proportionally

**Colorblind Modes:**
- Protanopia (red-green)
- Deuteranopia (red-green)
- Tritanopia (blue-yellow)
- Stamp colors: Add patterns (stripes, dots) in addition to color
- UI elements use shape + color differentiation

**Font Options:**
- Small, Medium, Large, Extra Large
- Sans-serif default (high readability)
- Dyslexia-friendly font option
- Increased letter spacing option
- High contrast text backgrounds

**High Contrast Mode:**
- Increase border thickness on interactive elements
- Enhanced outlines on documents and UI
- Bright highlights on hover states
- Reduce background detail opacity

### Responsive Design Considerations

**Minimum Resolution: 1280x720**
- UI scales proportionally
- Text remains readable
- All interactive elements maintain minimum 44x44px touch targets (for future mobile/Steam Deck)

**Ultrawide Support (21:9):**
- Extend background artwork
- Keep HUD elements anchored to safe zones
- Center critical gameplay area
- Utilize extra space for decorative elements

**Steam Deck Optimization:**
- Larger UI elements by default
- Touch-friendly button sizes
- Readable fonts at 7-inch screen
- Optimized control scheme for gamepad

### Animation & Feedback

**UI Animations:**
- Button hover: Scale 1.0 → 1.05, duration 0.1s
- Button press: Scale 1.05 → 0.95, duration 0.05s
- Panel transitions: Slide + fade, duration 0.3s
- Notification popups: Bounce in, fade out after 3s
- Score counters: Incremental number animation, 0.5s duration

**Visual Feedback:**
- Hover: Brightness +20%, subtle glow
- Click: Flash effect, particle burst
- Disabled state: 50% opacity, desaturated
- Focus (keyboard nav): Colored outline, 2px width

**Audio Feedback (See Audio Design):**
- Every interactive element has hover + click sounds
- Distinct sounds for positive/negative actions
- Volume scaling based on action importance

### Localization Support

**Text Expansion Allowances:**
- UI elements sized for 30% text expansion (German, Russian)
- Dynamic text wrapping where possible
- Icon-based UI for universal understanding
- Placeholder language flags in settings

**RTL Language Support (Future):**
- Mirror UI layout for Arabic, Hebrew
- Maintain logical reading flow
- Test with placeholder RTL text

---

## Audio Design - Comprehensive Strategy

### Audio Philosophy

**Core Principles:**
- Audio reinforces gameplay feedback (every action has sound)
- Music adapts to narrative tension and gameplay intensity
- Diegetic sounds prioritized (in-world audio sources)
- Accessibility through visual alternatives for critical audio cues

**Audio Pillars:**
1. **Clarity**: Player always understands what sound means
2. **Immersion**: Sounds believable within dystopian potato world
3. **Feedback**: Immediate audio response to player actions
4. **Atmosphere**: Music and ambience support narrative tone

### Music System

**Dynamic Music Layers:**

*Main Menu:*
- Ambient, slightly ominous loop
- Hints at dystopian setting without overwhelming
- Volume: -10dB to allow for clear menu navigation
- Track: [TBD - atmospheric synth pad]

*Gameplay - Story Mode:*
- **Base Layer**: Ambient exploration theme (currently: ambient_exploration_main.mp3)
  - Low-tension shifts (1-3)
  - Volume: -5dB
  - Tempo: 80-100 BPM
- **Tension Layer**: Adds as shift progresses
  - Activates when timer <5 minutes
  - Increases tempo perception through percussion
  - Volume ramps from 0dB to -3dB
- **Crisis Layer**: High-stakes moments
  - Activates when strikes >50% of limit
  - Sharp, staccato elements
  - Distorted synth leads
  - Volume: -2dB (louder than base)

*Gameplay - Endless/Score Attack:*
- Upbeat, chiptune-style track (currently: chiptune_work_work_work_main.mp3)
- Emphasizes competitive nature
- Faster tempo: 120-140 BPM
- Volume: -10dB to maintain focus

*Narrative Scenes (Dialogic):*
- Contextual music per scene
- Fade transitions (2s) between tracks
- Lower volume (-15dB) to prioritize dialogue
- Emotional matching: tense, mysterious, hopeful

*Shift Summary:*
- **Success**: Triumphant fanfare (15s), then cheerful loop
- **Failure**: Somber, descending progression (10s), fade to silence
- **Perfect Performance**: Extra flourish, celebratory brass

**Music Implementation:**
- All tracks looped seamlessly
- Crossfade between layers: 1.5-2s
- Bus routing: "Music" bus (separate from SFX for volume control)
- Format: MP3 (OGG Vorbis for compatibility)

### Sound Effects Catalog

**UI Sounds:**

*Menu Navigation:*
- Hover: Subtle tick (mechanical switch) - 0.05s
- Click: Satisfying clunk (stamp impression) - 0.1s
- Back/Cancel: Softer click, slightly lower pitch
- Error/Disabled: Dull thud, no resonance
- Volume: -5dB (audible but not intrusive)

*Sliders/Adjustments:*
- Volume sliders: Tick sound every 5% increment
- Toggle switches: Mechanical flip sound
- Checkbox: Light tap

*Notifications:*
- Achievement unlock: Bright chime + whoosh (celebration)
- Citation warning: Single beep (cautionary)
- Strike issued: Alarm siren (2s, urgent)
- Message received: Typewriter ding

**Gameplay Sounds:**

*Document Handling:*
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

*Stamping:*
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

*Megaphone/Calling:*
- **Megaphone click**: Button press sound
  - Volume: -6dB
- **Megaphone broadcast**: Distorted "Next!" callout (potato voice)
  - Optional: Procedural potato voice generator
  - Volume: -4dB

*Booth Operations:*
- **Lever pull**: Mechanical chain sound (currently: chain 2.wav)
  - Duration: 1.5s
  - Volume: -10dB
- **Shutter open**: Metal grinding, upward pitch shift
  - Duration: 2s
  - Volume: -8dB
- **Shutter close**: Metal grinding, downward pitch shift
  - Duration: 2s
  - Volume: -8dB

*Potato Sounds:*
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

*Missile Defense:*
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

*X-Ray Scanner:*
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

*UV Lamp (Planned):*
- **Activate**: Switch click + bulb buzz
- **Secret revealed**: Mystery chord + sparkle
- **Deactivate**: Click, buzz fades

**Ambient Sounds:**

*Customs Office (Interior):*
- Low background hum (machinery, ventilation)
  - Continuous loop, -20dB
- Distant radio chatter (muffled)
  - Occasional bursts, unintelligible
  - Volume: -22dB
- Fluorescent light hum
  - Subtle, high frequency
  - Volume: -25dB

*Border Area (Exterior):*
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

*Queue Area:*
- Potato murmurs (crowd ambience)
  - Low, indistinct conversation
  - Volume scales with queue size
  - Base volume: -16dB

**Voice/Dialogue:**

*Dialogic Scenes:*
- **Typing effect**: Currently uses keyboard mechanical typing 1.mp3
  - **ISSUE**: Audio desync noted in GDD
  - **Fix**: Use Dialogic built-in typing sounds OR custom tailored files
  - Sync with text speed setting
  - Volume: 0dB (per current timeline, needs adjustment to -10dB)

*Potato Voices (Planned):*
- Procedural pitch-shifted vocal sounds
- Contextual emotional inflection
- Short phrases during document inspection
  - "Here's my papers..."
  - "Please, I need to get through..."
  - Terry Pratchett-inspired humor

*Supervisor Russet:*
- Distinct voice (lower pitch, authoritative)
- Radio filter effect (talking through intercom)
- Volume: -8dB

**Audio Buses & Mixing:**

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

**Player Controls:**
- Master volume slider (0-100%)
- Music volume slider (0-100%)
- SFX volume slider (0-100%)
- Voice volume slider (0-100%)
- Mute all toggle

### Audio Implementation Technical Details

**Audio Format:**
- Music: MP3 or OGG Vorbis (streaming)
- SFX: WAV (short samples, loaded into memory)
- Voice: OGG Vorbis (streaming for dialogue)

**Optimization:**
- Pool frequently used sounds (footsteps, document rustles)
- Limit simultaneous sound instances (max 32 active sounds)
- Distance-based volume attenuation for off-screen sounds
- Priority system: Feedback > Gameplay > Ambient

**3D Audio (Future Consideration):**
- Spatial audio for runner positions
- Panning for off-screen events
- Currently: Stereo 2D audio sufficient for scope

### Audio Feedback for Accessibility

**Visual Alternatives:**
- Subtitle system for all dialogue
- Visual indicators for off-screen sounds (directional arrows)
- Haptic feedback (Steam Deck / controller rumble)
  - Stamp placement: Short rumble
  - Strike: Strong rumble
  - Perfect combo: Pulsing rumble

**Audio Cues Settings:**
- Toggle to enhance critical audio (louder strikes, runners)
- Mono audio option (for hearing impairment)
- Reduce background ambience option (focus on gameplay sounds)

### Current Audio Gaps (From GDD Action Items)

**High Priority:**
- [ ] Fix keyboard audio desync in Dialogic scenes
- [ ] Add lever SFX for office shutter
- [ ] Add hover sounds for megaphone/stamp bar
- [ ] Add emote audio feedback
- [ ] Add document grip sound (pick up)
- [ ] Add whoosh sounds for document movement
- [ ] Add menu tick sounds for volume sliders

**Medium Priority:**
- [ ] Implement dynamic music layers (tension/crisis)
- [ ] Create potato voice system (procedural or recorded)
- [ ] Add X-ray scanner sounds
- [ ] Add UV lamp sounds
- [ ] Improve ambient sound mixing (radio broadcasts)

**Low Priority (Polish):**
- [ ] Add bird interaction sounds
- [ ] Add footstep variation based on potato type
- [ ] Add environmental reverb (interior vs exterior)
- [ ] Add subtle breathing sounds for waiting potatoes

### Environmental Details
- Birds on ground that fly away on interaction (sound: flapping + chirp)
- Animated lights in customs office and Border Wall (subtle hum)
- Footstep system (concrete steps smaller/darker than grass, louder/softer audio)
- Shift-start animation: Player potato walks into office (footsteps + door open)
- Shadow rendering fixes for new potato models (no audio impact)

---

## 6. Technical Implementation

### Core Requirements
- Godot 4 engine
- Steam integration
- **Steam Cloud Save**: Verification needed for correct path configuration
- Leaderboard system (per shift, per difficulty, score attack mode)

### Key Classes and Systems
```gdscript
# Core game management
class_name GameManager
var difficulty_level: String
var game_mode: String
var current_chapter: int

# Story system
class_name StoryManager
var current_arc: Dictionary
var player_choices: Array
var reputation: Dictionary

# Narrative tracking
class_name NarrativeManager
# CRITICAL: Ensure choice tracking properly saves/loads
var tracked_choices: Dictionary
var ending_criteria: Dictionary

# Potato processing
class_name ProcessingManager
var processing_time: float
var current_rules: Array
var validation_system: ValidationSystem

# Save system
class_name SaveManager
# Must include: narrative choices, customization, high scores
var player_progress: Dictionary
var narrative_state: Dictionary
var customization_data: Dictionary
```

### Performance Optimization Needs
- **Footprint System**: Implement sprite pooling (currently creates/destroys)
- **Particle Systems**: Add cleanup plan for dynamically created particles
- **Z-Index Management**: Multiple rendering order issues documented

### Critical Debug Controls

**Development Efficiency Tools**

Debug controls enable rapid testing and iteration during development. All debug features must be disabled in production builds.

**Core Debug Keybinds:**
- **F1** - Toggle debug overlay (FPS, memory usage, active nodes)
- **F2** - Skip current shift (instant win for testing progression)
- **F3** - Force shift failure (test fail states and retry flow)
- **F4** - Spawn test potato (bypasses queue timing)
- **F5** - Toggle god mode (unlimited strikes, infinite time)
- **F6** - Unlock all potato types (test visual variety)
- **F7** - Toggle free camera (inspect scene details)
- **F8** - Reload current scene (quick iteration on changes)
- **F9** - Toggle hitbox visualization (collision debugging)
- **F10** - Force runner spawn (test missile defense)
- **F11** - Fullscreen toggle (player-accessible)
- **F12** - Screenshot (player-accessible)

**Console Commands (Debug Build Only):**
```gdscript
# Shift progression
/skip_to_shift <number>     # Jump to specific shift
/reset_narrative            # Clear all story choices
/unlock_endings             # Enable all ending branches

# Scoring and stats
/set_score <amount>         # Override current score
/add_perfect_stamps <count> # Test combo bonuses
/reset_leaderboards         # Clear local leaderboard cache

# Potato spawning
/spawn_runner               # Force border runner
/spawn_sapper               # Force sapper variant
/spawn_vip                  # Force VIP potato
/spawn_invalid              # Force invalid documents

# Rule testing
/list_active_rules          # Print current shift rules
/add_rule <rule_id>         # Add specific rule to shift
/clear_rules                # Remove all rules (auto-approve mode)

# Performance testing
/stress_test <potato_count> # Spawn many potatoes
/profile_start              # Begin performance profiling
/profile_stop               # End profiling and dump results
/clear_pooled_objects       # Force cleanup of object pools

# Audio/visual debugging
/mute_sfx                   # Toggle sound effects
/mute_music                 # Toggle music
/show_z_indices             # Render z-index labels on nodes
/highlight_clickable        # Show all interactive areas

# Save/load testing
/force_save                 # Immediate save
/corrupt_save               # Test save corruption handling
/delete_save                # Clear all save data
/export_save                # Dump save JSON to file
```

**Debug Overlay Information:**
- Frame rate (current, average, minimum)
- Memory usage (current, peak)
- Active potato count
- Active particle emitters
- Current shift timer
- Active rules count
- Narrative variables state
- Steam connection status

**Build Configuration:**
```gdscript
# project.godot settings
[debug]
enabled = true              # Debug mode active
show_fps = true             # Display FPS counter
verbose_logging = true      # Extended console output
allow_remote_debug = true   # Godot editor debugging

[release]
enabled = false             # All debug features disabled
strip_debug_symbols = true  # Reduce build size
optimize_for_size = true    # Minimize executable size
```

**Testing Workflows:**

*Rapid Narrative Testing:*
1. Use `/skip_to_shift 9` to jump near endings
2. Use `/reset_narrative` to test different choice branches
3. Use `/unlock_endings` to verify all ending art/dialogue

*Performance Testing:*
1. Use `/stress_test 50` to spawn maximum potatoes
2. Enable F1 overlay to monitor frame rate
3. Use `/profile_start` and `/profile_stop` for detailed metrics
4. Use `/clear_pooled_objects` to test cleanup systems

*Rule Validation Testing:*
1. Use `/list_active_rules` to see current rules
2. Use `/spawn_invalid` to force rule violations
3. Test strike system with intentional failures
4. Use `/clear_rules` to test UI without rule complexity

**Prohibited in Release Builds:**
- All F-key debug shortcuts (except F11/F12 player features)
- Console command system entirely removed
- Debug overlay system disabled
- Verbose logging disabled
- God mode functionality removed
- Skip/cheat functions removed

**Debug Build Distribution:**
- Internal testing only
- Never distribute to press or players
- Clearly labeled "DEBUG BUILD" in main menu
- Auto-expiration after 30 days (build date check)
- Watermark on screenshots/recordings

### Critical Bugs to Address

#### Drag and Drop System (DaDS)
- Documents don't appear above other documents when dragged
- Can drag through stamps (should block)
- Passport visible above fade when shift ends
- Return-to-table buffers broken
- Documents released appear in front of suspect panel background
- Z-index system not working properly
- Cannot drag documents off suspect table to auto-close
- Cannot pick up documents through stamp bar

#### Z-Index Issues
- Corpses need lower z-index (behind explosions)
- Explosions appear above inspection table
- Footsteps appear above customs office
- Gibs appear below screen borders
- Potatoes appear above table instead of under

#### Office Shutter System
- No SFX for lever
- Potato transparency fade issues (foreground shadow only)
- Button click detection needs transparent pixel exclusion

#### Gameplay Bugs
- Accept then reject keeps accepted state
- Cannot launch missiles during tutorial (correct behavior)
- Leaderboards not loading in 1.1 Steam public_test build (**BLOCKING**)
- Pause menu music persists when returning to main menu from Dialogic scene

#### UI/Visual Bugs
- Tutorial images need updating for new UI
- Cursor returns to default after drag (should check hover)
- Target cursor not showing over missile area
- Stamps extend over passport edges (viewport masking needed)
- Documents show above suspect panel (viewport masking needed)

---

## 7. Quality Assurance & Testing Strategy

### Overview
Comprehensive testing strategy combining automated unit tests, manual acceptance testing, and continuous integration to ensure code quality and prevent regressions throughout development and post-launch support.

### Testing Framework
**GUT (Godot Unit Test) v9.3.0**
- Lightweight testing framework designed for Godot 4.x
- Installed at: `godot_project/addons/gut/`
- Configuration: `godot_project/.gutconfig.json`
- Test runner: `godot_project/tests/run_tests.gd`

### Test Structure
```
godot_project/tests/
├── unit/                           # Unit tests for individual systems
│   ├── test_shift_stats.gd        # ShiftStats bonus calculations
│   ├── test_stats_manager.gd      # Stamp accuracy checking
│   ├── test_law_validator.gd      # Rule validation and date logic
│   └── test_potato_factory.gd     # Character generation helpers
└── integration/                    # Future integration tests
    └── (planned for full gameplay flow testing)
```

### Unit Test Coverage

#### Core Systems Tested

**1. ShiftStats.gd** (`test_shift_stats.gd`)
- **Coverage Areas:**
  - Missile bonus calculation (150 points per perfect hit)
  - Accuracy bonus calculation (200 points per perfect stamp)
  - Speed bonus calculation (100 points per second remaining)
  - Total bonus aggregation
  - Stats reset functionality
- **Test Count:** 15+ test cases
- **Critical for:** Score calculation accuracy, bonus system integrity

**2. StatsManager.gd** (`test_stats_manager.gd`)
- **Coverage Areas:**
  - Stamp accuracy checking via rectangle intersection
  - Perfect placement detection (10% tolerance)
  - Edge case handling (boundaries, negative coordinates)
  - New stats instance creation
- **Test Count:** 12+ test cases
- **Critical for:** Combo system, player feedback accuracy

**3. LawValidator.gd** (`test_law_validator.gd`)
- **Coverage Areas:**
  - Age calculation from date of birth
  - Document expiration checking
  - Rule violation detection (condition, gender, country, race)
  - Conflicting rule resolution
  - Rule difficulty classification
- **Test Count:** 25+ test cases
- **Critical for:** Core gameplay mechanics, rule validation accuracy

**4. PotatoFactory.gd** (`test_potato_factory.gd`)
- **Coverage Areas:**
  - Random attribute generation (name, condition, race, sex, country)
  - Date generation (past and future)
  - Potato info structure validation
  - Asset loading (gibs, explosions)
- **Test Count:** 20+ test cases
- **Critical for:** Character variety, data integrity

### Test Execution

#### Local Testing
```bash
# Run all tests via Godot editor
cd godot_project
godot --editor

# Run tests via command line (CI/CD)
godot --headless --script res://tests/run_tests.gd
```

#### GitHub Actions Integration
**Workflow:** `.github/workflows/automated_tests.yml`
- **Name:** Automated Tests & Linting
- **Triggers:** Push to `main`, all pull requests
- **Environment:** Ubuntu latest

**Job 1: Static Code Analysis**
- **Tools:** GDScript Toolkit (gdformat, gdlint, gdradon)
- **Steps:**
  1. Checkout code
  2. Setup GDScript Toolkit
  3. Run gdformat --check (code formatting verification)
  4. Run gdlint (linting and style checks)
  5. Run gdradon cc (cyclomatic complexity analysis)
- **Scope:** `godot_project/scripts/` directory

**Job 2: Unit Tests** (runs after static checks pass)
- **Environment:** Godot 4.5.0 headless
- **Steps:**
  1. Checkout code
  2. Setup Godot 4.5.0
  3. Import project (resolve dependencies)
  4. Run GUT test suite
  5. Upload test results as artifacts
- **Failure Handling:** Workflow fails if any check or test fails, blocking merge

**Workflow:** `.github/workflows/static_checks.yml` (Legacy - can be deprecated)
- **Status:** Superseded by integrated workflow above
- **Recommendation:** Remove to avoid duplicate checks

### Manual Testing Requirements

#### Pre-Release Test Procedure
**Location:** `project_management/testing/prerelease_test_procedure.md`

**Coverage Areas:**
1. **Core Processing Flow**
   - Megaphone interaction and potato spawning
   - Document dragging and passport inspection
   - Stamp application (approved/rejected)
   - Office shutter and potato movement

2. **Game Systems**
   - Score calculation and display
   - Strike system (difficulty-based limits)
   - Timer functionality
   - Difficulty mode differences

3. **Rule Verification**
   - Rule generation and display
   - Implementation accuracy (5 rule types)
   - Violation detection consistency

4. **Queue Management**
   - Spawn timing and frequency
   - Path following and animations
   - Queue state management

5. **Visual Verification**
   - Texture loading and display
   - Animation playback
   - UI element updates
   - Particle effects

6. **Audio System**
   - Sound effect playback
   - Voiceover integration
   - Audio settings persistence

7. **Performance Testing**
   - Stress tests (maximum potatoes)
   - Memory usage monitoring
   - Frame rate stability

#### User Acceptance Testing
**Location:** `project_management/testing/userbob_web_test_guide.txt`
- Web build specific testing procedures
- User-facing bug reporting guidelines

### Test Maintenance Strategy

#### When to Write Tests
1. **New Feature Development:** Write unit tests for all new systems before implementation
2. **Bug Fixes:** Add regression tests for fixed bugs to prevent recurrence
3. **Refactoring:** Ensure existing tests pass before and after refactoring
4. **Pre-Release:** Run full manual test suite before Steam deployment

#### Test Coverage Goals
- **Target:** 80% coverage for core gameplay systems
- **Priority Systems:**
  - Score calculation and bonuses
  - Rule validation logic
  - State management and persistence
  - Document processing mechanics
  - Character generation and attributes

#### Future Test Expansion

**Integration Tests (Planned)**
- Full gameplay loop testing
- Save/load functionality
- Steam API integration (leaderboards, achievements)
- Multi-scene transitions
- Narrative choice persistence

**Performance Tests (Planned)**
- Frame rate benchmarking across difficulty levels
- Memory leak detection
- Asset loading optimization
- Particle system stress tests

### Continuous Integration Requirements

#### Build Requirements
- **Godot Version:** 4.5.0 (locked for consistency)
- **Platform:** Linux (Ubuntu latest for CI/CD)
- **Headless Mode:** Required for automated testing
- **Exit Codes:** Test runner must exit with code 0 (pass) or 1 (fail)

#### Merge Requirements
- ✅ **Static Code Analysis:** All checks pass (gdformat, gdlint, gdradon)
- ✅ **Unit Tests:** All automated tests pass (GUT test suite)
- ✅ **No Regressions:** No new orphan nodes warnings
- ✅ **Code Review:** Approval required for team contributions
- ✅ **GitHub Actions:** Both workflow jobs must complete successfully

### Testing Best Practices

#### Test Writing Guidelines
1. **Isolation:** Each test should be independent (use `before_each()` and `after_each()`)
2. **Clarity:** Descriptive test names (e.g., `test_get_missile_bonus_with_multiple_perfect_hits`)
3. **Coverage:** Test happy paths, edge cases, and error conditions
4. **Performance:** Keep individual tests fast (<100ms per test)
5. **Determinism:** Avoid flaky tests dependent on timing or randomness

#### Test Organization
- **Unit tests:** Test individual functions/methods in isolation
- **Integration tests:** Test interactions between systems
- **Acceptance tests:** Manual testing of user-facing features
- **Regression tests:** Prevent fixed bugs from reoccurring

### Known Testing Limitations

#### Systems Not Covered by Automated Tests
1. **Visual/UI Testing:** Requires manual verification
   - Stamp placement visual feedback
   - Animation smoothness
   - Color accuracy
   - Font rendering

2. **Audio Testing:** Requires manual verification
   - Sound effect playback timing
   - Audio mixing levels
   - Voiceover synchronization

3. **Performance Testing:** Requires profiling tools
   - Frame rate under load
   - Memory usage over time
   - Asset loading times

4. **Steam Integration:** Requires manual testing on Steam
   - Leaderboard uploads
   - Achievement unlocks
   - Cloud save synchronization

#### Mitigations
- **Manual Test Checklists:** Comprehensive pre-release procedure
- **User Acceptance Testing:** External testers for usability feedback
- **Performance Monitoring:** Periodic profiling sessions
- **Steam Beta Branch:** Test Steam features in `public_test` before release

### Post-Launch Testing Support

#### Hotfix Workflow
1. Identify critical bug via user reports
2. Write regression test reproducing the bug
3. Fix bug and verify test passes
4. Run full test suite to prevent new regressions
5. Deploy via Steam patch with patch notes

#### Community Feedback Integration
- Monitor Steam forums and GitHub issues for bug reports
- Prioritize bugs affecting core gameplay mechanics
- Add tests for frequently reported issues
- Document fixes in `steam_patch_notes/` directory

---

## 8. Steam Release Requirements

### Essential Features
- **Steam Cloud Saves** (verification needed)
- 10-15 Achievements (display in-game from menus)
- Global Leaderboards:
  - Per shift per difficulty
  - Score attack mode
  - Daily challenges
  - Top 3 + player position ±3

### Launch Content
- 40+ unique immigration rules
- **4 potato types** (progressive unlock)
- 3 difficulty levels
- 2-3 hour story campaign with **4 endings**
- Endless / Score Attack mode with progressive difficulty
- Daily challenges with leaderboards

### Price Point: $4.99
Justification:
- Unique gameplay mechanics
- Rich narrative content with multiple endings
- Multiple game modes
- Regular content updates
- Environmental storytelling elements

### Pre-Release Checklist
- Steam Cloud Save path verification
- Leaderboard functionality testing (all modes)
- Achievement unlock testing (narrative + stats-based)
- All 4 story endings playable
- Demo build testing before upload
- Deployment process documentation (Steam Depots via Web Builds)

### System Requirements

**Minimum Requirements:**
- **OS**: Windows 10 (64-bit), macOS 10.15+, Ubuntu 20.04+
- **Processor**: Intel Core i3 or equivalent
- **Memory**: 2 GB RAM
- **Graphics**: OpenGL 3.3 compatible GPU
- **Storage**: 500 MB available space
- **Sound Card**: DirectX compatible
- **Additional Notes**: Mouse required for gameplay

**Recommended Requirements:**
- **OS**: Windows 11 (64-bit), macOS 12+, Ubuntu 22.04+
- **Processor**: Intel Core i5 or equivalent
- **Memory**: 4 GB RAM
- **Graphics**: Dedicated GPU with 1GB VRAM
- **Storage**: 1 GB available space
- **Sound Card**: DirectX compatible
- **Additional Notes**: 1920x1080 resolution or higher recommended

**Supported Platforms:**
- Windows (primary)
- macOS (planned)
- Linux (planned)
- Web (HTML5 export for demos)

**Technical Requirements:**
- Internet connection required for:
  - Steam achievements
  - Global leaderboards
  - Daily challenges
  - Cloud saves
- Offline play available for Story Mode and Endless Mode (local scores only)

### Steam Store Materials Checklist

**Required Assets (Pre-Release):**
- [ ] **Capsule Images**
  - Main capsule: 616x353px
  - Small capsule: 231x87px
  - Header capsule: 460x215px
  - Vertical capsule: 374x448px
  - Hero capsule: 1920x620px

- [ ] **Screenshots**
  - Minimum 5 screenshots at 1920x1080
  - Showcase: Document inspection, missile defense, story moments, UI elements, different potato types
  - All must be actual in-game screenshots (no mockups)

- [ ] **Trailer**
  - 30-90 seconds recommended
  - Show core gameplay loop
  - Highlight unique mechanics (stamp combos, X-ray, missile defense)
  - Include narrative hook
  - Trailer script at: `project_management/spud_customs_trailer_1.md`

- [ ] **Store Description**
  - Short description (300 characters max)
  - Long description with feature bullets
  - About This Game section
  - Key features list
  - System requirements (see above)

- [ ] **Store Tags**
  - Primary: Simulation, Indie, Casual, Strategy
  - Secondary: Immigration, Time Management, Choices Matter, Multiple Endings
  - Thematic: Dark Humor, Dystopian, Story Rich, Singleplayer

- [ ] **Legal & Compliance**
  - Age rating justification (Teen - dark humor, mild violence)
  - Privacy policy (if collecting data)
  - EULA/Terms of Service
  - Attribution credits (see Credits section below)

- [ ] **Community Setup**
  - Discussion boards enabled
  - Workshop integration (optional - for user-created content)
  - Achievement showcase enabled
  - Trading cards (optional - future consideration)

- [ ] **Launch Checklist**
  - Steam Depot configured for Windows build
  - Demo build uploaded and tested
  - Wishlisting enabled 2+ weeks before launch
  - Press kit prepared
  - Social media accounts ready
  - Launch discount strategy (10% recommended)

---

## 9. Development Timeline

### Current Phase: Version 1.1.1 - Minor Update
**Target Release: 2025-04-20 for Full 1.1.0**

#### Immediate Priorities (Blocking Release)
1. **CRITICAL**: Fix leaderboards not loading in Steam public_test
2. Complete 4 ending branches (2 art + 4 dialogue each)
3. Fix Shift 10 narrative inconsistencies
4. Test Steam Cloud Save functionality
5. Test Demo changes before upload

#### Tutorial System Overhaul
- Replace hard-coded screenshots with dynamic tutorial
- Integrate seamlessly into Shift 1
- Updated images for new UI
- Gate raising tutorial step
- Runner warning tutorial with emotes
- Exploding runner tutorial update

#### Narrative Improvements
- Split Supervisor Russet dialogue in shift1_intro
- Fix fade timing in shift1_intro (too fast for brief dialogue)
- Split "I think I know what's happening..." dialogue
- Reword scanner warning text
- Bridge narrative gap in Shift 10
- Smooth Shift 4 ending transition
- Implement different dialogue font

#### Audio Fixes
- Fix keyboard audio desync (use Dialogic keystrokes or tailored files)
- Add lever SFX for office shutter
- Add hover sounds for megaphone/stamp bar
- Add emote audio feedback
- Add document grip sound
- Add whoosh sounds for document movement
- Add menu tick sounds for volume sliders

#### Graphics Improvements
- Viewport masking for documents/stamps
- Ink fleck particles from stamping
- Message queue system implementation
- Potato hover tooltips in queue
- Shift-start walk-in animation
- Cursor system updates (multiple fixes)
- Emote display improvements
- Physics on documents
- Potato breathing animation
- Environmental animations (lights, birds)
- Shadow alignment fixes

#### Gameplay Additions
- UV lamp scanning system
- Entry ticket documents
- Baggage inspection mini-game
- Sapper runner variants
- Approved potato kill penalties
- Random runner chance while in line
- Kill text position improvements
- Shift-based time display

### Phase 1: Core Development (Completed)
- Basic gameplay mechanics ✓
- Document system ✓
- Stamp mechanics ✓
- UI implementation ✓

### Phase 2: Story Integration (In Progress)
- Narrative system (needs choice tracking fixes)
- Cutscenes (needs fade improvements)
- Character development ✓
- Dialogue system (needs font change)
- **Multiple endings** (needs implementation)
- **Environmental storytelling** (needs progressive integration)

### Phase 3: Features & Polish (Ongoing)
- Mini-games (X-ray, baggage, interrogation in progress)
- Steam integration (leaderboard issues blocking)
- Achievements (needs in-game display)
- Bug fixing (extensive list documented)

### Phase 4: Testing & Launch
- Playtesting (narrative + stats achievements)
- Balance adjustments
- Final polish
- Steam store setup
- Accessibility features implementation

---

## 10. Post-Launch Support

### Month 1
- Critical bug fixes (extensive list documented)
- Performance optimization (particle/sprite pooling)
- Community feedback integration
- Localization: Chinese, Spanish, Portuguese, German

### Months 2-3
- New potato types (beyond initial 4)
- Additional rules and document types
- Quality of life improvements
- Multiplayer implementation exploration (co-op/versus)

### Long-term
- Regular content updates
- Seasonal events
- Community features
- Additional language localization
- Level select leaderboard viewing
- A* pathfinding for main menu potato lines

---

## 11. Known Issues & Action Items

### High Priority (Blocking Release)
1. **Leaderboards not loading in Steam public_test build** - CRITICAL
2. Steam Cloud Save verification incomplete
3. Multiple ending branches not implemented
4. Choice tracking system needs verification
5. Shift 10 narrative inconsistencies

### Medium Priority (Quality Issues)
1. Tutorial system uses outdated screenshots
2. Drag and Drop System has multiple critical bugs
3. Z-index rendering issues throughout
4. Shift 4 ending transition is jarring
5. Accessibility features missing (colorblind, font size, UI scaling)

### Low Priority (Polish)
1. Performance optimization needed (pooling systems)
2. Audio desync issues
3. Cursor behavior inconsistencies
4. Environmental animation additions
5. Emote system enhancements

### Documentation Gaps
- Major system interaction documentation needed
- Content addition guide (potatoes, rules, laws)
- Story flow and decision point visualization
- Steam deployment process documentation
- Pre-release testing checklist formalization

### Art Assets Needing Revision
- plant_revelation: Goopy potatoes need cleanup
- extreme_emergency: Washed out colors need adjustment
- Purple color matching in personal quarters
- Various cutscenes need Aseprite repainting (16-32 color palettes)

### Future Considerations
- Multiplayer implementation (Steam Matchmaking)
- Conversation system during document checking
- Alt-Enter and F11 fullscreen toggles
- Instructions overlay system
- Main menu potato pathfinding
- Enhanced shift summary animations
- Control scheme for keyboard navigation



# X-Ray Scanning System

## Overview
X-ray scanning reveals hidden contents within potatoes and their belongings using a special shader effect. This mechanic integrates seamlessly into the document processing flow, requiring no context switch from core gameplay.

## Core Mechanics
- **Activation**: Toggle X-ray mode via button/hotkey while inspecting a potato or their documents
- **Visual Feedback**: Special shader reveals internal structures, hidden objects, or secret messages
- **Detection Types**:
  - Contraband items (weapons, illegal goods)
  - Biological anomalies (disease markers, mutations)
  - Resistance messages (coded symbols, hidden text)
  - Story clues (narrative-relevant objects)

## Progressive Complexity
- **Early Shifts (2-3)**: Obvious contraband (clear weapon silhouettes)
- **Mid Shifts (4-6)**: Subtle differences requiring careful examination
- **Late Shifts (7-10)**: Multi-layered secrets, requires cross-referencing with other documents

## Gameplay Integration
- **Bonus Points**: Successful detection awards points without requiring rejection
- **Narrative Delivery**: Resistance movement communicates through hidden X-ray messages
- **Optional Discovery**: Not required for basic approval/rejection, rewards thorough players
- **Rule Combinations**: Some rules require X-ray confirmation (e.g., "Reject potatoes with metal implants")

## Scoring
- Contraband detection: +150 points
- Resistance message discovery: +100 points + story progression
- Biological anomaly detection: +200 points
- Missed detection (if rule requires it): Citation issued

## Player Experience Goals
- "Aha!" moments when discovering hidden content
- Feels like detective work, not busywork
- Rewards careful observation without punishing those who miss it (except when rules require it)
- Creates memorable story moments through environmental storytelling

---

# Citation and Strike System

## Two-Tier Consequence Framework

### Citations (Minor Violations)
**Definition**: Recoverable mistakes that accumulate warnings without immediately ending the shift.

**Examples**:
- Incorrect stamp placement outside designated area
- Missing secondary document verification
- Failed UV lamp detection when required
- Minor timing inefficiencies
- Accidentally killing unapproved runner (border defense bonus lost)

**Consequences**:
- Point deduction (-50 to -150 points depending on severity)
- Visual warning indicator (yellow triangle)
- Audio cue (warning beep)
- **3 citations = 1 strike** (threshold adjustable by difficulty)

### Strikes (Major Violations)
**Definition**: Critical failures that directly threaten shift completion.

**Examples**:
- Approving potato with forged documents
- Rejecting valid VIP or authorized personnel
- Killing approved potato with missile (-250 points + strike for Totneva Convention violation)
- Missing critical X-ray contraband when rule requires detection
- Processing expired/invalid documents

**Consequences**:
- Significant point deduction (-250 to -500 points)
- Visual warning indicator (red X or badge)
- Audio cue (alarm siren)
- **Reach strike limit = shift ends immediately**

## Difficulty-Based Limits

| Difficulty | Citation Threshold | Strike Limit |
|------------|-------------------|--------------|
| Easy       | 5 citations = 1 strike | 5 strikes maximum |
| Normal     | 3 citations = 1 strike | 3 strikes maximum |
| Hard       | 2 citations = 1 strike | 2 strikes maximum |

## Recovery Mechanics

### Performance-Based Recovery
- **Perfect Processing Streak**: 5 consecutive perfect approvals/rejections = remove 1 citation
- **Excellence Bonus**: 10 consecutive perfect potatoes = remove 1 strike
- **Detection Mastery**: Successful X-ray/UV contraband detection = remove 1 citation
- **Border Defense**: Killing unapproved runner = remove 1 citation

### Shift-Based Reset
- **Citations**: Clear completely at start of each shift (fresh start)
- **Strikes**: Maximum 2 strikes carry over to next shift (prevents compounding failure)
- **Story Moments**: Supervisor Russet may forgive strikes during key narrative beats

### Narrative Recovery Options
- **Resistance Favors**: Story choices may grant temporary immunity
- **Bribe System**: Spend points/resources to clear citations or strikes (morally gray choice)
- **Performance Reviews**: End-of-shift summaries may reduce penalties for overall good work

## Visual & Audio Feedback

### UI Display
```
Citation Counter: ⚠️⚠️⚠️ (0/3 before strike)
Strike Counter: ❌❌⚠️ (2 strikes used, 1 remaining)
```

### Messaging Examples
- **Citation Issued**: "MINOR VIOLATION: Incorrect stamp placement (-50 pts)"
- **Strike Issued**: "MAJOR VIOLATION: Approved VIP rejected - Strike issued!"
- **Citation Removed**: "PERFORMANCE BONUS: Citation cleared through excellent processing"
- **Strike Removed**: "EXCELLENCE ACHIEVED: Strike forgiven for outstanding performance"

### Audio Cues
- Citation warning: Single beep (recoverable)
- Strike alarm: Siren sound (serious consequence)
- Recovery chime: Pleasant notification (reward)
- Threshold warning: "2/3 citations" triggers cautionary tone

## Accessibility Options

### Forgiving Mode
Toggle in settings for players focused on story over challenge:
- Unlimited citations (warnings only, no strike accumulation)
- Strikes warn but don't end shift prematurely
- All penalties become point deductions only
- Maintains feedback without punitive consequences

### Visual Indicators
- Colorblind-friendly warning colors (shape + color differentiation)
- Adjustable warning opacity/size
- Optional persistent counter display vs. pop-up only

## Design Philosophy
**Goal**: Balance tension with forgiveness. Small mistakes feel different from catastrophic errors. Recovery is possible through skilled play, not just lucky circumstances. Players understand why they're being penalized and have clear paths to improve.

**Avoiding Papers, Please's Economic Pressure**: Instead of family-feeding stakes, this system creates immediate shift-based tension while allowing recovery within the same session. Shorter campaign (2-3 hours) requires faster feedback loops than Papers, Please's gradual economic decay.


# Steam Achievements

## Overview
13 achievements combining narrative progression milestones with gameplay skill challenges. Designed to encourage both story completion and mastery of game mechanics across different play styles.

## Achievement Categories

### Narrative Achievements (Story Progression)

#### First Day on the Job
**Description**: Complete your first shift  
**Unlock Rate**: ~1.2%  
**Type**: Introductory milestone  
**Notes**: Tutorial completion, ensures basic mechanics understood

#### Rookie Customs Officer
**Description**: Complete Shift 5  
**Unlock Rate**: ~1.2%  
**Type**: Mid-game progression checkpoint  
**Notes**: Tracks player retention through early-to-mid campaign

#### Veteran Officer
**Description**: Complete 10 shifts  
**Unlock Rate**: ~0.6%  
**Type**: Story completion (any ending)  
**Notes**: Marks full campaign playthrough

#### Master of Customs
**Description**: Complete 25 shifts  
**Unlock Rate**: ~0.6%  
**Type**: Extended play/replay milestone  
**Notes**: Encourages multiple playthroughs for different endings or endless mode engagement

### Story Ending Achievements (Multiple Playthrough Incentives)

#### Down with the Tatriarchy
**Description**: Complete the game with the revolution ending  
**Unlock Rate**: ~14.1%  
**Type**: Narrative choice outcome  
**Notes**: Join the resistance, overthrow the regime

#### Born Diplomat
**Description**: Complete the game with the diplomatic ending  
**Unlock Rate**: ~12.8%  
**Type**: Narrative choice outcome  
**Notes**: Navigate middle path, maintain neutrality

#### Tater of Justice
**Description**: Complete the game with the loyalist ending  
**Unlock Rate**: ~12.8%  
**Type**: Narrative choice outcome  
**Notes**: Remain loyal to the Tatriarchy government

#### Savior of Spud
**Description**: Complete the main game with any ending and reform the nation of Spud  
**Unlock Rate**: ~0.6%  
**Type**: "True" or best ending  
**Notes**: Most difficult ending to achieve, requires specific choices throughout campaign

### Skill-Based Achievements (Gameplay Mastery)

#### Best Served Hot
**Description**: Process a potato perfectly (no errors, perfect stamp placement)  
**Unlock Rate**: ~8.5%  
**Type**: Basic proficiency  
**Notes**: Early skill check, teaches precision

#### Border Defender
**Description**: Stop 50 total border runners  
**Unlock Rate**: ~1.2%  
**Type**: Mini-game mastery (missile defense)  
**Notes**: Cumulative across all playthroughs, encourages defensive play

#### Sharpshooter
**Description**: Successfully stop 10 border runners  
**Unlock Rate**: ~0.6%  
**Type**: Mini-game proficiency  
**Notes**: Subset of Border Defender, mid-tier missile defense milestone

#### Perfect Shot
**Description**: Get 5 perfect hits on border runners  
**Unlock Rate**: ~0.6%  
**Type**: Mini-game precision  
**Notes**: Rewards accuracy over volume, tracks direct hits vs. splash damage

### High Score Achievements (Competitive Play)

#### High Scorer
**Description**: Achieve a score of 10,000 points in a single shift  
**Unlock Rate**: ~0.6%  
**Type**: Score attack milestone  
**Notes**: Encourages efficiency and combo mastery in Story or Endless mode

#### Score Legend
**Description**: Achieve a score of 50,000 points  
**Unlock Rate**: ~0.6%  
**Type**: Elite score achievement  
**Notes**: Likely requires Endless mode or perfect Hard difficulty performance

## Achievement Design Philosophy

### Balanced Unlock Distribution
- **High unlock rate (8-14%)**: Story ending achievements encourage replayability
- **Medium unlock rate (1-2%)**: Progression milestones track engagement
- **Low unlock rate (0.6%)**: Mastery and skill-based achievements reward dedication

### Tracking Requirements
- **Cumulative achievements** (Border Defender, Sharpshooter): Track across all game sessions
- **Single-session achievements** (High Scorer, Perfect Shot): Must occur within one shift
- **Story achievements**: Tied to NarrativeManager choice tracking
- **Skill achievements**: Tied to ProcessingManager and gameplay metrics

### Player Motivation Goals
1. **Story Completion**: Multiple ending achievements drive replays
2. **Skill Improvement**: Progression from "Best Served Hot" → "Perfect Shot"
3. **Long-term Engagement**: Cumulative achievements reward persistent play
4. **Difficulty Mastery**: Score achievements naturally push toward harder modes

## In-Game Display Requirements
- Achievement list accessible from Main Menu and Pause Menu
- Show locked/unlocked status with progress bars where applicable
- Display unlock percentages (global player statistics)
- Visual indication of which ending achievements remain (spoiler-free icons)
- Notification system when achievements unlock during gameplay

## Technical Implementation Notes
- Steam API integration for unlock tracking
- SaveManager must persist achievement progress for cumulative types
- NarrativeManager must trigger ending achievements based on final choices
- ProcessingManager must track perfect placements, scores, and runner kills
- Achievement unlocks must sync with Steam Cloud for cross-device play

## Post-Launch Achievement Expansion
Potential additional achievements for content updates:
- New mini-game specific achievements (interrogation, baggage inspection mastery)
- Daily Challenge streaks
- Hidden/secret achievements for easter eggs
- Speedrun achievements (complete story under time limit)
- No-strike perfect run achievements

---

## 12. Credits and Attribution

### Development Team

**Lost Rabbit Digital**
- Lead Developer & Designer: [Name]
- Programming: [Name]
- Art & Animation: [Name]
- Narrative Design: [Name]
- Audio Design: [Name]
- QA & Testing: [Name]

### Special Thanks

**User Testing & Feedback**
- See `project_management/user_feedback/special_thanks.md` for full list
- Community testers who provided invaluable feedback during development

### Third-Party Assets & Tools

**Game Engine**
- **Godot Engine 4.5.0** - MIT License
  - https://godotengine.org
  - Copyright (c) 2014-2025 Godot Engine contributors

**Plugins & Addons**

*GodotSteam*
- MIT License
- https://github.com/CoaguCo-Industries/GodotSteam
- Steam API integration for achievements, leaderboards, and cloud saves

*Dialogic 2*
- MIT License
- https://github.com/dialogic-godot/dialogic
- Dialogue system and narrative scripting

*GUT (Godot Unit Test) v9.3.0*
- MIT License
- https://github.com/bitwes/Gut
- Unit testing framework

*GDScript Toolkit*
- MIT License
- https://github.com/Scony/godot-gdscript-toolkit
- Code formatting and linting (gdformat, gdlint, gdradon)

**Audio Assets**
- Music tracks: [Sources and licenses to be documented]
- Sound effects: [Sources and licenses to be documented]
- See `godot_project/assets/ATTRIBUTION.md` for complete audio attribution

**Fonts**
- [Primary UI Font] - [License]
- [Dialogue Font] - [License]
- [Score/Stats Font] - [License]

**Visual Assets**
- Custom artwork: Lost Rabbit Digital
- Stock/reference assets: [Sources to be documented]
- See `godot_project/assets/ATTRIBUTION.md` for complete visual attribution

### Inspiration & Influence

**Games**
- **Papers, Please** by Lucas Pope - Primary gameplay and moral choice inspiration
- Document inspection mechanics influence
- Bureaucratic dystopia themes

**Literature**
- **Terry Pratchett's Discworld Series** - Tonal inspiration for conversations and dark humor

**Historical References**
- Cold War border checkpoint aesthetics
- Bureaucratic dystopia themes

### Open Source Contributions

This project uses open-source software and gives back to the community:
- Bug reports and contributions to Godot Engine
- Contributions to GodotSteam
- Contributions to Dialogic
- Sharing of custom tools and techniques with the community

### Legal Notices

**Trademark Acknowledgments**
- Steam and the Steam logo are trademarks of Valve Corporation
- All other trademarks are property of their respective owners

**Asset Licenses**
- See `godot_project/assets/ATTRIBUTION.md` for detailed asset licensing
- All custom art and code (c) 2025 Lost Rabbit Digital
- Game code and assets license: [License TBD]

**Privacy & Data**
- Game collects minimal data (Steam ID, scores, achievements)
- No personal information stored beyond Steam requirements
- Cloud saves stored via Steam Cloud (Valve privacy policy applies)
- No third-party analytics or tracking

**Content Warning**
- Game contains dark humor and dystopian themes
- Mild violence (cartoonish potato explosions)
- Themes of authoritarianism and bureaucracy
- Age rating: Teen (13+)

### Contact & Support

**Official Channels**
- Website: [URL]
- Steam Store: [URL]
- Email: [Support email]
- Bug Reports: https://github.com/Lost-Rabbit-Digital/SpudCustoms/issues

**Social Media**
- Twitter/X: [@handle]
- Discord: [Server invite]
- Reddit: r/SpudCustoms

**Press & Media**
- Press Kit: [URL]
- Media Contact: [Email]
- Review Key Requests: [Email]

---

**Document Version**: 1.1.1 Update Revision
**Last Updated**: October 19, 2025
**Status**: Pre-Release (1.1.0 target: April 20, 2025)