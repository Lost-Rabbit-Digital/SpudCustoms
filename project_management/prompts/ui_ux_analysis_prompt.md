# Spud Customs - Comprehensive UI/UX Analysis Prompt

> **Purpose:** Systematic evaluation of the game's user interface and user experience to identify confusion points, accessibility gaps, and improvement opportunities.
>
> **Target Audience:** Playtesters, UX analysts, developers, or AI assistants reviewing the game.

---

## Instructions for the Analyst

You are conducting a comprehensive UI/UX analysis of **Spud Customs**, a dystopian document thriller game where players act as customs officers processing potato citizens. Your goal is to identify:

1. **Confusion Points** - Where players get lost, stuck, or misunderstand mechanics
2. **Accessibility Gaps** - Barriers for players with disabilities or varied needs
3. **Feedback Failures** - Missing, unclear, or overwhelming feedback
4. **Friction Areas** - Unnecessary difficulty in accomplishing tasks
5. **Consistency Issues** - Violations of established patterns
6. **Improvement Opportunities** - Enhancements that would meaningfully improve the experience

For each issue found, provide:
- **Location**: Where in the game (menu, shift, specific interaction)
- **Severity**: Critical / Major / Minor / Enhancement
- **Description**: What the problem is
- **User Impact**: How this affects the player experience
- **Recommendation**: Suggested fix or improvement

---

## Part 1: First-Time User Experience (FTUE) Analysis

### 1.1 Initial Launch & Main Menu

Evaluate the player's very first moments with the game:

- [ ] Is the main menu immediately understandable?
- [ ] Are primary actions (Start Game, Continue, Options) clearly prioritized visually?
- [ ] Is language selection discoverable and accessible?
- [ ] Does the visual design communicate the game's tone (dystopian, document thriller)?
- [ ] Are social/community links appropriately positioned (not distracting from core actions)?
- [ ] Is the version number displayed for support/bug reporting purposes?
- [ ] Does any post-processing (bloom, effects) interfere with readability?
- [ ] How long does loading take, and is progress communicated?

### 1.2 Tutorial Onboarding (Shift 1)

The tutorial system includes 7 sequential tutorials covering core mechanics. Evaluate:

**Pacing & Flow:**
- [ ] Do tutorials auto-advance too quickly for comfortable reading?
- [ ] Can players who read slowly or are distracted recover context?
- [ ] Is the tutorial interruptible if the player accidentally interacts with game elements?
- [ ] Does the progress indicator ("Tutorial 1 of 7") help orientation?

**Clarity of Instructions:**
- [ ] Is each instruction specific enough to act on? (e.g., "Click to open stamp bar" - click WHAT?)
- [ ] Are controller/keyboard prompts dynamically shown based on input device?
- [ ] Is terminology consistent with in-game labels?
- [ ] Are visual highlights clearly pointing to the correct elements?

**Skip Functionality:**
- [ ] Are "Skip This Tutorial" and "Skip All Tutorials" buttons clearly differentiated from "Next/Continue"?
- [ ] Is the consequence of skipping explained?
- [ ] Can tutorials be re-enabled later?

**Missing Tutorial Coverage:**
- [ ] Are border runners (chase minigame) explained before players encounter them?
- [ ] Are date/expiration mechanics taught?
- [ ] Are all stamping outcomes (perfect, good, poor) explained?

### 1.3 First Shift Experience

- [ ] Does the first potato interaction feel intuitive?
- [ ] Is the document inspection flow (pick up → open → check rules → stamp) discoverable?
- [ ] Are the stakes (strikes, quota) clearly communicated?
- [ ] Does the player understand what happens on shift completion?

---

## Part 2: Core Gameplay UX Analysis

### 2.1 Document Processing Flow

This is the primary gameplay loop. Evaluate each step:

**Calling Potatoes (Megaphone):**
- [ ] Is the megaphone's purpose obvious?
- [ ] Is there feedback when clicked (visual, audio)?
- [ ] Can players accidentally call multiple potatoes?

**Gate Control (Shutter Lever):**
- [ ] Is the lever's function clear without tutorial?
- [ ] Is the interaction satisfying (feedback, animation)?
- [ ] Are there any timing issues with gate opening/closing?

**Document Inspection:**
- [ ] Can documents be picked up intuitively (drag? click?)?
- [ ] Is passport opening discoverable (click to open)?
- [ ] Can all passport information be read at default UI scale?
- [ ] Is text legible with dyslexia-friendly font enabled?
- [ ] Does any text overflow or clip (e.g., "Condition: Dehydrated")?

