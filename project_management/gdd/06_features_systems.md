# Features & Systems

> **Back to:** [GDD Index](README.md) | **Previous:** [Progression Time Targets](05_progression_timing.md)

## Core Systems

### 1. Document Processing

- Passport verification
- Rule checking (40+ unique immigration rules at launch)
- Stamp application with visual feedback for combos
- Time management
- **New Documents**: Entry tickets, work permits, visas, marriage licenses, baggage
- **Viewport Masking**: Prevents stamps outside passport boundaries
- **Physics System**: Documents have gravity on suspect panel

### 2. Mini-games (5 Integrated)

Mini-games unlock progressively through story mode shifts, each offering unique gameplay variety:

#### Document Scanner (UV Light) - Shift 1

- Drag UV light around documents to reveal hidden elements
- Click to mark discovered elements for bonus points
- Relaxing puzzle with no punishment for missing elements

#### Stamp Sorting - Shift 2

- Fast-paced sorting game with stamps falling from above
- Drag stamps to correct bin (APPROVED or DENIED)
- Rewards quick decisions and accuracy

#### Fingerprint Match - Shift 3

- Reference fingerprint shown, find match from grid of 6 options
- Tests observation skills without frustrating difficulty
- Time bonus for quick matches

#### Code Breaker - Shift 4

- Mastermind-style code guessing game (4-digit codes)
- Wordle-style feedback: position-specific color hints
- Maximum 6 attempts per code

#### Border Chase - Shift 5

- Quick reaction game on scrolling conveyor belt
- Click contraband items before they escape
- Satisfying "punt" animation for caught items
- Avoid clicking approved items

### Additional Gameplay Systems

- **Border Runner Defense**: Missile system to intercept fleeing potatoes
  - Killing approved potatoes: -250 points + strike (Totneva Convention violation)
- **Document Physics**: Gravity-based interaction on suspect panel

### 3. Progression System

- Character customization (hats, badges) - persistence via SaveManager
- **4 unlockable potato types** (down from 10):
  - Start: Russet only
  - Progressive unlock: New type every few shifts in story mode
- New rules and mechanics unlock
- Story achievements (in-game display from Main Menu and Pause Menu)
- Office/booth customization (saved in SaveManager)

### 4. Emote System

- Potatoes display emotional responses:
  - Exclamation marks when missiles fired
  - Anger (POPPING_VEINS) when clicked 3+ times
  - Chance distribution skewed toward angry/confused
- Audio feedback for emotes
- Tooltips on hover showing potato info

### 5. Visual Feedback Systems

- Animated score counters (incremental number display)
- Scores appear above respective actions
- Ink flecks from stamping
- Message queue system with delays (prevents override)
- Potato bobbing animation while walking
- Breathing animation for potato in office
- Slight wiggle animation for potatoes in queue
- Enhanced wiggle when clicked

### 6. Tension Management System

- **TensionManager autoload** monitors game state for near-failure conditions
- Tension levels: CALM → WARNING → DANGER → CRITICAL
- Visual feedback:
  - Screen tint overlay shifts from normal to red as strikes accumulate
  - Pulsing effects during critical state
- Haptic feedback escalation at tension transitions
- Integration with EventBus signals for decoupled architecture

### 7. Celebration System

- **Perfect hit celebrations** for stamps and runner stops
- Effects include:
  - Screen flash (0.15s duration)
  - Slowmo effect (0.25s at 0.5x speed)
  - Zoom punch (1.03x with bounce)
  - Golden particle burst (12 particles)
  - Celebration sound
  - Haptic feedback

### 8. Contextual Bubble Dialogue

- Officer provides dynamic commentary based on game events
- Trigger categories with chance-based activation:
  - Perfect stamp (70% chance)
  - Runner stopped (60% chance)
  - Runner escaped (80% chance)
  - Wrong stamp (50% chance)
  - Strike received (90% chance)
- Localized messages with fallbacks

## UI/UX Elements

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

> **Next:** [UI Layout](07_ui_layout.md)
