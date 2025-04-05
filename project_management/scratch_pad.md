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
- Office Shutter / Bug: Update button to exclude transparent pixels for more accurate clicks

# SHIFT SUMMARY SCREEN
- Shift Summary: If the "Continue" button does not appear, it should balance out the "Main Menu" and "Restart" buttons

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
- Remake Score Attack mode and score at least 25 potatoes
- Create demo instance of game without Score Attack mode, only shift 0, 1, and 2
- Beat Story mode, and test each of the 4 endings
- Stamps go over edge of passport
- Set a highlight shader on the closed passport if the document goes untouched for >15 seconds
- Set a highlight shader on the speaker/start button if the booth goes empty for >15 seconds
- Set a highlight shader on the stamps or stamp bar open if the document is open on the table for >15 seconds
- Corpses need a slightly lower z-index to show BEHIND explosions
- Runner potatoes are registering TWO strikes instead of just 1
- Skip button not disappearing, and resetting the shift when pressed


### Graphics  
- Gate re-raises on megaphone click, even when already up.
- Potato shadow doesn't line up with the silhouette of the new potatoes
- Potato stays in shadow when the shutter automatically raises
- Potatoes in queue don't seem to match up with potatoes that enter customs office (MugshotGenerator is using diff potatoes lol)
- When hit with a missile, make the Runner corpse spin up in an arc opposite the direction of the missile impact, then bounce on the ground at the same y-level as corpse started at before coming to a rest
- Add an animated counter up for each of the increases of the score (incrementally adding the numbers)
- Have animated counters up for each of the values in the shift summary screen
- Make a two-stage downward tween with the stamp and then the stamp handle to emulate pressing down an internal mechanism (whole stamp descends, just the stamp handle descends, stamp handle comes back up, whole stamp comes back up)
- Add logic to check if game paused or in dialogic before updating cursor to target cursor
- Add random y-axis variation on the position selected in the return to table function
- Cause stamps to wiggle and slam in and then fade into color on shift summary
- Center closed version of documents on the mouse position, it often appears offset
- Concrete steps should be smaller and darker than the grass footsteps
- Update cursor to show a select icon when above the approval or rejection stamp
- Make a two-stage downward tween with the stamp and then the stamp handle to emulate pressing down an internal mechanism for the approval and reject stamps? As in the whole stamp descends, just the stamp handle descends, stamp handle comes back up, whole stamp comes back up.
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


### Backend
- Megaphone Dialogue System: Implement the different categories of dialogue from the JSON file into the megaphone_clicked function code in mainGame.gd

### General Bugs
- Fix SceneLoader issues, direct scene transitions break overlaid menus
- Potatoes appear above table instead of under when border runner leaves map on south side
- Fix skip story bug not hiding the history button quickly

### Completed Tasks for 1.0.2
- Corpses added too high to tree, screen shake not affecting them
- Update cursor to show a select icon when above the megaphone 
- Only show take passport dialogue if the passport has been stamped
- Shrink texture for missiles and impacts, sizing of pixels is off-putting
- Update cursor when hovering over the megaphone
- Z-index: Dragged passport appears below the suspect table
- Drag and Drop: If the passport hasn't been stamped and is hovered over the potato, it should not prompt the dialogue
- Drag and Drop: If the passport hasn't been stamped and is dropped on the potato, it should return to table
