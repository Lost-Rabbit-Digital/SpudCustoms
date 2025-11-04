# Steam Update 1.2.0 - Major Update
Fix narrative manager and achievements in Spud Customs
Add intro segment that shows localized version of great wall of spud (with country flag of Steam user) as tongue in cheek reference using Localized resources in Godot and artwork from StagNation
Add StagNation credits
Change Date of Birth: to Born: on passports
Fix story narrative choices being retained
Incorporate all the new artwork from StagNation and push out an art update to Steam
Link loot and stealth systems in Tumblefire, fix console errors in Tumblefire prototype and push up to GitHub
Modify endings to have more diverse endings (really bad, decent, decent, really good)
Review ALL artwork and see if we can replace with better quality pixel art using Imagen 4
Test latest build .dll on AVBD prototype in Godot (More stability, set up physics problems tests to compare Jolt and AVBD directly)
Test story with new Dialogic 2.18 and make sure it's completable
Verify Passport Translations for Detail Names (Date of Birth)
Work on Spud Customs GIF integration in Godot to use Stagnation's art (https://godotengine.org/asset-library/asset/2255) ASAP

## Tasks
"Daily Challenge - Unique daily rule sets, Global leaderboards, Fixed seed" -> Move leaderboards OUT of the story, and focus on presenting these daily and challenge/score attack modes as leaderboards
Add Citation + Strike system - better feedback, more forgiving, clearer consequences
Add Environmental storytelling (propaganda, radio, newspapers mentioned in GDD) as shifts progress, we have artwork available for each of these
Add tutorial step for taking too long and causing runners, with warning from emotes
Add X-ray system 
Check endless / score attack mode, should have progressive difficulty, unlockable content, high score persistence per difficulty per player
Choice tracking system in NarrativeManager needs review, must make sure the players choices are properly retained tracked, saved, and loaded
color match purple of background in personal quarters
Create updated versions of each tutorial step with the new UI
Create updated versions of each tutorial step with the new UI
Dialogue font needs to be different
Document a visualization of the story flow and decision points
Document how major systems interact
Document how new content is added like potatoes, rules, and laws
Document the deployment process to Steam Depots using Web Builds
Done: Add tutorial step for raising the gate
Footprint system doesn't pool sprites (creates/destroys) which may cause performance issues
Gap: No colorblind mode for stamp colors for accessibility
Gap: No font size options for accessibility
Gap: No UI scaling options for accessibility
GDD potato types count needs to come down to 4 from 10
High score structure exists but inconsistently used
Keyboard audio desync when using pre-made audio files, change to use dialogic single keystrokes or tailored length files
Make sure character customization persistence (like changing aspects of the world, office, inspection booth) saved in SaveManager
Make sure narrative choices saved in SaveManager
Missing: Multiple ending branches (GDD mentions these but no implementation visible), low effort (2 art piece, 4 lines dialogue per ending)
No "unlockable potato types" progression visible, start with just russett add new type every few days in story mode
No Steam Cloud Save verification/testing documented, check where user data is saved and make sure Steam cloud is checking correct path
Outline the testing checklist for pre-release verification to ensure game function
Particle systems created dynamically without cleanup plan which may cause performance issues
Replace the current hard-coded tutorial using screenshots with a dynamic tutorial that blends into the first day in the Customs Office
Reworded "Anyone flagged faces" to "Anyone triggering the scanner will face"
shift10 needs the most re-work/narrative bridge
shift10, confusing narrative change from resistance members in the "stay" path being ground up to instead approaching the capitol
shift1_intro, some fades are too fast especially since dialogue is much briefer
shift1_intro, Split Supervisor Russet, "And remember, Glory to Spud!"
shift4_intro ending is abrupt and jarring
Short fun interrogation mini-game, how could this work?
Show achievements in-game from Main Menu and Pause Menu
Split "I think I know what's happening..." "They're becoming [shake][color=light purple]Root Reserve[/shake][/color]"
tutorial, needs updated images
Update tutorial step with exploding runner
Update where strikes and quota show on UI
Use OGV video files for the artwork from StagNation to play more easily within Spud Customs, or Animated GIF
- Test Demo changes before uploading Demo builds
- DaDS / Bug: When dropping a document onto the inspection table, it should appear in front of whatever is on the table
- DaDS / Bug: The _return_item_to_table buffers seem to be broken
- If you hit "Continue" then pause in the Dialogic scene and return to Main Menu, the music from the Dialogic scene continue
- Documents show above the suspect panel background, use viewport masking
- Stamps can be placed on the outside of the passport, use viewport masking
- Add visual feedback for combo multipliers with perfect stamps
- Dialogic / QoL: Dialogic scenes should fade in and out to the next scene
- Mugshot Generator / Bug: Potatoes go over the inspection desk when accepted
- Allow missiles to kill approved potatoes, resulting in 250 points removed and a strike added, with a flavor alert about a Totneva Convention violation
- Add a small chance to run while waiting in line for each potato in addition to the rejection chance and global timer chance
- Dialogic / Bug: You can launch missiles while in the tutorial scene
- Update art for plant_revelation, goopy potatoes
- Update art for extreme_emergency, washed out
- Test leaderboards for each shift and difficulty, and score attack mode
- Playtest: Beat Story mode, and test each of the 4 endings (Vengeance Complete)


