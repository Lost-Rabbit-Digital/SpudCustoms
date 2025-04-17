# Scratch Pad
These are our goals, to-do tasks, and completed tasks.

# Steam Minor Update 1.1.1 - Next Update

## Tasks

### Gameplay
- Add a UV lamp which represents an additional way to earn points by scanning for secret symbols/messages on documents
- Add an Entry ticket document and law requirement
- Add different types of documents, entry passes, work permits, baggage, visas, marriage licenses, bribes 
- Baggage inspection, grab bags and shake them with bugs and coins flying out until you get a "BAG CLEAN" and a small number of points, or contraband detected where you get points for clicking it
- Multiplayer Implementation, co-op or versus using Steam Matchmaking

### Graphics
- Add ink flecks from stamping that fly up when you stamp
- Add message queue system and delay between messages so they don't override each other, add GDScript to alert_label
- Add tooltip with potato info when you hover over them in line
- At the beginning of your shift, show your potato character walking into the customs office
- Documents should have gravity on the suspect panel and should fall to the counter
- Emote System: All potatoes show exclamation marks when you shoot a missile
- Emote System: If you click the same potato 3+ times they get angry and show POPPING_VEINS emote
- Emote System: Skew emote display chance towards angry and confused
- Flocks of birds on the ground that fly away when you interact
- Make sure scores are shown above their respective action (stamping, missiles, scanning)
- Office Shutter / Bug: Do not fade out transparency of potato when enter or leaving office, only the foreground shadow
- Office Shutter / Bug: Fade out the foreground shadow when the potatoes leave the office
- Office Shutter / Bug: Update button to exclude transparent pixels for more accurate clicks
- Physics on suspect panel and interaction table with items (Gravity, dropping, throwing)
- Potato in office: Should move up and down like breathing animation, simple tween
- Queue Interaction System: Pop-up of a portrait of potato
- Queue Interaction: Potato tooltip if hovered over in line
- Queue Interaction: Potatoes slightly wiggle while idle
- Queue Interaction: Potatoes wiggle when clicked
- Randomly toggle the lights on and off in customs office and Border Wall like people are using the rooms
- Use top 3 scores for leaderboard, then show ... and show 3 scores above player and 3 scores below player (if any), with players score in middle. 

### Backend
- Backend: Error handling if Steam is not loaded
- Localise the game into Chinese, Spanish, Portuguese, German initially

### Gameplay
- Add "Sapper" runner variants, These runner potatoes throw time-bombs which stick on the top-wall. Wave a mouse over bombs placed on the wall or upper wall in the background to defuse them for scoring, or beat a defusing mini-game.
- Change position so kill text flying up with the score update ("potato.first_name + potato.last_name" + "neutralized...")
- Change time to a shift-based time, such as 8 hours over a day
- Conversation with potato while checking documents, similar to customs office dialogue, Terry Pratchett inspired
- Make the instructions an overlay which you could close
- Repaint each cutscene that stands out as rough in Aseprite (use dedicated 16-32 color palettes, repaint in simpler forms)
- Show Missile counter on an LCD display on the desk or on UI
- Add a check for winning the day, if the border runner is actively happening wait for it to finish before ending the shift <-- I don't think we should necessarily do this, there may be CONSTANT border runners with max of concurrent and high spawn rate in later shifts - DM

### Menus
- Allow leaderboards for each level, viewed from the level select
- Control: Alt-Enter to toggle fullscreen 
- Control: F11 to toggle fullscreen 
- Main Menu: Graphic button function to turn defaults into pretty buttons
- Main Menu: Make a tile map for the paths to enable A* pathfinding
- Main Menu: Potatoes moving in infinite lines behind the main menu, similar to Factorio
- Set default selection for main menu for keyboard control
  #### SHIFT SUMMARY SCREEN
  - Shift Summary: If the "Continue" button does not appear, it should balance out the "Main Menu" and "Restart" buttons

### Law Bugs
- "Rotten potatoes strictly forbidden" and "all potatoes must be fresh" entry granted, said good job, gave +1 to quota and +1 to strikes
- "Sprouted potatoes need additional verification and must be denied", change to not include verification

