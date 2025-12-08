# Spud Customs - Narrative Variables & Cutscene Images

This document tracks all Dialogic variables used across timelines and the cutscene images needed for the enhanced narrative.

---

## Variable Tracking for Save/Load & Level Select

All variables below should be persisted when saving game state and restored when loading or selecting a level from level select.

### Core Story Choices (Must Persist)

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `initial_response` | shift1_intro | "eager", "questioning" | shift1_end, shift2_end | Player's response to Russet on day 1 |
| `note_reaction` | shift1_end | "investigate", "destroy", "report" | shift7_end | How player handled the mysterious note |
| `kept_note` | shift1_end | "yes", "no" | shift7_end | Whether player kept the note |
| `reported_note` | shift1_end | "yes" | shift7_end | Whether player showed note to Russet |
| `family_response` | shift3_intro | "refuse", "help" | shift4_end, shift7_end, loyalist | Whether player promised to help find missing wife |
| `has_wife_photo` | shift3_intro | "yes", "no" | shift4_end, shift7_end, final | Whether player took Maris Piper's photo |
| `wife_name` | shift3_intro | "Maris Piper" | shift7_end, final | Name of the missing wife |
| `stay_or_go` | shift9_intro | "stay", "go" | shift9_end, shift10, final | Major branching choice - join resistance or stay loyal |
| `ending_choice` | final_confrontation | "diplomatic", "justice", "vengeance", "dismantle" | final_confrontation | How player confronts Idaho |

### Murphy (Fellow Officer) Arc

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `murphy_trust` | shift2_end | "open", "guarded" | shift4_end | Initial conversation with Murphy |
| `murphy_alliance` | shift4_end | "ally", "cautious", "skeptical" | shift6_end, shift7_end, shift8_end, final | Whether Murphy is an ally |
| `murphy_final_alliance` | shift8_end | "committed", "hesitant" | shift9_intro | Murphy's commitment before the attack |

### Viktor (Guard) Arc

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `viktor_conversation` | shift6_end | "curious", "direct" | shift6_end | Initial conversation with Viktor |
| `viktor_allied` | shift6_end | "yes" | shift8_end, final | Whether Viktor helped at scanner |
| `has_keycard` | shift8_end | "yes" | shift9_intro | Viktor gave player security keycard |

### Resistance Choices

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `scanner_response` | shift3_intro | "loyal", "questioning" | - | Response to Russet about troublemakers |
| `reveal_reaction` | shift3_end | "shocked", "cautious" | - | Reaction to Root Reserve truth |
| `sasha_investigation` | shift5_intro | "committed", "hesitant" | - | Agreement to help Sasha's heist |
| `hide_choice` | shift5_end | "desk", "window" | - | How player hid during heist |
| `sasha_trust_level` | shift4_end | "committed", "cautious" | shift5_intro | Trust level with Sasha |
| `helped_operative` | shift6_end | "yes", "no" | shift6_end | Whether player helped resistance operative |
| `betrayed_resistance` | shift6_end | "yes" | shift8_intro | If player betrayed operative to scanner |
| `resistance_mission` | shift7_end | "committed", "hesitant", "cautious" | shift7_end | Response to Sasha's mission request |
| `final_decision` | shift7_end | "help", "passive", "undecided" | shift7_end | Commitment to helping resistance agents |
| `resistance_trust` | final_confrontation | "diplomatic", "committed" | final_confrontation | How player addresses resistance doubt |

### Shift 8 - Sasha's Capture

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `sasha_response` | shift8_intro | "cautious", "concerned" | shift8_intro | Response to news of Sasha's absence |
| `interrogation_choice` | shift8_intro | "deny", "betray" | shift8_end | Response to Security Chief interrogation |
| `sasha_arrest_reaction` | shift8_end | "intervene", "hide", "promise" | shift9_intro | Response to witnessing Sasha's arrest |
| `player_wanted` | shift8_end | "yes" | shift9_intro | Player is now wanted by security |
| `player_captured` | shift8_end | "yes" | shift8_end, shift9_intro | Player was captured with Sasha |

### Shift 9 - Rescue & Attack

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `critical_choice` | shift9_intro | "help", "betray" | shift9_intro | Help or betray resistance operative |
| `sasha_rescue_reaction` | shift9_end | "angry", "disgusted", "relieved" | final_confrontation | Reaction to seeing Sasha on conveyor |

### Cafeteria Choices

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `eat_reserve` | shift2_end | "ate", "refused" | shift4_end | Whether player ate Root Reserve |
| `cafeteria_response` | shift4_intro | "serious", "avoid" | shift4_end | Response to dark humor about Root Reserve |