### Gameplay
- Add an Entry ticket document and law requirement
- Add different types of documents, entry passes, work permits, baggage, visas, marriage licenses, bribes 
- Baggage inspection, grab bags and shake them with bugs and coins flying out until you get a "BAG CLEAN" and a small number of points, or contraband detected where you get points for clicking it
- Multiplayer Implementation, co-op or versus using Steam Matchmaking
- Office Shutter: Lever does not have SFX
- Potatoes bobbing up and down while walking
- When shift ends, treat the last guy in office as rejected (Why vs approved?)

### Graphics
- Add ink flecks from stamping that fly up when you stamp
- Add message queue system and delay between messages so they don't override each other, add GDScript to alert_label
- Add tooltip with potato info when you hover over them in line
- At the beginning of your shift, show your potato character walking into the customs office
- Cursor: Update cursor to show a select icon when above the approval or rejection stamp
- Cursor: Update cursor to work with Maaacks menu
- DaDS / Bug: If passport is dragged when shift ends, the passport appears above the fade
- Documents should have gravity on the suspect panel and should fall to the counter
- Drag and Drop Bug: Documents released appear in front of the suspect panel background
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
- Update grab logic to check for alpha of 0 and don't grab (for transparent outlines on documents)
- Z-Index Bug: Corpses need a slightly lower z-index to show BEHIND explosions (re-test)
- Z-Index Bug: Potatoes appear above table instead of under when border runner leaves map on south side

### Backend
- Localize the game into Chinese, Spanish, Portuguese, German initially
- Megaphone Dialogue System: Implement the different categories of dialogue from the JSON file into the megaphone_clicked function code in mainGame.gd

### Gameplay
- Add a check for winning the day, if the border runner is actively happening wait for it to finish before ending the shift <-- I don't think we should necessarily do this, there may be CONSTANT border runners with max of concurrent and high spawn rate in later shifts - DM
- Change position so kill text flying up with the score update ("potato.first_name + potato.last_name" + "neutralized...")
- Change time to a shift-based time, such as 8 hours over a day
- Conversation with potato while checking documents, similar to customs office dialogue, Terry Pratchett inspired
- Make the instructions an overlay which you could close
- Repaint each cutscene that stands out as rough in Aseprite (use dedicated 16-32 color palettes, repaint in simpler forms)
- Show Missile counter on an LCD display on the desk or on UI

### Menus
- Remove leaderboard pane from the shift summary screen
- Improve the introduction of each element into shift summary screen, make sure stamps are visible before running stamp animations 
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


## === 1.1.2 ===

### DaDS System Fixes:
- Fixed find_topmost_item_at() to properly use z-index for document stacking
- Fixed stamp bar blocking: Now checks entire StampBar bounds instead of individual buttons
- Fixed cursor not updating after drag: Clear hovered_item on drag start
- Prevent document pickup through stamp bar area
- Drag and Drop Bug: Do not allow the user to pick up the document through the stamp bar
- Drag and Drop Bug: Get highest z-index doesn't seem to be working properly, cannot easily set passport atop of LawReceipt
- Drag and Drop Bug: If the player grabs the passport while it's animated the script does not properly update z-index
- DaDS / Bug: You can drag the documents through the stamps, stamps should block interaction
- DaDS / Bug: When you drag documents, they do not appear above other documents

