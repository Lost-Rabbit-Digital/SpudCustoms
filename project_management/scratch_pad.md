  # Scratch Pad
These are our goals, to-do tasks, and completed tasks.

## Steam Minor Update 1.0.3 - Next Update
## Tasks
### Stretch Features
- Add tooltip with potato info when you hover over them in line
- Baggage inspection, grab bags and shake them with bugs and coins flying out until you get a "BAG CLEAN" and a small number of points, or contraband detected where you get points for clicking it
- Multiplayer Implementation, co-op or versus using Steam Matchmaking
- Add cars that drive by from the top to the bottom of the screen
- Use top 3 scores for leaderboard, then show ... and show 3 scores above player and 3 scores below player (if any), with players score in middle. 
- UV lamp represents a high-risk way to maximize points.
- Randomly toggle the lights on and off in customs office and Border Wall like people are using the
  rooms
- Make sure scores are shown above their respective action (stamping, missiles, scanning)
- Queue Interaction: Potato tooltip if hovered over in line
- Queue Interaction System: Pop-up of a portrait of potato
- Main Menu: Potatoes moving in infinite lines behind the main menu, similar to Factorio
- Main Menu: Make a tile map for the paths
- Main Menu: Graphic button function to turn defaults into pretty buttons
- Control: Alt-Enter to toggle fullscreen 
- Control: F11 to toggle fullscreen 
- Backend: Error handling if Steam is not loaded
- Queue Interaction: Potatoes slightly wiggle while idle
- Queue Interaction: Potatoes wiggle when clicked
- Emote System: All potatoes show exclamation marks when you shoot a missile

### Graphics
- Add message queue system and delay between messages so they don't override each other, add GDScript to alert_label
- Add different types of documents, entry passes, work permits, baggage, visas, marriage licenses, bribes 
- Add an Entry ticket document and law requirement
- Documents should have gravity on the suspect panel and should fall to the counter
- Add dialogue emotes randomly to the potatoes, Potatoes emote (Kenny emotes) while waiting in line
- Physics on suspect panel and interaction table with items (Gravity, dropping, throwing)
- Add ink flecks from stamping that fly up when you stamp

### Backend
- Localise the game

### Gameplay
- Change time to a shift-based time, such as 8 hours over a day
- Make the instructions an overlay which you could close
- Show Missile counter on an LCD display on the desk or on UI
- Change position so kill text flying up with the score update ("potato.first_name + potato.last_name" + "neutralized...")
- Add "Sapper" runner variants, These runner potatoes throw time-bombs which stick on the top-wall. Wave a mouse over bombs placed on the wall or upper wall in the background to defuse them for scoring, or beat a defusing mini-game.
- Conversation with potato while checking documents, similar to customs office dialogue, Terry Pratchett inspired
- Repaint each cutscene that stands out as rough in Aseprite (use dedicated 16-32 color palettes, repaint in simpler forms)

### Menus
- Allow leaderboards for each level from the level select
- Add button to reset campaign progress
- Set default selection for main menu for keyboard control
- Add button to reset highscores

### Law Bugs
- "Rotten potatoes strictly forbidden" and "all potatoes must be fresh" entry granted, said good job, gave +1 to quota and +1 to strikes
- "Sprouted potatoes need additional verification and must be denied", change to not include verification

### Audio
- Small sound for hovering above megaphone or stamp bar button

# FULL RELEASE TASKS - 2025-02-28 - 1.0.2
## Tasks
## RELEASE BLOCKERS
- Make sure that game state is reset properly between story and score attack modes within the Global.gd and GameState.gd, and make sure that narrative progress and high scores for each narrative level and each score attack level are saved appropriately
- Save game and load game, especially max level reached and local highscores
- Score might not be resetting between rounds on leaderboard. Must be reset in Continue, Restart, Main Menu calls.
- Strikes on endless mode do not reset after summary screen, summary > main menu > endless mode
- Quota maximum not updating at start of shift
- Add distinct buttons for resetting story progress, resetting high scores
- Playtest Endless mode
- Playtest Story mode
- Stamps go over edge of passport
- Set a highlight shader on the closed passport if the document goes untouched for >15 seconds
- Set a highlight shader on the speaker/start button if the booth goes empty for >15 seconds
- Set a highlight shader on the stamps or stamp bar open if the document is open on the table for >15 seconds
- Fix the issue where the game continues running during story sequences
- Corpses added too high to tree, screen shake not affecting them
- Corpses need a slightly lower z-index to show BEHIND explosions
- Runner potatoes are registering TWO strikes instead of just 1
- Skip button not disappearing, and resetting the shift when pressed
- Update leaderboard logic to refer to appropriate new leaderboards


