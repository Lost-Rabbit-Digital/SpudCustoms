# SPUD CUSTOMS 1.0.2 - PATCH NOTES

## MAJOR SYSTEM OVERHAULS
- 🚀 **Missile System**: Completely revamped for faster, more consistent missile travel and targeting
- 🖱️ **Interaction System**: Simplified to use just left-click interactions
- 🎯 **Stamping System**: Redesigned for better usability and feedback

## GAMEPLAY IMPROVEMENTS
- **Border Runner System**:
  - Expanded area for perfect hit chance on border runners
  - Fixed issue where runners would escape during various game states
  - Replaced missile sprite and updated explosion animation
  - Allow firing multiple missiles simultaneously
  - Added animated smoke trail for missiles

- **Customs Office**:
  - Potatoes now properly fade in when entering the customs office
  - Fixed bug where correctly rejected potatoes didn't award 250 points
  - Correctly award points for stamping decisions even when potatoes time out
  - Fixed issue with passport documents sometimes not being provided

- **Interface Updates**:
  - Extended score display duration (2s → 3.5s)
  - Improved art quality of stamp bar interface
  - Added screen shake effects on stamping and missile hits (varying intensity)
  - Changed "Runner Escaped" text to all capitals for better visibility
  - Added version counter to main menu

## STORY MODE & DIALOGUE
- Simplified story progression
- Added ability to skip to the end of dialogic timelines with "Skip" button
- Added day-by-day shift selection that unlocks as players progress
- Changed character action text from italics to colored text
- Made the tutorial interactive instead of a simple text panel

## CONTROL IMPROVEMENTS
- Added missile targeting restriction to prevent accidental launches when clicking UI
- Fixed passport and stamp dragging boundaries to lower half of screen
- Fixed offset issues when closing passports

## RULE CLARIFICATIONS
- Updated law text: "Frozen potatoes are not allowed" (removed reference to non-existent special permit)
- Updated law text: "Young potatoes (under 2 years) must be accompanied" (removed reference to non-existent guardian system)
- Updated law text: "Reject Spuddington potatoes because of document counterfeiting activity" (changed "visa" to "document")
- Simplified stamp control explanations in the Guide book

## BUG FIXES
- Fixed missile getting stuck when potatoes escape while missile is in flight
- Fixed issue where border runner system could activate twice and cancel the first occurrence
- Lowered z-index of crater to appear below potato runners
- Fixed multiple targeting issues with the missile system
- Fixed various Guide book text and instructions

## TECHNICAL IMPROVEMENTS
- Added game state checks to prevent potato spawning during dialogic timelines
- Cleaned up old git branches from previous updates