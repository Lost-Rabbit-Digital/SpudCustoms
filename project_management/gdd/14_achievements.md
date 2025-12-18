# Steam Achievements

> **Back to:** [GDD Index](README.md) | **Previous:** [Post-Launch Support](13_post_launch.md)

## Overview

21 achievements combining narrative progression milestones, character arc completions, and gameplay skill challenges. Designed to encourage story exploration, meaningful choices, and mastery of game mechanics across different play styles.

## Achievement Categories

### Narrative Achievements (Story Progression) - 4 Achievements

#### First Day on the Job
- **Steam ID**: `first_day_on_the_job`
- **Description**: Complete your first shift
- **Unlock Rate**: ~1.2%
- **Type**: Introductory milestone
- **Notes**: Tutorial completion, ensures basic mechanics understood

#### Rookie Customs Officer
- **Steam ID**: `rookie_customs_officer`
- **Description**: Complete Shift 5
- **Unlock Rate**: ~1.2%
- **Type**: Mid-game progression checkpoint
- **Notes**: Tracks player retention through early-to-mid campaign

#### Veteran Officer
- **Steam ID**: `customs_veteran`
- **Description**: Complete 10 shifts
- **Unlock Rate**: ~0.6%
- **Type**: Story completion (any ending)
- **Notes**: Marks full campaign playthrough

#### Master of Customs
- **Steam ID**: `master_of_customs`
- **Description**: Complete 25 shifts
- **Unlock Rate**: ~0.6%
- **Type**: Extended play/replay milestone
- **Notes**: Encourages multiple playthroughs for different endings or endless mode engagement

### Story Ending Achievements (Resistance Path) - 4 Achievements

#### Down with the Tatriarchy
- **Steam ID**: `down_with_the_tatriarchy`
- **Description**: Complete the game by dismantling Root Reserve infrastructure
- **Unlock Rate**: ~14.1%
- **Type**: Narrative choice outcome
- **Trigger**: `ending_choice == "dismantle"` in final_confrontation
- **Notes**: Focus on destroying the system rather than the people

#### Born Diplomat
- **Steam ID**: `born_diplomat`
- **Description**: Complete the game by negotiating a peaceful transition
- **Unlock Rate**: ~12.8%
- **Type**: Narrative choice outcome
- **Trigger**: `ending_choice == "diplomatic"` in final_confrontation
- **Notes**: Navigate middle path, attempt to preserve relationships

#### Tater of Justice
- **Steam ID**: `tater_of_justice`
- **Description**: Complete the game by demanding Idaho's arrest and trial
- **Unlock Rate**: ~12.8%
- **Type**: Narrative choice outcome
- **Trigger**: `ending_choice == "justice"` in final_confrontation
- **Notes**: Pursue legal accountability for the regime's crimes

#### Best Served Hot
- **Steam ID**: `best_served_hot`
- **Description**: Complete the game by enacting vigilante justice on Idaho
- **Unlock Rate**: ~8.5%
- **Type**: Narrative choice outcome
- **Trigger**: `ending_choice == "vengeance"` in final_confrontation
- **Notes**: Take matters into your own hands - revenge ending

### Story Ending Achievements (Loyalist Path) - 3 Achievements

#### Heart of Stone
- **Steam ID**: `heart_of_stone`
- **Description**: Complete the loyalist path and report the new resistance
- **Unlock Rate**: ~3.0%
- **Type**: Narrative choice outcome (darkest ending)
- **Trigger**: `stay_or_go == "stay"` AND `final_loyalist_choice == "report"`
- **Notes**: Fully commit to the regime even after knowing the truth

#### Survivor
- **Steam ID**: `survivor`
- **Description**: Complete the loyalist path by looking the other way
- **Unlock Rate**: ~5.0%
- **Type**: Narrative choice outcome
- **Trigger**: `stay_or_go == "stay"` AND `final_loyalist_choice == "ignore"`
- **Notes**: Neither help nor hinder - moral neutrality ending

#### Late Bloomer
- **Steam ID**: `late_bloomer`
- **Description**: Complete the loyalist path but leave a mark of hope
- **Unlock Rate**: ~4.0%
- **Type**: Narrative choice outcome (redemption ending)
- **Trigger**: `stay_or_go == "stay"` AND `final_loyalist_choice == "hope"`
- **Notes**: Plant seeds of future resistance from within