### Loyalist Path Variables

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `fellow_officer_response` | shift6_intro | "cautious", "sympathetic", "loyal" | shift6_intro | Response to officer talking about pamphlets |
| `fellow_officer_response_2` | shift10_intro | "cautious", "sympathetic" | shift10_intro | Response during Idaho's visit |
| `interrogation_response` | shift6_intro | "lie", "legal" | shift6_intro | Response during interrogation |
| `loyalty_response` | shift5_intro | "patriotic", "idealistic" | shift5_intro | Response during loyalty screening |
| `accept_medal` | loyalist_ending | "accept", "reluctant" | loyalist_ending | Response to Idaho's medal |
| `eat_final` | loyalist_ending | "eat", "refuse" | loyalist_ending | Whether player eats "Resistance Blend" |
| `final_loyalist_choice` | loyalist_ending | "report", "ignore", "hope" | loyalist_ending | Final choice about yellow emblems |

---

## New Cutscene Images Needed

### High Priority (Core Story)

| Filename | Scene | Description |
|----------|-------|-------------|
| `sasha_quarters_raid.png` | shift8_end | Security forces kicking down Sasha's door at night |
| `sasha_arrest.png` | shift8_end | Sasha being dragged away by guards, defiant expression |
| `player_confronts_guards.png` | shift8_end | Player stepping forward to confront guards (reckless choice) |
| `wife_photo.png` | shift3_intro | Close-up of worn photo showing Maris Piper |
| `memorial_wall.png` | final_confrontation | Wall covered in photos of the processed - memorial |
| `cafeteria_evening.png` | shift2_end | Checkpoint cafeteria at evening, officers eating Root Reserve |
| `storage_room.png` | shift4_end, shift8_end | Small storage room for private conversations |

### Medium Priority (Supporting Scenes)

| Filename | Scene | Description |
|----------|-------|-------------|
| `conveyor_rescue.png` | shift9_end | Sasha bound on processing conveyor, player rushing to save her |
| `idaho_arrival.png` | loyalist_ending | Prime Minister Idaho stepping out of armored vehicle |
| `loyalist_ceremony.png` | loyalist_ending | Player receiving Golden Tuber medal |
| `victory_feast.png` | loyalist_ending | Hollow celebration feast with Root Reserve |
| `sasha_memory.png` | loyalist_ending | Dreamlike image of Sasha for guilt scene |
| `loyalist_future.png` | loyalist_ending | Player in comfortable office, looking hollow |
| `loyalist_office.png` | loyalist_ending | Regional Inspector's office - comfortable but cold |
| `yellow_emblem.png` | loyalist_ending | Yellow spud emblem scratched into wall |
| `loyalist_end_dark.png` | loyalist_ending | Dark ending - player fully complicit |
| `loyalist_end_neutral.png` | loyalist_ending | Neutral ending - player passive |
| `loyalist_end_hope.png` | loyalist_ending | Hopeful ending - player leaves yellow mark |
| `loyalist_final.png` | loyalist_ending | Final scene for loyalist path |

### Lower Priority (Polish)

| Filename | Scene | Description |
|----------|-------|-------------|
| `root_reserve_can_closeup.png` | various | Disturbing close-up of Root Reserve can/label |
| `murphy_breakdown.png` | shift4_end | Murphy emotional in storage room |
| `viktor_portrait.png` | shift6_end | Guard Viktor's haunted face |

---

## Implementation Notes

### Variable Persistence for Level Select

When implementing level select, ensure these variables are:
1. Saved to the save file when game is saved
2. Loaded from save file when continuing
3. Reset to appropriate defaults when starting a new shift from level select

**Suggested approach for level select:**
- Store variables in `SaveManager` as a dictionary
- When player selects a level, check if they have a save with variables
- If yes, offer to continue with existing choices or start fresh
- If starting fresh, set reasonable defaults based on the level:
  - Levels 1-4: All variables unset (player makes fresh choices)
  - Levels 5+: Require prior save OR set "committed" defaults

### Variable Validation

Some variables depend on others. Add validation:
- `has_wife_photo` requires `family_response == "help"`
- `kept_note` and `reported_note` are mutually exclusive
- `viktor_allied` only possible if `helped_operative == "yes"`
- `sasha_rescue_reaction` only set in "go" path

---

## Timeline Flow Reference

```
shift1_intro → shift1_end →
shift2_intro → shift2_end →
shift3_intro → shift3_end →
shift4_intro → shift4_end →
shift5_intro → shift5_end →
shift6_intro → shift6_end →
shift7_intro → shift7_end →
shift8_intro → shift8_end →
shift9_intro → shift9_end →
shift10_intro →
    ├── [stay_or_go == "stay"] → loyalist_ending
    └── [stay_or_go == "go"] → final_confrontation
```
