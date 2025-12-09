# Spud Customs - Narrative Analysis Report

**Generated:** December 2024
**Scope:** All 23 Dialogic timeline files, NarrativeManager.gd, NARRATIVE_VARIABLES.md, and GDD

---

## Executive Summary

This report identifies issues in the Dialogic variable handling, conditional branching logic, narrative transitions, and achievement coverage across the game's story mode.

**Key Findings:**
- 12 variables set but never used in downstream conditions
- 1 critical variable overwrite bug (viktor_conversation)
- QTE failure paths unreachable due to missing variable handling
- Harsh transitions between shifts 8→9 and 9→10
- All 8 endings technically reachable
- Only 4/12+ potential narrative achievements implemented
- GDD-listed "Savior of Spud" achievement not implemented

---

## 1. Variables Set But Never Read (Unused)

These variables create the illusion of choice but don't affect outcomes:

| Variable | Set In | Description |
|----------|--------|-------------|
| `scanner_response` | shift3_intro | "loyal"/"questioning" - no downstream effect |
| `reveal_reaction` | shift3_end | "shocked"/"cautious" - no effect |
| `hide_choice` | shift5_end | "desk"/"window" - makes no difference |
| `evidence_choice` | shift5_end | Only "chaos" branch matters |
| `follow_trucks` | shift7_intro | Sets `found_facility` but never checked |
| `found_facility` | shift7_intro | Never referenced |
| `yellow_badge_response` | shift7_intro | Never checked later |
| `sasha_plan_response` | shift6_intro | No influence on outcomes |
| `malfunction_excuse` | shift6_intro | Immediate effect only |
| `interrogation_response` | shift6_intro | Not used downstream |
| `final_mission_response` | shift10_intro | Immediate dialogue only |
| `loyalty_response` | shift5_intro | Immediate effect only |

**Recommendation:** Either add downstream consequences or remove these choices to avoid player disappointment.

---

## 2. Critical Bug: viktor_conversation Overwrite

**Location:** `shift6_end.dtl:21-34`