### Special Ending Achievement - 1 Achievement

#### Savior of Spud
- **Steam ID**: `savior_of_spud`
- **Description**: Complete the romantic ending with Sasha
- **Unlock Rate**: ~2.0%
- **Type**: "True" ending / Best outcome
- **Trigger**: `stay_or_go == "go"` AND `pro_sasha_choice >= 5` AND `sasha_rescue_reaction == "relieved"`
- **Notes**: Requires consistent support for Sasha throughout the campaign. Must make at least 5 pro-resistance choices and express relief at rescuing her. The most emotionally satisfying conclusion.

### Character Arc Achievements - 3 Achievements

#### Tommy's Legacy
- **Steam ID**: `tommys_legacy`
- **Description**: Stand by Murphy through the revelation about his cousin
- **Unlock Rate**: ~6.0%
- **Type**: Character relationship
- **Trigger**: `murphy_alliance == "ally"` at game completion
- **Notes**: Support Murphy when he breaks down about Tommy. Rewards empathy and building alliances.

#### Elena's Memory
- **Steam ID**: `elenas_memory`
- **Description**: Tell Viktor the truth about his wife's fate
- **Unlock Rate**: ~5.0%
- **Type**: Character relationship
- **Trigger**: `viktor_conversation == "tell_truth"` (must have discovered wife on manifest first)
- **Notes**: A painful truth rather than a comfortable lie. Viktor becomes an ally after.

#### The Note
- **Steam ID**: `the_note`
- **Description**: Keep Sasha's mysterious note and complete the game
- **Unlock Rate**: ~7.0%
- **Type**: Story discovery
- **Trigger**: `kept_note == "yes"` at game completion
- **Notes**: The note from Day 1 sets everything in motion. Keeping it shows early skepticism of the regime.

### Discovery Achievements - 2 Achievements

#### Root of Evil
- **Steam ID**: `root_of_evil`
- **Description**: Witness the true horror of Root Reserve
- **Unlock Rate**: ~15.0%
- **Type**: Story milestone
- **Trigger**: Reach shift9_end processing plant scene (either path)
- **Notes**: The moment the player sees the processing machinery and understands what Root Reserve really is.

#### Chaos Architect
- **Steam ID**: `chaos_architect`
- **Description**: Play both sides against each other
- **Unlock Rate**: ~1.5%
- **Type**: Alternative playstyle
- **Trigger**: `chaos_points >= 4` at game completion
- **Notes**: A morally gray path - manipulate both resistance and regime for personal gain. Requires deliberately making chaos choices throughout the campaign.

### Skill-Based Achievements (Gameplay Mastery) - 4 Achievements

#### Border Defender
- **Steam ID**: `border_defender`
- **Description**: Stop 50 total border runners
- **Unlock Rate**: ~1.2%
- **Type**: Mini-game mastery (missile defense)
- **Notes**: Cumulative across all playthroughs, encourages defensive play

#### Sharpshooter
- **Steam ID**: `sharpshooter`
- **Description**: Successfully stop 10 border runners
- **Unlock Rate**: ~0.6%
- **Type**: Mini-game proficiency
- **Notes**: Subset of Border Defender, mid-tier missile defense milestone

#### Perfect Shot
- **Steam ID**: `perfect_shot`
- **Description**: Get 5 perfect hits on border runners
- **Unlock Rate**: ~0.6%
- **Type**: Mini-game precision
- **Notes**: Rewards accuracy over volume, tracks direct hits vs. splash damage

#### Stamp Master
- **Steam ID**: `stamp_master`
- **Description**: Process a potato perfectly (no errors, perfect stamp placement)
- **Unlock Rate**: ~8.5%
- **Type**: Basic proficiency
- **Notes**: Early skill check, teaches precision in document processing

### High Score Achievements (Competitive Play) - 2 Achievements

#### High Scorer
- **Steam ID**: `high_scorer`
- **Description**: Achieve a score of 10,000 points in a single shift
- **Unlock Rate**: ~0.6%
- **Type**: Score attack milestone
- **Notes**: Encourages efficiency and combo mastery in Story or Endless mode