**Rules Checking:**
- [ ] Is the laws/rules book easy to access?
- [ ] Can players compare rules to passport while both are visible?
- [ ] Is current day/date visible for expiration checking?
- [ ] Are rules written in plain, understandable language?

**Stamping:**
- [ ] Is the stamp bar discoverable and easy to open?
- [ ] Is the stamp placement guide clear (where to position documents)?
- [ ] Is "perfect stamp" detection accurate and fair?
- [ ] Can players understand why a stamp was imperfect?
- [ ] Is stamp feedback satisfying (sound, visual, celebration)?

**Document Return:**
- [ ] Is it clear how to return documents to the potato?
- [ ] What happens if documents are dropped in the wrong place?
- [ ] Is there feedback confirming successful return?

### 2.2 Feedback Systems

**Score Feedback:**
- [ ] Is score displayed prominently enough?
- [ ] Are score increases clearly associated with actions?
- [ ] Is the scoring system understandable?

**Strike Feedback:**
- [ ] Are strikes highly visible and alarming?
- [ ] Is the reason for each strike clearly communicated?
- [ ] Is strike text colored appropriately (red for danger)?
- [ ] Can players understand how to avoid future strikes?

**Perfect Hit Celebrations:**
- [ ] Is the celebration noticeable but not disruptive?
- [ ] Do screen flash, particles, and sound feel rewarding?
- [ ] Can celebrations be disabled for players who find them overwhelming?

**Tension System:**
- [ ] Does escalating tension (color tint, audio) communicate danger?
- [ ] Is the transition between tension levels smooth?
- [ ] Can the tension overlay be disabled for accessibility?

**Alert Messages:**
- [ ] Are positive/negative alerts clearly distinguishable?
- [ ] Is alert text readable at all font sizes?
- [ ] Do alerts persist long enough to be read?
- [ ] Do alert sounds match their positive/negative nature?

### 2.3 Minigames

The game includes 7 minigames. For each, evaluate:

**Quick Time Events (QTE):**
- [ ] Are button prompts readable and large enough?
- [ ] Is timing fair at all difficulty levels?
- [ ] Are accessibility options (reduced prompts, extended time) working?
- [ ] Is the auto-complete option discoverable?

**Stamp Sorting:**
- [ ] Can the sorting criteria be understood without color vision?
- [ ] Are symbols/patterns used in addition to colors?

**Fingerprint Match:**
- [ ] Is the matching interface intuitive?
- [ ] Is success/failure clearly indicated?

**Code Breaker:**
- [ ] Are color-based indicators accessible to colorblind players?
- [ ] Is the logic puzzle explained sufficiently?

**Border Chase (Missile System):**
- [ ] Can good/bad targets be distinguished without color alone?
- [ ] Is the missile hitbox fair (not too large/small)?
- [ ] Are controls responsive?
- [ ] Is there tutorial coverage for first-time players?

**Evidence Destruction:**
- [ ] Is the destruction mechanic clear?
- [ ] Is feedback satisfying?

**Document Scanner:**
- [ ] Is the scanning interface intuitive?
- [ ] Is success/failure clearly communicated?

---

## Part 3: Menu & Navigation Analysis

### 3.1 Pause Menu

- [ ] Does ESC/Start button open pause reliably?
- [ ] Are all options visible without scrolling?
- [ ] Can players easily return to gameplay?
- [ ] Does "Return to Main Menu" warn about unsaved progress?

### 3.2 Options Menu

**Video Settings:**
- [ ] Are all settings understandable to non-technical users?
- [ ] Is camera shake intensity easily adjustable?
- [ ] Are there settings that don't apply (e.g., anti-aliasing for pixel art)?
- [ ] Do changes apply immediately or require confirmation?

**Audio Settings:**
- [ ] Are volume sliders clearly labeled?
- [ ] Can dialogue/voice volume be adjusted separately from SFX?
- [ ] Is there audio preview when adjusting sliders?

**Input Settings:**
- [ ] Is rebinding intuitive?
- [ ] Are default controls shown?
- [ ] Is controller/keyboard switching automatic?
- [ ] Can players reset to defaults?

**Game Settings:**
- [ ] Does the tutorial toggle work correctly?
- [ ] Does "Reset Game Data" function as expected?
- [ ] Are any settings explained with tooltips?