The variable `viktor_conversation` is set in shift6_intro (lines 75-80) with meaningful values:
- `tell_truth` (reveals Elena's fate, sets viktor_allied)
- `lie_protect` (keeps Viktor in the dark)

However, shift6_end.dtl OVERWRITES this with:
- `curious`
- `direct`

This erases the player's impactful choice about whether to tell Viktor the truth.

**Fix:** Use a different variable name in shift6_end (e.g., `viktor_night_conversation`) or remove the redundant choice.

---

## 3. QTE Failure Paths Unreachable

In `final_confrontation.dtl`:
- Line 61: `if {qte_rescue_result} == "fail":`
- Line 163: `if {qte_confrontation_result} == "fail":`

These conditions check variables that are **never set** by the signal system. The QTE emits signals but doesn't write results back to Dialogic variables.

**Impact:** Viktor's heroic intervention, Murphy's sacrifice, and machinery malfunction scenes are **unreachable**.

**Fix:** Modify QTE completion handler to set these variables before returning to dialogue.

---

## 4. Harsh Narrative Transitions

### 4.1 Shift 8 → Shift 9
- shift8_end: Emotional aftermath of Sasha's capture
- shift9_intro: Immediate "war zone" chaos with no transition

**Missing:** Passage of time indication, player reflection scene

### 4.2 Shift 9 → Shift 10
- "stay" path: Prime Minister visiting (peaceful)
- "go" path: Resistance attack preparation (chaotic)

**Issue:** No bridging content explaining the divergent outcomes.

### 4.3 Murphy's Cousin Reference (shift4_intro)
Dark humor about cousin being in Root Reserve comes before the player fully understands the horror.

---

## 5. Ending Reachability Matrix

| Ending | Path | Trigger Variable | Status |
|--------|------|------------------|--------|
| Revolution/Dismantle | go | `ending_choice == "dismantle"` | Reachable |
| Diplomatic | go | `ending_choice == "diplomatic"` | Reachable |
| Justice | go | `ending_choice == "justice"` | Reachable |
| Vengeance | go | `ending_choice == "vengeance"` | Reachable |
| Loyalist (Report) | stay | `final_loyalist_choice == "report"` | Reachable |
| Loyalist (Ignore) | stay | `final_loyalist_choice == "ignore"` | Reachable |
| Loyalist (Hope) | stay | `final_loyalist_choice == "hope"` | Reachable |
| Romantic | go | `sasha_rescue_reaction == "relieved"` + `pro_sasha_choice >= 3` | Reachable |

### pro_sasha_choice Accumulation Points (10 total):
1. shift4_end:111 - "I believe you. How can I help?"
2. shift5_intro:24 - "I'm in. Let's expose the truth."
3. shift5_end:75 - "Hand over everything"
4. shift6_intro:106 - "It's worth the risk. I'm in."
5. shift7_end:81 - "I'll do whatever it takes"
6. shift7_end:125 - "I'll help them cross"
7. shift8_end:88 - "Catch Sasha's eye and nod - a promise"
8. shift9_intro:55 - "Process them through"
9. shift9_intro:97 - "I've been complicit for too long"
10. final_confrontation:27 - "I've already sacrificed everything"

**Note:** Threshold of 3 may be too easy. Consider raising to 5.

### Chaos Agent Path Issue
`chaos_agent` and `chaos_points` are set but never checked. No unique chaos ending exists.

---

## 6. Achievement Coverage Analysis

### Currently Implemented (4):
- `born_diplomat` - Diplomatic ending
- `tater_of_justice` - Justice ending
- `best_served_hot` - Vengeance ending
- `down_with_the_tatriarchy` - Dismantle ending

### Signals Exist But Not Mapped to Steam:
- `achievement_complicit` - Loyalist dark ending (report resistance)
- `achievement_late_bloomer` - Loyalist hope ending (leave yellow mark)

### GDD-Listed But Not Implemented:
- **Savior of Spud** - Described as "most difficult/true ending" but no trigger exists

### Recommended Additional Achievements:

**Character Arc (3):**
| Achievement | Trigger | Description |
|-------------|---------|-------------|
| `tommy_remembered` | `murphy_alliance == "ally"` at end | Honor Murphy's sacrifice |
| `truth_teller` | `viktor_conversation == "tell_truth"` | Tell Viktor about Elena |
| `note_keeper` | `kept_note == "yes"` at end | Keep the mysterious note |

**Loyalist Path (2):**
| Achievement | Trigger | Description |
|-------------|---------|-------------|
| `heart_of_stone` | Loyalist + report new resistance | Darkest ending |
| `late_bloomer` | Loyalist + leave yellow mark | Redemption ending |

**Discovery (2):**
| Achievement | Trigger | Description |
|-------------|---------|-------------|
| `root_of_evil` | Reach processing plant scene | Witness the horror |
| `chaos_architect` | `chaos_points >= 4` | Play both sides |

---

## 7. Priority Fixes

### Critical (P0):
1. Fix viktor_conversation overwrite bug
2. Add QTE result variable handling
3. Implement "Savior of Spud" achievement
4. Map loyalist signals to Steam achievements

### High (P1):
5. Add transition scenes (shift8→9, shift9→10)
6. Create chaos agent ending or acknowledgment
7. Resolve player_captured path consequences

### Medium (P2):
8. Add consequences for unused variables
9. Raise pro_sasha_choice threshold to 5
10. Add character arc achievements
11. Add milestone/discovery achievements

---

## 8. Files Modified for This Analysis

**Read Only - No Modifications Made:**
- All 23 .dtl files in `godot_project/assets/narrative/`
- `godot_project/assets/narrative/NARRATIVE_VARIABLES.md`
- `godot_project/scripts/systems/NarrativeManager.gd`
- `project_management/spud_customs_design_document.md`

---

## Appendix: Complete Variable Cross-Reference

See `godot_project/assets/narrative/NARRATIVE_VARIABLES.md` for the full variable tracking table.
