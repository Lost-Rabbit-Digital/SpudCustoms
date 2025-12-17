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
| `murphy_alliance` | shift4_end | "ally", "cautious", "skeptical", "hostile" | shift6_end, shift7_end, shift8_end, final | Whether Murphy is an ally (hostile = loyalist rejection) |
| `murphy_final_alliance` | shift8_end | "committed", "hesitant" | shift9_intro | Murphy's commitment before the attack |
| `murphy_farewell` | final_confrontation | "desperate", "pleading", "shock" | final_confrontation | Player's reaction when Murphy walks toward the Amalgam |
| `murphy_memorial` | final_confrontation | "honor", "grief", "determined", "numb" | final_confrontation | Player's response after Murphy's sacrifice |

**Murphy's Sacrifice Sequence** (triggers if `murphy_alliance == "ally"`):
- Idaho releases "Protocol HARVEST" - The Amalgam monster emerges
- Murphy recognizes his cousin Tommy was distilled into the RR-UTIL-7 canister he's been carrying
- Player is restrained by resistance members while Murphy sacrifices himself
- Murphy's sacrifice wounds but doesn't kill the monster
- Chain reaction of Extra Distilled tanks brings down the refinery tower
- "Tommy started the fire. The lost ones finished it."

### Viktor (Guard) Arc

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `viktor_initial_response` | shift5_intro | "sympathetic", "distant" | shift5_intro | Player's first response to Viktor asking about his wife |
| `viktor_wife_discovery` | shift5_end | "yes" | shift6_intro | Player found Elena Petrov on manifest (always set in shift5_end) |
| `viktor_conversation` | shift6_intro | "tell_truth", "lie_protect" | shift6_end, shift7_end | How player told Viktor about Elena |
| `viktor_allied` | shift6_intro | "yes" | shift7_end, shift8_end, final | Whether Viktor became an ally (set if player tells truth) |
| `viktor_comfort` | shift7_end | "comfort", "strength", "honest" | shift7_end | How player comforted Viktor at grief scene |
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

### Path Tracking Variables

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `pro_sasha_choice` | multiple | integer (0-10) | final_confrontation | Counter for pro-Sasha/resistance choices (3+ needed for romantic ending) |
| `loyalist_path` | shift4_end, shift10_intro | "yes" | shift10_intro, loyalist_ending | Whether player chose loyalist options |
| `loyalist_points` | multiple | integer | loyalist_ending | Counter for self-interest/loyalist choices |
| `chaos_agent` | shift5_end, shift7_end, shift9_intro | "yes" | endings | Whether player is on chaos agent path (sabotage both sides) |
| `chaos_points` | multiple | integer (0-6) | endings | Counter for chaos agent choices (play both sides against each other) |

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

### Path Tracking Variables

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `pro_sasha_choice` | Multiple | integer (0-10) | final_confrontation | Counter for pro-resistance choices, 5+ needed for Savior of Spud |
| `loyalist_path` | shift4_end | "yes", "no" | shift10_intro | Whether player is on loyalist path |
| `loyalist_points` | Multiple | integer | loyalist_ending | Counter for loyalist actions |
| `chaos_agent` | shift5_end, shift7_end | "yes", "no" | final_confrontation | Whether player is playing both sides |
| `chaos_points` | Multiple | integer (0-6) | final_confrontation | Counter for chaos actions (4+ for Chaos Architect) |
| `player_captured` | shift8_end | "yes", "rescued" | shift9_intro | Whether player was captured and rescued |

