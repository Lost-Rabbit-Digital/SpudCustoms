# SPUD CUSTOMS 1.2.0 - PATCH NOTES

## A PERSONAL NOTE FROM THE DEVELOPER
This update is dedicated to my little one, who spent the first months of life in the NICU - from 1lb at birth to now 20lbs of pure joy. Thank you to everyone who has joined this journey - over 2,000 players have now experienced Spud Customs!

## VISUAL ENHANCEMENTS
- **Animated Art Integration**: Incorporated new animated GIFs from StagNation into opening scenes
- **Art Overhaul**: Repainted the first five scenes players see for improved visual quality:
  - Main menu background
  - Tutorial checkpoint interior
  - Shift 1 introduction scenes (Nation of Spud, checkpoint interior, Great Wall of Spud)
  - Shift 1 ending scenes
  - Shift 2 introduction with Sasha
- **Dynamic Backgrounds**: Background visuals now change as difficulty increases
- **Shift Fade Transitions**: New smooth fade animation between days for improved flow
- **Bloom & Lighting Tuning**: Refined bloom/glow effects for better document readability while maintaining atmospheric cutscenes
- **Animated Cutscene Effects**: Added subtle animated bloom pulse effect to cutscenes
- **Reduced Vignette**: Lighter vignette in game scene for improved visibility
- **New Cutscene Art**: Added new cutscene artwork and Sasha credits image for committed narrative path
- **New Audio Assets**: Added new music and sound effects

## STORY & NARRATIVE
- **Choice Persistence**: Narrative choices now properly carry across all levels
- **Visual Progression**: Added visual indicators of story progression in main gameplay scenes based on current shift number
- **Branching Dialogue Fixes**: Fixed issues with branching dialogue in final narrative scenes
- **Loyalty Path Fix**: Resolved issue where scanner/reality scan sequence was triggering both paths around episode 5
- **Chaos Agent Path**: New story path allowing players to sabotage both sides
- **Sasha Ending Improvements**: Sasha ending now requires 3+ pro-Sasha choices with subtle hints throughout
- **Viktor Storyline**: Added Viktor character with full subplot, grief narrative, and dialogue that shows familiarity after first meeting
- **QTE Narrative System**: New Quick Time Event minigame system for narrative transitions with failure paths
- **QTE Visual Pane**: Added UI support for narrative images during QTE sequences
- **Loyalist Path Enhancements**: Improved narrative for loyalist path with dialogue fixes
- **Enhanced Cutscenes**: Improved cutscene narrative with better choice continuity and new scenes
- **Citation Notes**: Added draggable citation note system for strike feedback
- **Expanded Achievements**: New achievements and improved achievement tracking

## BUG FIXES
- **Achievement System**: Fixed achievement tracking - all achievements now unlock properly including "First Shift Complete"
- **Leaderboard**: Fixed issue where leaderboard was stuck on "Loading leaderboard data" with disabled submit button
- **Screen Shake**: Screen shake now properly resets to origin after each invocation (was causing screen to drift off-center)
- **Difficulty Scaling**: Fixed easy mode scaling factor (was 0.1, now correctly 0.8)
- **Background Display**: Fixed missing backgrounds during dialogue scenes including:
  - "All officers, line up for security scanning" sequence
  - Legal representative option during security testing
- **Text Readability**: Fixed "Sweet Potato Sasha" scene text coloration for better readability ("The Traitor will be")
- **Post-Credits Navigation**: Full game post-credits button now properly returns to main menu
- **Shift Progression**: Fixed shift not advancing after completing day 1
- **Tutorial Dialogue**: Fixed duplicate dialogue IDs causing wrong text in tutorial
- **Character Names**: Fixed Viktor and Murphy character display names in translations
- **Pronoun Fixes**: Fixed Maris Piper seeker's pronouns in shift 3 intro
- **Diplomatic Ending**: Fixed malformed dialogue lines in diplomatic ending
- **Missile Freeze**: Fixed game freeze caused by missile array index out of bounds
- **Poster Hover**: Fixed poster hover zoom by using manual mouse position checking
- **Border Runner Issues**: Fixed various tutorial, background, and border runner issues

## UI & QUALITY OF LIFE
- **Date Display**: Added date display to lower left corner of game scene
- **Clear User Data**: Added button to clear user data from options menu
- **Tutorial Flow**: Improved narrator intro flow in tutorial
- **Minigame Notifications**: Minigame unlock notifications now delayed until after shift starts
- **Minigame Variety**: Added chance for minigame to trigger when border runner would spawn

## PLAYER ENGAGEMENT
- **Review Requests**: Added tasteful review prompts for both demo and full game players
- **Translation Fixes**: Various translation improvements across supported languages

## TECHNICAL IMPROVEMENTS
- **Expanded Language Support**: Now supporting all Steam-supported languages (29 languages total)
- **Translation System Overhaul**: Reorganized to per-language translation files for better maintainability
- **QTE Accessibility**: Improved QTE accessibility and registered minigame system
