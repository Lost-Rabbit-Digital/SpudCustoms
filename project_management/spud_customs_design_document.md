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

### Environmental Details
- Birds on ground that fly away on interaction
- Animated lights in customs office and Border Wall
- Footstep system (concrete steps smaller/darker than grass)
- Shift-start animation: Player potato walks into office
- Shadow rendering fixes for new potato models

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
- **Triggers:** Push to `main`, all pull requests
- **Environment:** Ubuntu latest with Godot 4.5.0
- **Steps:**
  1. Checkout code
  2. Setup Godot 4.5.0
  3. Import project (resolve dependencies)
  4. Run GUT test suite
  5. Upload test results as artifacts
- **Failure Handling:** Workflow fails if any test fails, blocking merge

**Workflow:** `.github/workflows/static_checks.yml` (Existing)
- **Purpose:** Code quality (gdformat, gdlint, gdradon)
- **Scope:** `godot_project/scripts/` directory
- **Complements:** Automated tests with static analysis

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
- ✅ All unit tests pass
- ✅ Static checks pass (gdformat, gdlint, gdradon)
- ✅ No new orphan nodes warnings
- ✅ Code review approval (for team contributions)

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

**Document Version**: 1.1.1 Update Revision
**Last Updated**: October 19, 2025
**Status**: Pre-Release (1.1.0 target: April 20, 2025)