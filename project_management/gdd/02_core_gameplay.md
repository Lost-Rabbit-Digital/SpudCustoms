# Core Gameplay

> **Back to:** [GDD Index](README.md) | **Previous:** [Game Overview](01_game_overview.md)

## Basic Mechanics

- Document inspection and verification
- Time-pressured decision making
- Stamp-based approval/rejection system
- Consequence-driven progression
- Missile defense system against border runners
- X-ray scanning for hidden messages/contraband

## Difficulty Levels

### Easy Mode
- 8 potato target score
- 5 strikes allowed
- 12 minute shift time

### Normal Mode
- 10 potato target score
- 3 strikes allowed
- 10 minute shift time

### Hard Mode
- 12 potato target score
- 2 strikes allowed
- 8 minute shift time

## Scoring System

- Perfect stamp placements award combo multipliers
- Missile kills on runners award points (negative points if approved potato killed)
- X-ray scanning detection awards bonus points

---

## X-Ray Scanning System

### Overview

X-ray scanning reveals hidden contents within potatoes and their belongings using a special shader effect. This mechanic integrates seamlessly into the document processing flow, requiring no context switch from core gameplay.

### Core Mechanics

- **Activation**: Toggle X-ray mode via button/hotkey while inspecting a potato or their documents
- **Visual Feedback**: Special shader reveals internal structures, hidden objects, or secret messages
- **Detection Types**:
  - Contraband items (weapons, illegal goods)
  - Biological anomalies (disease markers, mutations)
  - Resistance messages (coded symbols, hidden text)
  - Story clues (narrative-relevant objects)

### Progressive Complexity

- **Early Shifts (2-3)**: Obvious contraband (clear weapon silhouettes)
- **Mid Shifts (4-6)**: Subtle differences requiring careful examination
- **Late Shifts (7-10)**: Multi-layered secrets, requires cross-referencing with other documents

### Gameplay Integration

- **Bonus Points**: Successful detection awards points without requiring rejection
- **Narrative Delivery**: Resistance movement communicates through hidden X-ray messages
- **Optional Discovery**: Not required for basic approval/rejection, rewards thorough players
- **Rule Combinations**: Some rules require X-ray confirmation (e.g., "Reject potatoes with metal implants")

### Scoring

- Contraband detection: +150 points
- Resistance message discovery: +100 points + story progression
- Biological anomaly detection: +200 points
- Missed detection (if rule requires it): Citation issued

### Player Experience Goals

- "Aha!" moments when discovering hidden content
- Feels like detective work, not busywork
- Rewards careful observation without punishing those who miss it (except when rules require it)
- Creates memorable story moments through environmental storytelling

---

## Citation and Strike System

### Two-Tier Consequence Framework

#### Citations (Minor Violations)

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

#### Strikes (Major Violations)

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

### Difficulty-Based Limits

| Difficulty | Citation Threshold | Strike Limit |
|------------|-------------------|--------------|
| Easy       | 5 citations = 1 strike | 5 strikes maximum |
| Normal     | 3 citations = 1 strike | 3 strikes maximum |
| Hard       | 2 citations = 1 strike | 2 strikes maximum |

### Recovery Mechanics

#### Performance-Based Recovery

- **Perfect Processing Streak**: 5 consecutive perfect approvals/rejections = remove 1 citation
- **Excellence Bonus**: 10 consecutive perfect potatoes = remove 1 strike
- **Detection Mastery**: Successful X-ray/UV contraband detection = remove 1 citation
- **Border Defense**: Killing unapproved runner = remove 1 citation

#### Shift-Based Reset

- **Citations**: Clear completely at start of each shift (fresh start)
- **Strikes**: Maximum 2 strikes carry over to next shift (prevents compounding failure)
- **Story Moments**: Supervisor Russet may forgive strikes during key narrative beats

#### Narrative Recovery Options

- **Resistance Favors**: Story choices may grant temporary immunity
- **Bribe System**: Spend points/resources to clear citations or strikes (morally gray choice)
- **Performance Reviews**: End-of-shift summaries may reduce penalties for overall good work

### Visual & Audio Feedback

#### UI Display

```
Citation Counter: ⚠️⚠️⚠️ (0/3 before strike)
Strike Counter: ❌❌⚠️ (2 strikes used, 1 remaining)
```

#### Messaging Examples

- **Citation Issued**: "MINOR VIOLATION: Incorrect stamp placement (-50 pts)"
- **Strike Issued**: "MAJOR VIOLATION: Approved VIP rejected - Strike issued!"
- **Citation Removed**: "PERFORMANCE BONUS: Citation cleared through excellent processing"
- **Strike Removed**: "EXCELLENCE ACHIEVED: Strike forgiven for outstanding performance"

#### Audio Cues

- Citation warning: Single beep (recoverable)
- Strike alarm: Siren sound (serious consequence)
- Recovery chime: Pleasant notification (reward)
- Threshold warning: "2/3 citations" triggers cautionary tone

### Accessibility Options

#### Forgiving Mode

Toggle in settings for players focused on story over challenge:
- Unlimited citations (warnings only, no strike accumulation)
- Strikes warn but don't end shift prematurely
- All penalties become point deductions only
- Maintains feedback without punitive consequences

#### Visual Indicators

- Colorblind-friendly warning colors (shape + color differentiation)
- Adjustable warning opacity/size
- Optional persistent counter display vs. pop-up only

### Design Philosophy

**Goal**: Balance tension with forgiveness. Small mistakes feel different from catastrophic errors. Recovery is possible through skilled play, not just lucky circumstances. Players understand why they're being penalized and have clear paths to improve.

**Avoiding Papers, Please's Economic Pressure**: Instead of family-feeding stakes, this system creates immediate shift-based tension while allowing recovery within the same session. Shorter campaign (2-3 hours) requires faster feedback loops than Papers, Please's gradual economic decay.

---

> **Next:** [Story Mode](03_story_mode.md)
