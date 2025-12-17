# SPUD CUSTOMS 1.2.0 - PATCH NOTES

## A PERSONAL NOTE FROM THE DEVELOPER

My son Kobi was born 25 weeks premature in late November 2023, weighing barely 1 pound. I'd been delaying the launch week after week, and finally decided to release whatever I could muster the willpower to finish while we were checking into the NICU.

Now, over a year later, he's grown from 1 pound to over 20 pounds. Last week he graduated from the NICU to the PICU - still waiting for his lungs to be strong enough for a home ventilator so we can finally go home. In the quiet hours between visits, I've been working to bring Spud Customs closer to the vision I had before life took an unexpected turn.

A lot of the new content reflects feelings that mirror my experiences - Viktor's rooftop grief, Murphy's sacrifice, the old queer couple's erasure, the negative impact of thoughtless acts performed as social norm, and the helplessness in face of waves of ongoing disasters. I watch every recording that pops up online, and I'm grateful to each of you who've taken the time to experience this strange little world.

Over 2,000 people have played Spud Customs and joined us on this journey. Thank you for your feedback, your patience, and your interest in our little story of potato redemption.

I hope this game can bloom even a fraction as much as Kobi has.

This update is for you.

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
- **Murphy's Sacrifice**: New "Protocol HARVEST" sequence with Murphy badge memorial scene and symbolic tattoo imagery
- **QTE Narrative System**: New Quick Time Event minigame system for narrative transitions with failure paths
- **QTE Visual Pane**: Added UI support for narrative images during QTE sequences with progressive image system
- **Loyalist Path Enhancements**: Improved narrative for loyalist path with dialogue fixes
- **Enhanced Cutscenes**: Improved cutscene narrative with better choice continuity and new scenes
- **Citation Notes**: Added draggable citation note system for strike feedback

## ACHIEVEMENTS
- **In-Game Achievement Viewer**: New achievements panel accessible from the pause menu showing all unlockable achievements
- **Toast Notifications**: Achievement unlock toast notifications appear in-game when you earn achievements
- **Expanded Achievement Set**: New achievements tracking various gameplay milestones and story paths
- **Fixed Achievement Tracking**: All achievements now unlock properly including "First Shift Complete"

## BUG FIXES
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
- **Final Confrontation Timeline**: Fixed mixed indentation in final_confrontation.dtl that could affect dialogue flow control
- **Missile Freeze**: Fixed game freeze caused by missile array index out of bounds
- **Poster Hover**: Fixed poster hover zoom by using manual mouse position checking
- **Border Runner Issues**: Fixed various tutorial, background, and border runner issues

## UI & QUALITY OF LIFE
- **Main Menu Cleanup**: Improved main menu social buttons layout and version label styling
- **Date Display**: Added date display to lower left corner of game scene
- **Clear User Data**: Added button to clear user data from options menu
- **Tutorial Flow**: Improved narrator intro flow in tutorial
- **Minigame Notifications**: Minigame unlock notifications now delayed until after shift starts
- **Minigame Frequency Scaling**: Minigames now appear more frequently as you progress through shifts
- **Law Receipt Improvements**: Added expired document note to law receipt, fixed passport text overflow

## PLAYER ENGAGEMENT
- **Review Requests**: Added tasteful review prompts for both demo and full game players
- **Translation Fixes**: Various translation improvements across supported languages

## TECHNICAL IMPROVEMENTS
- **Expanded Language Support**: Now supporting all Steam-supported languages (29 languages total)
- **Translation System Overhaul**: Reorganized to per-language translation files for better maintainability
- **QTE Accessibility**: Improved QTE accessibility and registered minigame system
