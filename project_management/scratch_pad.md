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
- When shift ends, treat the last guy in office as rejected (Why vs approved?)
- Office Shutter: Lever does not have SFX
- Potatoes bobbing up and down while walking

### Graphics
- DaDS / Bug: If passport is dragged when shift ends, the passport appears above the fade
- Update grab logic to check for alpha of 0 and don't grab (for transparent outlines on documents)
- Add ink flecks from stamping that fly up when you stamp
- Add message queue system and delay between messages so they don't override each other, add GDScript to alert_label
- Add tooltip with potato info when you hover over them in line
- At the beginning of your shift, show your potato character walking into the customs office
- Cursor Bug: After dragging a document the cursor returns to default even if the cursor is still hovering over a document 
- Cursor Bug: Target display is not showing when hovering over the missile area
- Cursor: Update cursor to show a select icon when above the approval or rejection stamp
- Cursor: Update cursor to work with Maaacks menu
- Documents should have gravity on the suspect panel and should fall to the counter
- Drag and Drop Bug: Do not allow the user to pick up the document through the stamp bar
- Drag and Drop Bug: Documents released appear in front of the suspect panel background
- Drag and Drop Bug: Get highest z-index doesn't seem to be working properly, cannot easily set passport atop of LawReceipt
- Drag and Drop Bug: If the player grabs the passport while it's animated the script does not properly update z-index
- Drag and Drop Bug: LawReceipt does not automatically close when dragged off of the suspect table
- Emote System: All potatoes show exclamation marks when you shoot a missile
- Emote System: If you click the same potato 3+ times they get angry and show POPPING_VEINS emote
- Emote System: Skew emote display chance towards angry and confused
- Flocks of birds on the ground that fly away when you interact
- Main Game UI: Add an animated counter up for each of the increases of the score (incrementally adding the numbers)
- Make sure scores are shown above their respective action (stamping, missiles, scanning)
- Office Shutter Bug: Do not fade out transparency of potato when enter or leaving office, only the foreground shadow
- Office Shutter Bug: Fade out the foreground shadow when the potatoes leave the office
- Office Shutter Bug: Update button to exclude transparent pixels for more accurate clicks
- Physics on suspect panel and interaction table with items (Gravity, dropping, throwing)
- Potato in office: Should move up and down like breathing animation, simple tween
- PotatoPerson: Concrete steps should be smaller and darker than the grass footsteps
- PotatoPerson: Potato shadow doesn't line up with the silhouette of the new potatoes
- Queue Interaction System: Pop-up of a portrait of potato
- Queue Interaction: Potato tooltip if hovered over in line
- Queue Interaction: Potatoes slightly wiggle while idle
- Queue Interaction: Potatoes wiggle when clicked
- Randomly toggle the lights on and off in customs office and Border Wall like people are using the rooms
- Shift Summary UI: Have animated counters up for each of the values in the shift summary screen
- Shift Summary UI: Show buttons on continue summary screen AFTER fading everything in.
- Shift Summary UI: Use top 3 scores for leaderboard, then show ... and show 3 scores above player and 3 scores below player (if any), with players score in middle. 
- Stamp System: Make a two-stage downward tween with the stamp and then the stamp handle to emulate pressing down an internal mechanism for the approval and reject stamps? As in the whole stamp descends, just the stamp handle descends, stamp handle comes back up, whole stamp comes back up.
- Stamp System: Stamps go over edge of passport
- Z-Index Bug: Corpses need a slightly lower z-index to show BEHIND explosions (re-test)
- Z-Index Bug: Explosions appear above the inspection table
- Z-Index Bug: Potato footsteps appear above the customs office
- Z-Index Bug: Potato gibs appear below the screen borders
- Z-Index Bug: Potatoes appear above table instead of under when border runner leaves map on south side

### Backend
- Megaphone Dialogue System: Implement the different categories of dialogue from the JSON file into the megaphone_clicked function code in mainGame.gd
- Localize the game into Chinese, Spanish, Portuguese, German initially

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

### Audio
- Emote System: Potatoes should play small sound upon emoting
- Hand gripping sound to document
- Menu Audio: Tick sounds when adjusting volume sliders
- Small sound for hovering above megaphone or stamp bar button
- Whooosh sound when document is returned to table
- Whooshing sound when documents are dragged quickly



# FULL RELEASE TASKS - 2025-04-20 Target Release - 1.1.0
## Tasks
Leaderboards not loading as expected on 1.1 Steam in public_test, troubleshoot ASAP, blocking full release
Test Demo changes before uploading Demo builds

### Law Bugs

## Drag and Drop System
- DaDS / Bug: When dropping a document onto the inspection table, it should appear in front of whatever is on the table
- DaDS / Bug: You can drag the documents through the stamps, stamps should block interaction
- DaDS / Bug: The _return_item_to_table buffers seem to be broken
- DaDS / Bug: When you drag documents, they do not appear above other documents

### Menus
- If you hit "Continue" then pause in the Dialogic scene and return to Main Menu, the music from the Dialogic scene continue

### Graphics  
- Documents show above the suspect panel background, use viewport masking
- Stamps can be placed on the outside of the passport, use viewport masking
- Add visual feedback for combo multipliers with perfect stamps
- Cursor System: The target cursor is not showing when firing missiles
- Dialogic / QoL: Dialogic scenes should fade in and out to the next scene
- Mugshot Generator / Bug: Potatoes go over the inspection desk when accepted

### Gameplay
- Allow missiles to kill approved potatoes, resulting in 250 points removed and a strike added, with a flavor alert about a Totneva Convention violation
- Add a small chance to run while waiting in line for each potato in addition to the rejection chance and global timer chance
- Dialogic / Bug: You can launch missiles while in the tutorial scene
- If you kill a runner and have 0 strikes, it should not say "Strike Removed!" on the pop-up text
- If you accept and then reject a potato, it keeps the accepted state

### Audio

### General Bugs

### Backend

### Art
- plant_revelation, goopy potatoes
- extreme_emergency, washed out

### Credit Additions

### Playtests
- Test narrative and stats-based achievements
- Test leaderboards for each shift and difficulty, and score attack mode
- Playtest: Beat Story mode, and test each of the 4 endings (Vengeance Complete)


### Completed Tasks for 1.1.0