#### Score Legend
- **Steam ID**: `score_legend`
- **Description**: Achieve a score of 50,000 points
- **Unlock Rate**: ~0.6%
- **Type**: Elite score achievement
- **Notes**: Likely requires Endless mode or perfect Hard difficulty performance

## Achievement Summary Table

| Category | Count | IDs |
|----------|-------|-----|
| Story Progression | 4 | first_day_on_the_job, rookie_customs_officer, customs_veteran, master_of_customs |
| Resistance Endings | 4 | down_with_the_tatriarchy, born_diplomat, tater_of_justice, best_served_hot |
| Loyalist Endings | 3 | heart_of_stone, survivor, late_bloomer |
| Special Ending | 1 | savior_of_spud |
| Character Arcs | 3 | tommys_legacy, elenas_memory, the_note |
| Discovery | 2 | root_of_evil, chaos_architect |
| Skill-Based | 4 | border_defender, sharpshooter, perfect_shot, stamp_master |
| High Score | 2 | high_scorer, score_legend |
| **Total** | **21** | |

## Achievement Design Philosophy

### Balanced Unlock Distribution

- **High unlock rate (8-15%)**: Early discoveries and basic skill achievements
- **Medium unlock rate (3-7%)**: Story ending and character arc achievements encourage replayability
- **Low unlock rate (0.6-2%)**: Mastery achievements and special endings reward dedication

### Tracking Requirements

- **Cumulative achievements** (Border Defender, Sharpshooter): Track across all game sessions via SaveManager
- **Single-session achievements** (High Scorer, Perfect Shot): Must occur within one shift
- **Story achievements**: Tied to NarrativeManager choice tracking and Dialogic variables
- **Skill achievements**: Tied to ProcessingManager and gameplay metrics
- **Character arc achievements**: Require specific variable states at game completion

### Player Motivation Goals

1. **Story Exploration**: Multiple ending achievements (8 total) drive replays
2. **Meaningful Choices**: Character arc achievements reward consistent role-playing
3. **Skill Improvement**: Progression from "Stamp Master" → "Perfect Shot"
4. **Long-term Engagement**: Cumulative achievements reward persistent play
5. **Alternative Playstyles**: Chaos Architect rewards unconventional approaches

## In-Game Display Requirements

- Achievement list accessible from Main Menu and Pause Menu
- Show locked/unlocked status with progress bars where applicable
- Display unlock percentages (global player statistics)
- Visual indication of which ending achievements remain (spoiler-free icons)
- Notification system when achievements unlock during gameplay
- Character arc achievements should show partial progress (e.g., "Murphy: Allied")

## Technical Implementation Notes

- Steam API integration for unlock tracking
- SaveManager must persist achievement progress for cumulative types
- NarrativeManager must trigger ending achievements based on final Dialogic variable states
- ProcessingManager must track perfect placements, scores, and runner kills
- Achievement unlocks must sync with Steam Cloud for cross-device play
- Character arc achievements require checking multiple variables at game end

### Variable Requirements for Narrative Achievements

```
# Ending achievements check these variables at game completion:
ending_choice: "diplomatic" | "justice" | "vengeance" | "dismantle"
stay_or_go: "stay" | "go"
final_loyalist_choice: "report" | "ignore" | "hope"
pro_sasha_choice: integer (0-10)
sasha_rescue_reaction: "angry" | "disgusted" | "relieved"

# Character arc achievements check:
murphy_alliance: "ally" | "cautious" | "skeptical" | "hostile"
viktor_conversation: "tell_truth" | "lie_protect"
kept_note: "yes" | "no"

# Chaos agent achievement checks:
chaos_points: integer (0-6)
```

## Post-Launch Achievement Expansion

Potential additional achievements for content updates:
- New mini-game specific achievements (interrogation, baggage inspection mastery)
- Daily Challenge streaks
- Hidden/secret achievements for easter eggs
- Speedrun achievements (complete story under time limit)
- No-strike perfect run achievements
- Viktor's Vengeance: Have Viktor help during final confrontation QTE

---

> **Next:** [Credits and Attribution](15_credits.md)