### Z-Index Fixes:
- Explosions: 12 → 1 (now below inspection table, won't obscure gameplay)
- Explosion smoke: 13 → 1 (matches explosions)
- Footprints: 9 → 0 (on ground level with environment)
- Gibs: 11 → 21 (above screen borders to prevent clipping)
- Missile smoke: 11 → 7 (proper layering)
- Z-Index Bug: Explosions appear above the inspection table
- Z-Index Bug: Potato footsteps appear above the customs office
- Z-Index Bug: Potato gibs appear below the screen borders

### Game State Bug:
- Fixed accept/reject state bug: Stamping now removes opposite stamp type
- Prevents approved then rejected passports from keeping approved state
- If you accept and then reject a potato, it keeps the accepted state

### Cursor System:
- Added missile zone cursor targeting callback registration
- Created is_point_in_missile_zone() function for target cursor display
- Target cursor now shows when hovering over missile launch area
- Cursor System: The target cursor is not showing when firing missiles
- Cursor Bug: After dragging a document the cursor returns to default even if the cursor is still hovering over a document
- Cursor Bug: Target display is not showing when hovering over the missile area

### Audio Bug:
- Fixed music persistence when returning to main menu from Dialogic
- Added Dialogic.Audio.stop_all_channels() to _on_shift_summary_main_menu()

### Gameplay Fixes:
- Fixed 'Strike Removed!' showing when killing runner with 0 strikes
- Now only shows strike removal message if a strike was actually removed
- Properly reconstructs alert message based on whether strike was removed
- If you kill a runner and have 0 strikes, it should not say "Strike Removed!" on the pop-up text

### Code Quality:
- Missile launch during tutorial already protected by is_in_dialogic check
- Dialogic.timeline_started properly connected to _on_dialogue_started
- Easy difficulty scaling factor already set to 0.8 (not a bug)

### Achievement System Fixes:
- Fixed check_achievements() never being called
- Added call to Global.check_achievements() after each successful shift (mainGame.gd:478)
- Added call to Global.update_steam_stats() to sync with Steam (mainGame.gd:479)
- Fixed total_shifts_completed never incremented
- Increment Global.total_shifts_completed after successful shift (mainGame.gd:474)
- Fixed total_runners_stopped not tracked globally
- Increment Global.total_runners_stopped when runner hit (BorderRunnerSystem.gd:1139)
- Fixed perfect_hits not tracked globally
- Increment Global.perfect_hits on perfect missile hits (BorderRunnerSystem.gd:1159)
- Test narrative and stats-based achievements

### Save/Load Persistence:
- Added total_shifts_completed to save_game_state() (Global.gd:237)
- Added total_runners_stopped to save_game_state() (Global.gd:238)
- Added perfect_hits to save_game_state() (Global.gd:239)
- Added loading of all three stats in load_game_state() (Global.gd:251-253)

### Leaderboard System Fixes:
- Root Cause: Timeout handlers were calling reset_leaderboard_state() which set state to IDLE
- When Steam callback arrived later, it checked state != FINDING and rejected it
- This prevented score_submitted/leaderboard_updated signals from firing
- UI remained stuck waiting for signals that would never arrive
- Removed async from reset_leaderboard_state() (SteamManager.gd:594-599)
- Removed unnecessary await get_tree().process_frame
- Function now completes immediately without race conditions
- Updated loading timeout handler (ShiftSummaryScreen.gd:267-276)
- Removed call to reset_leaderboard_state()
- Now only updates UI text to show timeout
- Allows Steam callback to complete if it arrives late
- Updated submission timeout handler (ShiftSummaryScreen.gd:317-331)
- Re-enables submit button for user retry
- Improved callback state handling (SteamManager.gd:356-361)
- Changed from hard rejection to warning + process anyway
- Handles case where timeout fired but callback arrived late
- Logs warning but continues processing valid Steam response
- Fixed concurrent request check (SteamManager.gd:256-260)
- Simplified condition from complex AND to just is_fetching_leaderboard
- Added state logging to debug message
- More consistent rejection of duplicate requests
- Leaderboards not loading as expected on 1.1 Steam in public_test, troubleshoot ASAP, blocking full release