### Graphics  
- Potatoes in queue don't seem to match up with potatoes that enter customs office (MugshotGenerator is using diff potatoes lol)
- When hit with a missile, make the corpse spin up in an arc opposite the direction of the missile impact, then bounce on the ground at the same y-level as corpse started at before coming to a rest.
- Add an animated counter up for each of the increases of the score (incrementally adding the numbers)
- Have animated counters up for each of the values in the shift summary screen
- Make a two-stage downward tween with the stamp and then the stamp handle to emulate pressing down an internal mechanism (whole stamp descends, just the stamp handle descends, stamp handle comes back up, whole stamp comes back up)
- Add logic to check if game paused or in dialogic before updating cursor to target cursor
- Add random y-axis variation on the position selected in the return to table function
- Cause stamps to wiggle and slam in and then fade into color on shift summary
- Center closed version of documents on the mouse position, it often appears offset
- Concrete steps should be smaller and darker than the grass footsteps
- Only show take passport dialogue if the passport has been stamped
- Shrink texture for missiles and impacts, sizing of pixels is off-putting (Boden task, too subjective without guidance)
- Update cursor to show a select icon when above the approval or rejection stamp
- Update cursor to show a select icon when above the megaphone 
- Update cursor when hovering over the megaphone
- Update grab logic to check for alpha of 0 and don't grab (for transparent outlines on documents)
- When shift ends, treat the last guy in office as rejected
- Alert Text: Wrong font sizing, causing blurry text

### Gameplay
- Allow missiles to kill approved potatoes, resulting in a Taterneva Convention violation (-250 points)
- Do not allow the user to pick up the document through the stamp bar
- Now that the Runner System has support for multiple runners, include a chance to run while waiting in line for each potato instead of waiting for rejection or the global timer

### Audio
- Hand gripping sound to document
- Whooshing sound when documents are dragged quickly
- Whooosh sound when document is returned to table
- Add small amount of random pitch variation to the document open and close sounds
- Check if there is a Dialogic 2 end audio function, implement after each keyboard audio call through all 11 .dtl resources
- Add pitch variation to the positive and negative score sound

# SHIFT SUMMARY SCREEN
- Shift Summary: If the "Continue" button does not appear, it should balance out the "Main Menu" and "Restart" buttons

### Backend
- Code: Move cursor system out of drag system
- Megaphone Dialogue System: Implement the different categories of dialogue from the JSON file into the megaphone_clicked function code in mainGame.gd
- Update take passport dialogue in mainGame.gd to use the new dialogue system (Same as for megaphone) 

### General Bugs
- Cursor does not update when hovering above megaphone
- Cursor does not update when hovering above stamp bar button
- Escape key for menu stopped working after I alt tabbed a few times and completed the first "day", likely SceneLoader issue.
- Potatoes appear above table instead of under when border runner leaves map on south side
- Fix skip story bug not hiding the history button quickly

### Credits
These users have to be added to our ATTRIBUTIONS.md before 1.0.2 release 

- Emotes: https://kenney.nl/assets/emotes-pack
- Social Icons: https://krinjl.itch.io/icons2
- Button SFX: https://opengameart.org/content/click-sounds6


### Completed Tasks for 1.0.2
- Fix stamping animations so that they move down from the stamp crossbar and are behind it
- Add leaderboards for each level to support shift summary screen (shift_0_easy, shift_1_normal, shift_2_expert, etc)
- Add new compressed MP3 music and sound effects to all scenes for enhanced emotional impact
- Add an on_dialogue_start and on_dialogue_finished call to stop the BGMPlayer and then start next random track when back in game scene
- Set main game audio to mute when dialogue starts and start a new background song on BGMPlayer when dialogue finishes
- If you restart on shift summary screen, it advances to the next level
- Bug: Stamps fly up from the bottom of the screen
- Added social icons to main menu
- Bug: Text disappearing on the law receipt when picked up
- Bug: Audio on shutter does not sync
- Added emotes for potatoes in line
- Create system to detect current cursor shape and update the sprite to match
- Use the "Default cursor shape" property to update cursor state
- Update cursor in the main menu when hover over buttons
- Bug: Passport text disappears while dragged
- Emote System: Implement a variable delay between emotes
- Megaphone: Update core to have button for mouse interactions instead of Area2D (Or alongside Area2D if you don't feel like updating other code references)
- Cursor: We need a hover for grabbable documents (Passport, Law Receipt) and a hover for interactable objects (Potatoes, Megaphone)
- Cursor: Add mulitple hover modes
- Cursor: Update while hovering over megaphone
- Cursor: Update while dragging documents
- Cursor: Update while hovering over documents
- Cursor / Bug: Offset to the right a bit
- Queue Interaction: Highlight on hover of potato
- New game button starts day 1 instead of day 0!
- Regenerate potato images for each character in narrative, 16 total