### Audio
- Emote System: Potatoes should play small sound upon emoting
- Hand gripping sound to document
- Menu Audio: Tick sounds when adjusting volume sliders
- Small sound for hovering above megaphone or stamp bar button
- Whooosh sound when document is returned to table
- Whooshing sound when documents are dragged quickly

# FULL RELEASE TASKS - 2025-04-15 Target Release - 1.1.0
## Tasks
- Disable narrative manager when in score attack mode
### Menus
- After hitting new game, Continue should also load the first level as if data were cleared
- End shift dialogues don't appear to be triggering properly, test having it before shift summary screen?
### Graphics  
- Add an animated counter up for each of the increases of the score (incrementally adding the numbers)
- Add logic to check if game paused or in dialogic before updating cursor to target cursor
- Adding fade to skip or end of dialogic sequences so it doesn't abruptly switch.
- Cause stamps to wiggle and slam in and then fade into color on shift summary
- Center closed version of documents on the mouse position, it often appears offset
- Concrete steps should be smaller and darker than the grass footsteps
- Cursor / Bug: Target display is not showing when hovering over the missile area
- Cursor: After dragging a document the cursor returns to default even if the cursor is still hovering over a document 
- Cursor: Update cusor to work with Maaacks menu
- Drag and Drop / Bug: Do not allow the user to pick up the document through the stamp bar
- Drag and Drop / Bug: Documents released appear in front of the suspect panel background
- Drag and Drop / Bug: Get highest z-index doesn't seem to be working properly, cannot easily set passport atop of LawReceipt
- Drag and Drop / Bug: If the player grabs the passport while it's animated the script does not properly update z-index
- Drag and Drop / Bug: LawReceipt does not automatically close when dragged off of the suspect table
- Have animated counters up for each of the values in the shift summary screen
- Make a two-stage downward tween with the stamp and then the stamp handle to emulate pressing down an internal mechanism for the approval and reject stamps? As in the whole stamp descends, just the stamp handle descends, stamp handle comes back up, whole stamp comes back up.
- Potato shadow doesn't line up with the silhouette of the new potatoes
- Show buttons on continue summary screen AFTER fading everything in.
- Stamp System: Need to troubleshoot particle effects for perfect stamps
- Stamp System: Stamps go over edge of passport
- Update cursor to show a select icon when above the approval or rejection stamp
- When hit with a missile, make the Runner corpse spin up in an arc opposite the direction of the missile impact, then bounce on the ground at the same y-level as corpse started at before coming to a rest
- Z-Index Bug: Corpses need a slightly lower z-index to show BEHIND explosions (re-test)
- Z-Index Bug: Explosions appear above the inspection table
- Z-Index Bug: Potato footsteps appear above the customs office
- Z-Index Bug: Potato gibs appear below the screen borders
### Gameplay
- Add a condition for if the player skips the final narrative so that the end credits are still signalled 
- Allow missiles to kill approved potatoes, resulting in a Taterneva Convention violation (-250 points)
- Disable ability to skip final cutscene so the player doesn't skip right into end credits?
- Need to update support for combo multipliers with perfect stamps
- Now that the Runner System has support for multiple runners, include a chance to run while waiting in line for each potato instead of waiting for rejection or the global timer
- Update grab logic to check for alpha of 0 and don't grab (for transparent outlines on documents)
- When shift ends, treat the last guy in office as rejected
### Audio
### Testing
- Test narrative and stats-based achievements
- Test leaderboards for each shift and difficulty
- Test Shift 6 - 11 and see if end credits trigger
- Playtest: Beat Story mode, and test each of the 4 endings
### Backend
- Megaphone Dialogue System: Implement the different categories of dialogue from the JSON file into the megaphone_clicked function code in mainGame.gd
### General Bugs
- Potatoes appear above table instead of under when border runner leaves map on south side
### Art
- loyalist_outcome, too human
- night attack, human man in background
- night_checkpoint, messed up characters
- personal quarters, style break, random
- plant_revelation, goopy potatoes
- processing_facility, remove random messed up potatoes
- reckoning, fix grain
- resistance_planning, emblems should be potatoes, potatoes should not have armor, leader should look more like old white mustache russet potato
- security_lockdown, washed out
- victory_scene, fucked up faces