**Accessibility Settings:**
- [ ] Are all colorblind modes available and working?
- [ ] Is UI scaling range sufficient (80%-150%)?
- [ ] Is font size adjustment effective?
- [ ] Is high contrast mode impactful?
- [ ] Is dyslexia-friendly font available and readable?
- [ ] Are QTE accessibility presets discoverable?

### 3.3 Level Select Menu

- [ ] Is shift progression clear (which shifts are available)?
- [ ] Can players easily see their previous narrative choices?
- [ ] Is the Sasha trust indicator understandable?
- [ ] Can players replay any unlocked shift?

### 3.4 Help Menu

- [ ] Does the help menu cover all mechanics?
- [ ] Is text readable and well-formatted?
- [ ] Are visual references (screenshots, sprites) included?
- [ ] Is terminology consistent with in-game labels?
- [ ] Are there accessibility issues in help content (color-only information)?

---

## Part 4: Visual Hierarchy & Consistency

### 4.1 Z-Index Layering

Check for correct visual stacking:

- [ ] Do open documents appear above closed documents?
- [ ] Does the passport appear above the inspection table elements?
- [ ] Does the laws book appear at the correct layer?
- [ ] Do UI overlays (tutorials, alerts) appear above game elements?
- [ ] Are there any elements "leaking" through layers unexpectedly?

### 4.2 Color Usage

- [ ] Is approval consistently green and rejection consistently red?
- [ ] Are colorblind-friendly alternatives used for all color-coded information?
- [ ] Is important text color consistent across the UI?
- [ ] Are interactive elements visually distinct from decorative elements?

### 4.3 Typography

- [ ] Is font size consistent for similar UI elements?
- [ ] Is text legible against all backgrounds?
- [ ] Are fonts appropriate for a dystopian document thriller tone?
- [ ] Does text scale correctly at all UI scale settings?

### 4.4 Interactive Element States

For buttons, levers, and interactive objects:
- [ ] Is hover/focus state visible?
- [ ] Is pressed/active state visible?
- [ ] Is disabled state clearly different from enabled?
- [ ] Are interactive elements distinguishable from static elements?

---

## Part 5: Input & Control Analysis

### 5.1 Keyboard & Mouse

- [ ] Are all actions achievable with keyboard/mouse?
- [ ] Are keyboard shortcuts consistent with conventions?
- [ ] Is drag-and-drop intuitive and responsive?
- [ ] Are click targets large enough?

### 5.2 Controller Support

- [ ] Does the game detect controller connection automatically?
- [ ] Are button prompts correct for the detected controller type (Xbox, PlayStation, Nintendo)?
- [ ] Is menu navigation intuitive with d-pad/stick?
- [ ] Is focus management reliable (no lost focus)?
- [ ] Is haptic feedback meaningful and configurable?

### 5.3 Steam Deck Compatibility

- [ ] Does the game run well on Steam Deck?
- [ ] Are touch controls available?
- [ ] Are controls remappable via Steam Input?
- [ ] Is text readable at Steam Deck resolution?

---

## Part 6: Accessibility Deep Dive

### 6.1 Visual Accessibility

- [ ] **Colorblind Modes:** Do all three modes (Protanopia, Deuteranopia, Tritanopia) function correctly?
- [ ] **High Contrast:** Does high contrast mode improve readability for low vision users?
- [ ] **UI Scaling:** Is the UI usable at 80% and 150% scale?
- [ ] **Font Sizing:** Is text readable at all size options?
- [ ] **Screen Shake:** Can screen shake be reduced or disabled?
- [ ] **Flashing:** Are there any rapidly flashing elements that could trigger photosensitive reactions?

### 6.2 Motor Accessibility

- [ ] Can the game be played one-handed?
- [ ] Are there timed elements that cannot be adjusted?
- [ ] Is QTE accessibility sufficient (auto-complete, extended time)?
- [ ] Are click targets large enough for players with tremors?

### 6.3 Cognitive Accessibility

- [ ] Is tutorial pacing adjustable?
- [ ] Are instructions clear and unambiguous?
- [ ] Is there a pause function available at all times?
- [ ] Are rules displayed persistently or easily referenced?
- [ ] Is there an option to reduce information density?

### 6.4 Auditory Accessibility

- [ ] Are subtitles available for all dialogue?
- [ ] Are important audio cues also communicated visually?
- [ ] Is there a separate dialogue/voice volume control?
- [ ] Are sound effects distinguishable from background music?

