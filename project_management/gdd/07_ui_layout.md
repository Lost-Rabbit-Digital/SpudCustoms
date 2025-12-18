# UI Layout - Comprehensive Design

> **Back to:** [GDD Index](README.md) | **Previous:** [Features & Systems](06_features_systems.md)

## Screen Hierarchy & Layout Strategy

### Design Philosophy

- Diegetic UI where possible (in-world elements like desk items, wall displays)
- Non-diegetic UI only for critical information (timer, quota, strikes)
- Minimalist HUD to maintain immersion
- Screen space optimized for 16:9 aspect ratio (1920x1080 native)

## Main Gameplay Screen (Customs Office)

### Screen Regions

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

### HUD Elements (Top Bar)

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

### Interactive Zones

#### Customs Booth Zone (Left Middle)

- Potato display area (animated breathing, emotes)
- Shutter lever for opening/closing booth
- Background elements (propaganda posters, lights)
- Hover tooltips when gate closed

#### Inspection Table Zone (Center Middle)

- Primary document interaction area
- Viewport masking to prevent documents leaving bounds
- Drop zones for organizing multiple documents
- Physics-enabled document stacking
- Visual feedback for correct/incorrect placement

#### Suspect Panel (Below Inspection Table)

- Secondary document area
- Gravity physics for dropped documents
- Easy retrieval for comparison
- Prevents clutter on main inspection table

#### Stamp Bar (Bottom Center)

- Retractable UI element
- Shows when clicked/hovered
- Two stamps: Approved (green checkmark), Rejected (red X)
- Perfect placement target indicators
- Ink particle effects on stamp

#### Rules Panel (Bottom Right)

- Scrollable list of active rules
- Collapsible to save screen space
- Highlight rule when hovering over relevant document field
- Checkmark next to verified rules

#### Megaphone (Bottom Left)

- Diegetic control to call next potato
- Hover sound effect
- Disabled state when booth closed or potato present
- Visual feedback (megaphone tilts/animates on click)

#### Missile Defense Zone (Top Right Background)

- Border wall with running potatoes
- Click anywhere on runner to launch missile
- Target cursor on hover
- Explosion particle effects
- Kill counter display

### Floating Feedback Elements

- Score popups appear above action locations
  - Stamp: +50, +100 (perfect)
  - Missile kill: +150
  - X-ray detection: +100
- Message queue for supervisor notifications
- Animated combos ("Perfect x3!")
- Citation/strike warnings (modal overlays)

## Menu Screens

### Main Menu Layout

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
│  v1.2.0            [Social Icons]  [Steam Icon] │
└─────────────────────────────────────────────────┘
```

### Pause Menu (In-Game Overlay)

- Semi-transparent background blur
- Centered modal panel
- Options: Resume, Settings, Main Menu, Quit
- Stats display (current shift performance)
- Achievement progress access

### Settings Menu

- Tabbed interface: Audio, Video, Controls, Accessibility
- Real-time preview for visual changes
- Volume sliders with tick sounds
- Keybind remapping interface
- Accessibility toggles (see AccessibilityManager)

### Help Menu ✓ (Implemented)

- Tabbed interface with multiple information sections
- **Lore Tab**: Game world backstory and setting information
  - History of the potato nation
  - Political context and factions
  - Character backgrounds
- Controls and gameplay instructions
- Accessible from main menu and pause menu

### Shift Summary Screen

- Full-screen results display
- Animated stat counters
- Performance rating (F to S rank)
- Golden stamp awards (0-3)
- Bonus breakdown with tooltips
- Leaderboard position (if connected)
- Continue/Retry/Main Menu buttons

### Achievement Screen

- Grid layout of achievement icons
- Locked/unlocked states
- Progress bars for cumulative achievements
- Unlock percentage from global stats
- Filter options (All, Locked, Unlocked)

## Accessibility Features (Managed by AccessibilityManager)

### UI Scaling

- 80%, 100%, 120%, 150% options
- Maintains aspect ratio and layout integrity
- Dynamic font resizing
- Adjusts clickable area sizes proportionally

### Colorblind Modes

- Protanopia (red-green)
- Deuteranopia (red-green)
- Tritanopia (blue-yellow)
- Stamp colors: Add patterns (stripes, dots) in addition to color
- UI elements use shape + color differentiation

### Font Options

- Small, Medium, Large, Extra Large
- Sans-serif default (high readability)
- Dyslexia-friendly font option
- Increased letter spacing option
- High contrast text backgrounds

### High Contrast Mode

- Increase border thickness on interactive elements
- Enhanced outlines on documents and UI
- Bright highlights on hover states
- Reduce background detail opacity

## Responsive Design Considerations

### Minimum Resolution: 1280x720

- UI scales proportionally
- Text remains readable
- All interactive elements maintain minimum 44x44px touch targets (for future mobile/Steam Deck)

### Ultrawide Support (21:9)

- Extend background artwork
- Keep HUD elements anchored to safe zones
- Center critical gameplay area
- Utilize extra space for decorative elements

### Steam Deck Optimization

- Larger UI elements by default
- Touch-friendly button sizes
- Readable fonts at 7-inch screen
- Optimized control scheme for gamepad

## Animation & Feedback

### UI Animations

- Button hover: Scale 1.0 → 1.05, duration 0.1s
- Button press: Scale 1.05 → 0.95, duration 0.05s
- Panel transitions: Slide + fade, duration 0.3s
- Notification popups: Bounce in, fade out after 3s
- Score counters: Incremental number animation, 0.5s duration

### Visual Feedback

- Hover: Brightness +20%, subtle glow
- Click: Flash effect, particle burst
- Disabled state: 50% opacity, desaturated
- Focus (keyboard nav): Colored outline, 2px width

### Audio Feedback (See Audio Design)

- Every interactive element has hover + click sounds
- Distinct sounds for positive/negative actions
- Volume scaling based on action importance

## Localization Support

### Text Expansion Allowances

- UI elements sized for 30% text expansion (German, Russian)
- Dynamic text wrapping where possible
- Icon-based UI for universal understanding
- Placeholder language flags in settings

### RTL Language Support (Future)

- Mirror UI layout for Arabic, Hebrew
- Maintain logical reading flow
- Test with placeholder RTL text

---

> **Next:** [Audio Design](08_audio_design.md)