### Credits


### Completed Tasks for 1.1.0
- New game must always use tutorial, and SHOULD wipe data, then load the correct level
- New game continues right now, should go back to tutorial
- Demo: Create demo version of game without Score Attack mode, only shift 0, 1, and 2
- Make rejected potatoes walk away even slower
- Make the score attack button on main_menu_with_animations load the appropriate score attack mode scene similar to main_game_ui.tscn
- Add score attack mode back in by inheriting mainGame and overriding scoring rules
- Remake Score Attack mode and score at least 25 potatoes
- Add a confirmation for resetting story progress (not highscores) to New Game
- Add Arludus to credits: https://arludus.itch.io/2d-top-down-180-pixel-art-vehicles
- Add button to reset campaign progress
- Add button to reset highscores
- Add cars that drive by from the top to the bottom of the screen
- Add dialogue emotes randomly to the potatoes, Potatoes emote (Kenny emotes) while waiting in line
- Add pitch variation to the positive and negative score sound
- Add random x/y-axis variation on the position selected in the return to table function
- Add small amount of random pitch variation to the document open and close sounds
- Alert Text: Wrong font sizing, causing blurry text
- Bubble Dialogue: Implement into the Drag and Drop system for dropping a passport onto a potato to have varied dialogue instead of the same hardcoded text
- Check if there is a Dialogic 2 end audio function, implement after each keyboard audio call through all 11 .dtl resources
- Corpses added too high to tree, screen shake not affecting them
- DaDS / Bug: When you drag a document to close it, it does not center on the mouse 
- Dialogue sign outside customs office isn't disappearing after a few seconds
- Drag and Drop: Clip the document edges if they are off the table
- Drag and Drop: If the passport hasn't been stamped and is dropped on the potato, it should return to table
- Drag and Drop: If the passport hasn't been stamped and is hovered over the potato, it should not prompt the dialogue
- Drag and Drop: Law receipt passes between the passport description/photo and the passport background
- Drag and Drop: Passport text and photo appear over the LawReceipt
- Drag and Drop: Stamps disappear on passport while being dragged
- Emote System / Bug: When potatoes are clicked it only displays love emotes, could be set to display HAPPY category
- Emote System: Reduce frequency of emotes occuring
- Environment: Cars passing by
- Fix potatoes using wrong spritesheet for assigned race / sex
- Fix SceneLoader issues, direct scene transitions break overlaid menus in Shift Summary but using SceneLoader.load_scene with a reference to the desired scene isn't working either, and no error is being produced.
- Fix skip story bug not hiding the history button quickly
- Gate re-raises on megaphone click, even when already up.
- Make quota include difficulty level as well
- Make sure that stamp consistently marks the same spot on the document, NOT based on where the player clicks on the stamp
- Office Shutter: Shutter opens even when open when a potato comes into the office
- Office Shutter: When shutter is automatically raised, the potatoes stay shadow-y
- Only show take passport dialogue if the passport has been stamped
- Potato stays in shadow when the shutter automatically raises
- Potatoes in queue don't seem to match up with potatoes that enter customs office (MugshotGenerator is using diff potatoes lol)
- Progression for story not saving/loading properly
- Runner potatoes are registering TWO strikes instead of just 1
- Score not resetting when continuing shifts
- Set a highlight shader on the closed passport if the document goes untouched for >15 seconds
- Set a highlight shader on the speaker/start button if the booth goes empty for >15 seconds
- Set a highlight shader on the stamps or stamp bar open if the document is open on the table for >15 seconds
- Shift increasing by 2 on shift completion; game goes from shift 10 to shift 12 and appears to skip the end of the game
- Shrink texture for missiles and impacts, sizing of pixels is off-putting
- Skip button not disappearing, and resetting the shift when pressed
- Stamp System: Stamps disappear when picked up and dragged
- Update cursor to show a select icon when above the megaphone 
- Update cursor when hovering over the megaphone
- Update stamp buttons to use the correct offsets and starting positions
- Wrong shift displaying on shift summary screen
- Z-index: Dragged passport appears below the suspect table