---

## Part 7: Localization Analysis

### 7.1 Text Display

- [ ] Does text fit in allocated UI space in all supported languages?
- [ ] Are there any untranslated strings?
- [ ] Are number and date formats localized correctly?
- [ ] Are right-to-left languages (Arabic) properly supported?

### 7.2 Cultural Considerations

- [ ] Are any images or symbols culturally inappropriate for target regions?
- [ ] Are game mechanics (document types, rules) culturally neutral?
- [ ] Is humor/tone preserved across translations?

---

## Part 8: Error Prevention & Recovery

### 8.1 Preventing Mistakes

- [ ] Are destructive actions (return to menu, reset data) confirmed?
- [ ] Can accidental stamp applications be undone?
- [ ] Are players warned before making narrative choices with consequences?
- [ ] Is auto-save frequent enough to prevent progress loss?

### 8.2 Recovering from Mistakes

- [ ] Can players restart the current shift?
- [ ] Is it clear how to recover from a failed shift?
- [ ] Are save slots available for manual saves?
- [ ] Can tutorials be replayed if needed?

---

## Part 9: Narrative & Dialogue UX

### 9.1 Dialogic Integration

- [ ] Is dialogue text readable and appropriately paced?
- [ ] Can players skip or fast-forward dialogue they've seen?
- [ ] Is dialogue history accessible?
- [ ] Does skipping dialogue cause any visual glitches (floating characters, missing backgrounds)?

### 9.2 Choice Presentation

- [ ] Are narrative choices clearly presented?
- [ ] Is the consequence of choices understandable?
- [ ] Is choice history visible in level select?
- [ ] Are path indicators (Resistance, Loyalist, Chaos) clear?

---

## Part 10: Performance & Polish

### 10.1 Loading & Transitions

- [ ] Are loading times communicated with progress indication?
- [ ] Are scene transitions smooth (no flashes of wrong content)?
- [ ] Is shader caching handled gracefully?

### 10.2 Animation & Juice

- [ ] Are UI animations smooth and purposeful?
- [ ] Do interactive elements have satisfying feedback?
- [ ] Are there any stuck animations or tweens?
- [ ] Is the "juice" balanced (not overwhelming, not too subtle)?

---

## Analysis Output Template

For each issue found, document using this format:

```markdown
### Issue: [Brief Title]

| Field | Value |
|-------|-------|
| **Location** | [Menu/Shift/Interaction where issue occurs] |
| **Severity** | Critical / Major / Minor / Enhancement |
| **Category** | [Confusion, Accessibility, Feedback, Friction, Consistency, Polish] |

**Description:**
[Detailed description of the issue]

**User Impact:**
[How this affects players]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Expected vs Actual behavior]

**Recommendation:**
[Suggested fix or improvement]

**Priority:** [High / Medium / Low]
```

---

## Summary Checklist

After completing the analysis, rate each area:

| Area | Rating (1-5) | Critical Issues | Notes |
|------|--------------|-----------------|-------|
| First-Time Experience | | | |
| Tutorial System | | | |
| Core Gameplay Loop | | | |
| Feedback Systems | | | |
| Minigames | | | |
| Menu Navigation | | | |
| Visual Consistency | | | |
| Input Support | | | |
| Accessibility | | | |
| Localization | | | |
| Error Handling | | | |
| Narrative UX | | | |
| Polish & Performance | | | |

**Overall UX Score:** ___ / 5

**Top 3 Priority Issues:**
1.
2.
3.

**Top 3 Quick Wins:**
1.
2.
3.

---

## Known Issues Reference

The following issues have already been identified in playtesting. Verify their current status:

1. **Tutorial timing** - Auto-advances too quickly
2. **Z-index layering** - Multiple stacking issues with documents and UI
3. **Strike text color** - Shows green instead of red
4. **Stamp bar highlight** - Not working correctly in tutorial
5. **Reset game data** - Button non-functional
6. **Help menu** - Missing visual references and proper formatting
7. **Color-only minigames** - Stamp Sorting, Code Breaker, Border Chase need symbols
8. **Text overflow** - "Condition: Dehydrated" exceeds bounds
9. **Dialogue skip bug** - Skipping during history view causes visual issues
10. **Post-processing** - Main menu bloom too aggressive

---

*This prompt was generated for Spud Customs v1.2.0 (December 2025)*