### QTE Result Variables (Set by NarrativeManager)

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `qte_rescue_result` | final_confrontation | "pass", "fail" | final_confrontation | Result of Sasha rescue QTE |
| `qte_confrontation_result` | final_confrontation | "pass", "fail" | final_confrontation | Result of final confrontation QTE |
| `qte_escape_result` | shift9_intro | "pass", "fail" | shift10_intro | Result of escape QTE |
| `qte_infiltration_result` | shift7_intro | "pass", "fail" | shift7_intro | Result of infiltration QTE |
| `qte_scanner_result` | shift6_intro | "pass", "fail" | shift6_intro | Result of scanner fake QTE |
| `qte_surveillance_result` | shift7_intro | "pass", "fail" | shift7_intro | Result of surveillance QTE |
| `qte_suppression_result` | loyalist_ending | "pass", "fail" | loyalist_ending | Result of suppression QTE |

### Additional UI Variables

| Variable | Set In | Possible Values | Used In | Description |
|----------|--------|-----------------|---------|-------------|
| `viktor_night_greeting` | shift6_end | "curious", "direct" | shift6_end | Viktor's night greeting (fixed: was overwriting viktor_conversation) |

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

### Murphy's Sacrifice Sequence (High Priority - Protocol HARVEST)

| Filename | Scene | Description |
|----------|-------|-------------|
| `idaho_bunker_monitors.png` | final_confrontation | Idaho in bunker watching security feeds, finger on Protocol HARVEST button |
| `amalgam_emergence.png` | final_confrontation | Floor exploding upward, tendrils reaching from Sub-Level 3 |
| `amalgam_reveal.png` | final_confrontation | HERO SHOT - The Amalgam fully revealed, frozen faces in its mass |
| `team_horror.png` | final_confrontation | Resistance fighters reacting in terror to the monster |
| `murphy_recognition.png` | final_confrontation | Murphy touching his "roots grow deep" tattoo, dawning realization |
| `murphy_canister.png` | final_confrontation | Murphy's hands holding RR-UTIL-7 canister - Tommy in a can |
| `amalgam_advance.png` | final_confrontation | The Amalgam lurching forward, blocking path to Idaho |
| `player_restrained.png` | final_confrontation | POV shot - player's arms held back, Murphy walking away |
| `murphy_stand.png` | final_confrontation | Wide shot - Murphy alone facing massive monster (Kong parallel) |
| `murphy_arms_spread.png` | final_confrontation | ICONIC - Murphy arms spread, canister raised, facing the Amalgam |
| `murphy_sacrifice_explosion.png` | final_confrontation | Murphy hurling canister, initial explosion beginning |
| `purple_explosion.png` | final_confrontation | Full Extra Distilled detonation, Murphy silhouetted |
| `amalgam_wounded.png` | final_confrontation | Monster still standing but burning - sacrifice wasn't enough |
| `chain_reaction.png` | final_confrontation | Burning Amalgam crashing into refinery tanks |
| `tower_collapse.png` | final_confrontation | Refinery tower collapsing onto the Amalgam |
| `massive_explosion.png` | final_confrontation | HERO EXPLOSION - All tanks detonating, dawn breaking through |
| `aftermath_rubble.png` | final_confrontation | Quiet aftermath, smoking rubble, path to Idaho clear |

**Reference:** Kong: Skull Island (2017) - Cole's sacrifice scene
**See:** `project_management/imagen_prompts_murphy_sacrifice.md` for detailed generation prompts

### Lower Priority (Polish)

| Filename | Scene | Description |
|----------|-------|-------------|
| `root_reserve_can_closeup.png` | various | Disturbing close-up of Root Reserve can/label |
| `murphy_breakdown.png` | shift4_end | Murphy emotional in storage room |
| `viktor_portrait.png` | shift6_end | Guard Viktor's haunted face |
| `idaho_aide.png` | final_confrontation | Nervous bureaucratic aide to Idaho (character portrait) |

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
- `viktor_allied` requires `viktor_conversation == "tell_truth"` (player must reveal Elena's fate)
- `viktor_conversation` requires `viktor_wife_discovery == "yes"` (manifest must be found in shift5_end)
- `viktor_comfort` requires `viktor_allied == "yes"` (grief scene only if allied)
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
