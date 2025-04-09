  # Scratch Pad
These are our goals, to-do tasks, and completed tasks.

## Steam Minor Update 1.0.3 - Next Update
## Tasks
### Features
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



# FULL RELEASE TASKS - 2025-04-11 Target Release - 1.0.2
## Tasks
## RELEASE BLOCKERS
- Stamps go over edge of passport
- Corpses need a slightly lower z-index to show BEHIND explosions (re-test)
- Make sure that stamp consistently marks the same spot on the document, NOT based on where the player clicks on the stamp
- Cursor / Bug: Target display is not showing when hovering over the missile area
- Emote System / Bug: When potatoes are clicked it only displays love emotes, could be set to display HAPPY category
- Drag and Drop / Bug: If the player grabs the passport while it's animated the script does not properly update z-index
- Drag and Drop / Bug: LawReceipt does not automatically close when dragged off of the suspect table
- Drag and Drop / Bug: Get highest z-index doesn't seem to be working properly, cannot easily set passport atop of LawReceipt
- Remake Score Attack mode and score at least 25 potatoes
- Create demo version of game without Score Attack mode, only shift 0, 1, and 2
- Beat Story mode, and test each of the 4 endings
- Update grab logic to check for alpha of 0 and don't grab (for transparent outlines on documents)
- Do not allow the user to pick up the document through the stamp bar
- Add a check for winning the day, if the border runner is actively happening wait for it to finish before ending the shift
- Need to update target positions for stamp buttons, currently both going same place
- Need to update support for combo multipliers with perfect stamps
- Need to troubleshoot particle effects for perfect stamps
### Graphics  
- Add an animated counter up for each of the increases of the score (incrementally adding the numbers)
- Add logic to check if game paused or in dialogic before updating cursor to target cursor
- Cause stamps to wiggle and slam in and then fade into color on shift summary
- Center closed version of documents on the mouse position, it often appears offset
- Concrete steps should be smaller and darker than the grass footsteps
- Have animated counters up for each of the values in the shift summary screen
- Make a two-stage downward tween with the stamp and then the stamp handle to emulate pressing down an internal mechanism for the approval and reject stamps? As in the whole stamp descends, just the stamp handle descends, stamp handle comes back up, whole stamp comes back up.
- Potato shadow doesn't line up with the silhouette of the new potatoes
- Update cursor to show a select icon when above the approval or rejection stamp
- When hit with a missile, make the Runner corpse spin up in an arc opposite the direction of the missile impact, then bounce on the ground at the same y-level as corpse started at before coming to a rest
- When shift ends, treat the last guy in office as rejected

### Gameplay
- Allow missiles to kill approved potatoes, resulting in a Taterneva Convention violation (-250 points)
- Now that the Runner System has support for multiple runners, include a chance to run while waiting in line for each potato instead of waiting for rejection or the global timer

### Audio
- Check if there is a Dialogic 2 end audio function, implement after each keyboard audio call through all 11 .dtl resources
- Hand gripping sound to document
- Whooosh sound when document is returned to table
- Whooshing sound when documents are dragged quickly

### Backend
- Megaphone Dialogue System: Implement the different categories of dialogue from the JSON file into the megaphone_clicked function code in mainGame.gd

### General Bugs
- Fix SceneLoader issues, direct scene transitions break overlaid menus in Shift Summary but using SceneLoader.load_scene with a reference to the desired scene isn't working either, and no error is being produced.
- Potatoes appear above table instead of under when border runner leaves map on south side

### Credits
Add these users to the credits menu

- Arludus: https://arludus.itch.io/2d-top-down-180-pixel-art-vehicles

### Completed Tasks for 1.0.2
- Skip button not disappearing, and resetting the shift when pressed
- Wrong shift displaying on shift summary screen
- Runner potatoes are registering TWO strikes instead of just 1
- Add pitch variation to the positive and negative score sound
- Add random x/y-axis variation on the position selected in the return to table function
- Add small amount of random pitch variation to the document open and close sounds
- Alert Text: Wrong font sizing, causing blurry text
- Corpses added too high to tree, screen shake not affecting them
- Drag and Drop: Clip the document edges if they are off the table
- Drag and Drop: If the passport hasn't been stamped and is dropped on the potato, it should return to table
- Drag and Drop: If the passport hasn't been stamped and is hovered over the potato, it should not prompt the dialogue
- Drag and Drop: Law receipt passes between the passport description/photo and the passport background
- Drag and Drop: Passport text and photo appear over the LawReceipt
- Drag and Drop: Stamps disappear on passport while being dragged
- Emote System: Reduce frequency of emotes occuring
- Fix potatoes using wrong spritesheet for assigned race / sex
- Fix skip story bug not hiding the history button quickly
- Gate re-raises on megaphone click, even when already up.
- Office Shutter: Shutter opens even when open when a potato comes into the office
- Office Shutter: When shutter is automatically raised, the potatoes stay shadow-y
- Only show take passport dialogue if the passport has been stamped
- Potato stays in shadow when the shutter automatically raises
- Potatoes in queue don't seem to match up with potatoes that enter customs office (MugshotGenerator is using diff potatoes lol)
- Set a highlight shader on the closed passport if the document goes untouched for >15 seconds
- Set a highlight shader on the speaker/start button if the booth goes empty for >15 seconds
- Set a highlight shader on the stamps or stamp bar open if the document is open on the table for >15 seconds
- Shrink texture for missiles and impacts, sizing of pixels is off-putting
- Stamp System: Stamps disappear when picked up and dragged
- Update cursor to show a select icon when above the megaphone 
- Update cursor when hovering over the megaphone
- Z-index: Dragged passport appears below the suspect table
