
### Completed Tasks for 1.0.2
Before release, review GitHub commits using the following command `git log --since="last month" --pretty=format:'%h,%an,%ar,%s' > log.csv` - This artifact can then be fed into Claude or similar to analyze the changes.
  - *INTERNAL USE* Cleaned up old tutorial code to pave road for new system
  - *INTERNAL USE* Fixed passport closing after timed_out() called 
  - *INTERNAL USE* Updated alert system in endlessGame and BorderRunnerSystem
  - Ability to kill potato after it is accepted if there is a runner, penalty of 500 points
  - Add 10 paths for accepted potatoes
  - Add 10 paths for rejected potatoes
  - Add 10 paths for runner potatoes
  - Add 3 strike system and warn when wrong.
  - Add 8 different potato gibs that explode from a hit potato, with more exploding from a perfectly hit potato
  - Add dialogue to the megaphone
  - Add global score and shifts to extend play session
  - Add letter with brief explainer on your job as a Spudarado Border Officer
  - Add number of eyes as an attribute of personally identifiable information to the spuddy passports
  - Add random selection of background music on launch
  - Add restart button to game over screen
  - Add score to both the success_scene.tscn and the game_over.tscn, then end of shifts functions as a soft-end and a way to heal for high-scoring.
  - Add working game over constraints
  - Added community members who helped with bug reports to credits
  - Alert, larger and centeredHighlight on the speaker
  - An approval stamp and rejection stamp that you pick up with left click, drag over the document to set approve or reject status. 
  - Approval message is the wrong format, should be large green text
  - Audio settings
  - Bulletin card system
  - Can't see the mouse cursor > Attribute: https://steamcommunity.com/app/3291880/discussions/0/4637115050041082833/
  - Centered alert text
  - Change score display to be out of 25. Change scene to success_scene once completed. In success_scene, move back to mainGame and pass the score back.
  - Change spawn timer to not stop timer when hitting max
  - Change the texture for Sprite2D (PotatoMugshot) to match the type of potato using these headshot paths: 
  - Change the texture of the Sprite2D on the PotatoPerson to the appropriate type based on their potato_info.type
  - Changed background color of dialogue boxes
  - Changed character actions from italic to colored text
  - Changed minimum speed of potato gibs to allow for more even gib distribution
  - Check potato sex check logic, only males is giving points on allowing female potato
  - Click the document and drag the document onto the potato to return the document.
  - Clock on the suspect table
  - Close passport
  - Collision for the draggables to stay in the lower half of screen
  - Create approved and rejected stamps images that fit the size of the passport document
  - Create Label (DateLabel) and add to the Potato Customs Table so the player can see the current date and judge if passports are expired.
  - Create NodePath2d for approved spuddies
  - Create NodePath2d for border running spuddies
  - Create NodePath2d for rejected spuddies
  - Create NodePath2d for spuddies entering office
  - Credits menu (Main menu scene)
  - current_rules should have a maximum of 1-2 rules. 
  - Cursor disappears after stamping
  - Cursor which changes on interaction hover 
  - Custom cursor for hover, click, grab, drag
  - Customize the passport document to be fully original
  - Cut items off when they leave interaction table
  - Date system
  - days_until_expiry, returning IMPOSSIBLY high numbers
  - Disclaimer menu (Main menu scene)
  - Discuss new font
  - Document displays in evidence drawer.
  - Enable pause menu
  - Expired passports now properly apply rejection logic and give alerts to the player on processing.
  - Explain how to flip the pages on the document in the tutorial
  - Fade out passport when giving potato documents back
  - Fill in additional detail on stamp objects
  - Fix bug where passport re-appears after callback for departed potato
  - Fix bug with clicking speaker before first potato 
  - Fix fade from/to black outline for potato mugshot
  - Fix potato mugshot changing to the next potato in line before the current potato has been processed
  - Fix stamp animation
  - Fix text color, should be white with black outline
  - Fixed a few issues with z-ordering on textures
  - Fixed alert timer not triggering
  - Fixed checking for strike total to send player to game over
  - Fixed removal of strike when you successfully murder a potato with an air-to-surface missile
  - Fixed score update after approving Spuds for entry
  - Fixed strike additions when Spuds run the border
  - Fixed wrong formatting on a few alert pop-ups 
  - Flip to game over and show high score when 3 strikes hit. 
  - Fullscreen button
  - generate_rules() has 7 entries in current_rules, this should be expanded. 
  - Give more time to make decisions (30 seconds suggested by @KotBud)
  - Hit 25 points without getting 3 strikes. 
  - Hook up restart / main menu buttons from summary menu
  - How do we tell the new player what to do to get through first potato processing?
  - If you do not kill a potato while it is running the border it repeats
  - If you spam stamps then multiple show up
  - Increased missile speed by 100 (500 -> 600)
  - Initially the Sprite2D Passport is hidden until a PotatoPerson is called into the customs office, at which point the child Sprite2D (Close Passport) is animated going across the suspect panel and settling at the bottom for the player to pick up. 
  - Integrate bgm handler, sfx handler
  - is_potato_valid() must support multiple active rules in current_rules at once. 
  - Laws are not displaying on first potato
  - Laws are not showing up in the guide book
  - Made expiration law apply as expected (if past date)
  - main menu
  - Make a closed passport icon (128x128px)
  - Make an options menu
  - Make difficulty a global var
  - Make full-screen appear in the main game instead of just the main menu
  - Make intuitive stamp mechanic
  - Make music start on main menu instead of game
  - Make stamp interaction be, left click to pick up, left click to stamp, right click to drop. 
  - Make sure missile leaves a crater
  - Make the flashing icon on the megaphone larger
  - Make the flashing icon on the megaphone larger
  - Make toggle audio button on main menu work
  - Measure and trigger the win condition on score, similar to quit. 
  - Merge the new_potato and spawn_new_potato functions and have them managed by the queueManager
  - More papers to shuffle around
  - Move 4th page of instructions to page 1
  - Move tutorial to the front of the document
  - Move tutorial to the front of the document
  - Moved lowest path for rejected Spud higher to avoid z-order issues
  - Music system (Main menu scene, smooth transition, game scene)
  - No longer subtracts points if the player does not have points
  - Open passport
  - Overlay of potato customs officer talking
  - Passport has a transparent stamp applied, player picks up and returns to potato.
  - Passport will now always come out of the slot
  - Passports break after 2nd potato enters
  - Picking up stamp hides cursor
  - Player clicks approve or reject stamp and a stamp comes down on the passport. 
  - Player clicks document. 
  - Player clicks stamp drawer to bring stamps into evidence drawer. 
  - Player drags closed document to evidence drawer. 
  - Player reviews document. 
  - Potato expiration dates are always in the past, need a separate FUTURE facing function
  - Potato fades out and appears to left of customs office. 
  - Potato moving in after decision processing, before megaphone pressed
  - Potato persons are above the customs office when called into the office
  - Potato persons flip upside down when called into the office
  - Potato walks off-screen to left or is destroyed mid-way.
  - Potato walks up, puts in document. 
  - Potatoes which run the border after being denied entry don't trigger BorderRunnerSystem
  - Randomize path that the runners traverse
  - Re-enable Label (ScoreLabel) on Customs Table
  - Redraw megaphone
  - Reduce time before start of queue
  - Reduced approval score from 1,000 points to 250 points
  - Reduced chance of Spud running the border from 30% to 15%
  - Remove Anti-aliasing from options
  - Remove camera shake from options
  - Remove invalid/inconsistent rules (remove expiration related rules and just properly process expiration)
  - Remove Mr. Potato from first names
  - Remove potato types from mugshots and passports and replace with procedural character generator
  - Remove potato types from mugshots and passports and replace with procedural character generator
  - Remove reset game data from options
  - Rephrase all laws to be more clearly negative
  - Replace the buttons for Welcome to Taterland and No Entry with stamps that the player can pick up and use to stamp the potato person's documents, punch down stamp with right click while dragging.
  - Reset score if you fail
  - Review rules and make sure applying properly
  - Rounded edges of UI elements
  - Scale up potato information in the passport to be more visible.
  - Score is added or removed based on accuracy of judgement.
  - Settings menu with graphics, audio, accessibility, rebinds
  - Shadows when the player begins to drag the item, they can click with no reaction
  - Show the appropriate leaderboard out of 3 Leaderboards based on the difficulty_level global
  - Slow down potato leaving the customs office
  - speaker sound when click megaphone for next person to come up
  - Splash-screen text 
  - Split out the customs office and megaphone and create sprites for them so the potatoes will appear to go inside the office
  - Split out the customs office and megaphone and create sprites for them so the potatoes will appear to go inside the office
  - Split stamp into two separate objects
  - Stamp doesn't match the rest of the pixel feel, different resolution
  - stamp interaction instead of buttons
  - Steam.uploadLeaderboardScore( score, keep_best, details, handle ) 
  - Switch megaphone alert to be off when the box has someone in it
  - The potato does not leave the customs office when the time runs out, set x/y
  - The potatoes generate new images too early, when added to queue instead of when called into customs office
  - Then the Sprite2D (Close Passport) is animated going down from the Sprite2D (PotatoMugshot) and settling at the bottom of the InteractionTableBackground for the player to pick up. 
  - Then use the approval_status to decide whether to add the PotatoPerson to the Path2D (ApprovePath) or the Path2D (RejectPath) based on approved or rejected status respectively and move them to the end of the path, then remove them. 
  - Transition to game lose scene, "You have unjustly denied permitted potatoes entry, you will be roasted. You have disgraced the potato motherland."
  - Transition to game win scene, "Your shift is over, you will be re-planted, you have served the potato motherland."
  - Transition to win game screen, outline limit "Only allow 25 permitted potatoes to enter. You will be returned to your family if successful. Otherwise you will be roasted."
  - Troubleshoot Colcannon rule
  - Tuberstan and Pratie Point rules, one is not evaluating properly
  - Update "You made the right choice officer" and implement the green number score system instead
  - Update first page of Pamphlet with instructions
  - Update missile smoke system
  - Update pause menu
  - Update rules to include potato information.
  - Update the potato information to include sex, country of issue, date of birth, expiration date.
  - Update the process_decision logic to make the oldest potato move through the customs office get blown up with mini-nuke particle effects after their immigration decision is made and is negative.
  - Update the process_decision logic to make the potato in customs office move through the customs office and all the way to the left side of the screen after their immigration decision is made and is positive.
  - Update the queue_manager to store potato information about each potato in the queue including condition, type, and name.
  - Update the remove_stamp function or create a new function to Tween the Sprite2D (Potato Mugshot) to move to the left of the Sprite2D (Suspect Panel) and disappear.
  - Updated font for dialogue
  - Use flashing circles and text to walk the player through processing their first document. Click by click. 
  - Use Steam name and avatar on the leaderboard use Steam.AVATAR_SMALL for the leaderboard
  - What do we tell the player when they lose? 
  - What do we tell the player when they win?
  - When clicked, the book object morphs into an opened document showing the information for the potato immigrating.
  - when dragging, set shadow for stamp to visible and invisible otherwise
  - When the player clicks on the Sprite2D (Megaphone) on top of the customs office in mainGame.tscn, the next PotatoPerson is removed from the front of the Path2D (SpuddyQueue) and the QueueManager, and the PotatoPerson is moved along the Path2D (EnterOfficePath), then the PotatoPerson is removed and the Sprite2D (PotatoMugshot) slides onto the Sprite2D (Suspect Panel) from the right and goes from a dark black outline to the regular texture.
  - when you close document
  - when you open document
  - Windowed mode breaks resolution and causes you to see outside viewport
  - years_until_expiry, returning impossibly high numbers
  - You can no longer see the Spud when it enters the office from the right
# OFFICIALLY COMPLETED TASKS
## Steam Minor Update 1.0.1: General bug fixes - ALREADY RELEASED
## Steam Release 1.0.0: Demo release - ALREADY RELEASED
- "Rotten potatoes strictly forbidden" and "all potatoes must be fresh" entry granted, said good job, gave +1 to quota and +1 to strikes
- "Sprouted potatoes need additional verification and must be denied", change to not include verification
- *INTERNAL USE* Cleaned up the old git branches from various updates
- *INTERNAL USE* Speed up passport through slot, decrease by 0.5-1.5 seconds
- Able to drag passport off interaction table, bound them to lower half of screen
- Able to drag stamps off interaction table, bound them to lower half of screen
- Add 25 variations of main menu music and 75 variations of main game music
- Add a condition for if the player skips the final narrative so that the end credits are still signalled 
- Add a confirmation for resetting story progress (not highscores) to New Game
- Add a growth bounce tween or shrink bounce tween to the quota and strikes labels when they change
- Add a language selection option to game option menu
- Add a loss of 250 points on top of strike if the rejection was incorrect (Use the same code as the border runner system to check for point penalty)
- Add a Metal shutter that rolls down cinematically with segments that cascade down, dust particles as it hits bottom, a satisfying "clunk" sound effect
- Add a missile targeting restriction region to prevent accidental missile launches when clicking UI elements
- Add a skip button to dialogic
- Add a version counter
- Add ability to skip to end of Dialogic timeline with button in Upper left "Skip"
- Add an on_dialogue_start and on_dialogue_finished call to stop the BGMPlayer and then start next random track when back in game scene
- Add Arludus to credits: https://arludus.itch.io/2d-top-down-180-pixel-art-vehicles
- Add button to reset campaign progress
- Add button to reset highscores
- Add cars that drive by from the top to the bottom of the screen
- Add clearer feedback for game over conditions ("Too many strikes, you lose!")
- Add day-by-day shift selection the player unlocks as they progress
- Add dialogue emotes randomly to the potatoes, Potatoes emote (Kenny emotes) while waiting in line
- Add distinct buttons for resetting story progress, resetting high scores
- Add footsteps visuals to the potatoes
- Add if check to BorderRunnerSystem.gd to check if user is currently in dialogic timeline, if so than do not spawn runners
- Add if check to launch_missile() in BorderRunnerSystem.gd to check if user is currently in dialogic timeline, if so than do not spawn potatoes
- Add if check to QueueManager.gd to check if user is currently in dialogic timeline, if so than do not spawn potatoes in queue
- Add leaderboards for each level to support shift summary screen (shift_0_easy, shift_1_normal, shift_2_expert, etc)
- Add logic to check if game paused or in dialogic before updating cursor to target cursor
- Add minor random size scaling to explosions for visual variety
- Add new compressed MP3 music and sound effects to all scenes for enhanced emotional impact
- Add new missile explosion animation
- Add new potato type art and re-institute potato type rules
- Add new potato type corpse art
- Add pitch variation to the positive and negative score sound
- Add random x/y-axis variation on the position selected in the return to table function
- Add score attack mode back in by inheriting mainGame and overriding scoring rules
- Add simple fade to game over summary
- Add small amount of random pitch variation to the document open and close sounds
- Add smooth animations for the shutter gate lever going up and down
- Add sound effects to each narrative scene
- Add to Attributions.md - Button SFX: https://opengameart.org/content/click-sounds6
- Add to Attributions.md - Emotes: https://kenney.nl/assets/emotes-pack
- Add to Attributions.md - FilmCow Sound Effects: https://filmcow.itch.io/filmcow-sfx
- Add to Attributions.md - Social Icons: https://krinjl.itch.io/icons2
- Add Version Counter into main menu
- Add whoosh to shift summary journal and leaderboard journal
- Added emotes for potatoes in line
- Added full localization for 18 languages in addition to English (cs  da  de  es  fi  fr  hu  id  it  nl  no  pl  pt  ro  sk  sv  tr  vi)
- Added social icons to main menu
- Adding fade to skip or end of dialogic sequences so it doesn't abruptly switch
- Adding in initial 4 potato races, laws, and suspect booth/world sprites for them
- After hitting new game, Continue should also load the first level as if data were cleared
- Alert Text: Wrong font sizing, causing blurry text
- Allow firing missiles even when no active runner
- Allow firing multiple missiles at once
- Allow multiple simultaneous runners, can we multi-thread this?
- Backend: Error handling if Steam is not loaded
- Balance points (missiles, stamping, scanning)
- Border runner system went off twice and cancelled the first one out (We overhauled the entire system)
- Bubble Dialogue: Implement into the Drag and Drop system for dropping a passport onto a potato to have varied dialogue instead of the same hardcoded text
- Bug: Audio on shutter does not sync
- Bug: Passport text disappears while dragged
- Bug: Stamps fly up from the bottom of the screen
- Bug: Text disappearing on the law receipt when picked up
- Cannot generate female potatoes via mugshot generator
- Cause potatos on shift summary screen to rotate based on their horizontal speed
- Cause stamps to wiggle and slam in and then fade into color on shift summary
- Center closed version of documents on the mouse position, it often appears offset
- Center explosions on the targeted location
- Change "Runner Escaped" to Capitals
- Change "Runner Escaped" to capitals
- Changed character action text from italics to colored text (We represent story character actions differently now)
- Check for failing date rules, especially months_until_expiry()
- Check if the stamp rejection was correct before triggering the border run system for the scores to be accurate
- Check if there is a Dialogic 2 end audio function, implement after each keyboard audio call through all 11 .dtl resources
- Code: Move cursor system out of drag system
- Color match the lever to dark blue / grey tones, and improve the quality
- Corpses added too high to tree, screen shake not affecting them
- Create system to detect current cursor shape and update the sprite to match
- Cursor / Bug: Offset to the right a bit
- Cursor does not update when hovering above megaphone
- Cursor does not update when hovering above stamp bar button
- Cursor: Add mulitple hover modes
- Cursor: Update while dragging documents
- Cursor: Update while hovering over documents
- Cursor: Update while hovering over megaphone
- Cursor: We need a hover for grabbable documents (Passport, Law Receipt) and a hover for interactable objects (Potatoes, Megaphone)
- Customs booth talk bubble not translating
- DaDS / Bug: LawReceipt does not close when dragged off inspection table
- DaDS / Bug: When you drag a document to close it, it does not center on the mouse 
- Darkest point of potato is darker than darkest point of GUI
- Demo: Create demo version of game without Score Attack mode, only shift 0, 1, and 2
- Deploy 1.1 to Public Test
- Dialogue sign outside customs office isn't disappearing after a few seconds
- Disable ability to skip final cutscene so the player doesn't skip right into end credits - NOT NEEDED
- Disable narrative manager when in score attack mode
- Display max score for each shift and 0-3 golden potatoes / stamps based on score benchmarks for each shift
- Display Score for Longer Duration (2s -&gt; 3.5s)
- Display the score for longer, a few seconds, so the player can read it
- Documents appear above the stamp bar when dragged
- Documents should move themselves into the inspection table if opened and clipped outside the table
- Drag and Drop: Clip the document edges if they are off the table
- Drag and Drop: If the passport hasn't been stamped and is dropped on the potato, it should return to table
- Drag and Drop: If the passport hasn't been stamped and is hovered over the potato, it should not prompt the dialogue
- Drag and Drop: Law receipt passes between the passport description/photo and the passport background
- Drag and Drop: Passport text and photo appear over the LawReceipt
- Drag and Drop: Stamps disappear on passport while being dragged
- Emote System / Bug: When potatoes are clicked it only displays love emotes, could be set to display HAPPY category
- Emote System: Implement a variable delay between emotes
- Emote System: Reduce frequency of emotes occuring
- End scenes not triggering for shifts (should they be before the shift summary screen, or after the player clicks continue on the shift summary screen?)
- End shift dialogues don't appear to be triggering properly, test having it before shift summary screen?
- Environment: Cars passing by
- Expand area for perfect hit chance on border runner system
- Expiration rule is wrong, passport was expired and got strike for denying entry
- Fade in potatoes when they come into the customs office
- Faster velocity or more centralized location for missile
- Final cutscene not triggering
- Finish remainder of narrative translations
- Finish translating Shift Summary screen
- Fix audio reference issues with gunshots in vengeance ending
- Fix bug where summary screen restarts back into endless mode instead of story mode
- Fix missile getting stuck bug, store last position of mouse on potato escape. If the missile is in flight when the spud escapes off the road, the missile freezes and remains until the next escape attempt.
- Fix potatoes using wrong spritesheet for assigned race / sex
- Fix SceneLoader issues, direct scene transitions break overlaid menus in Shift Summary but using SceneLoader.load_scene with a reference to the desired scene isn't working either, and no error is being produced.
- Fix skip story bug not hiding the history button quickly
- Fix stamping animations so that they move down from the stamp crossbar and are behind it
- Fix text on main menu and other scenes with background photos
- Fix the issue where the game continues running during story sequences
- Fix z-ordering issues on the summary screen
- Fix z-ordering with potatoes to pass them under the background layer
- Fixed law wording: "Frozen potatoes require a special permit", change to not allowed because there is not special permit
- Fixed law wording: "Reject Spuddington potatoes because of visa counterfeiting activity.", there is no visa system, reword "visa" to "document"
- Fixed law wording: "Young potatoes (under 2 years) need guardian.", there is no guardian system, reword
- Footsteps must be positioned at the bottom of the potato sprites
- Game not fully unpausing for shift end dialogic cutscenes, maybe don't add the pause to end_shift 
- Gate re-raises on megaphone click, even when already up.
- Get alerts translation working
- Get Border Runner System alerts working
- Get BRS perfect hit alerts working
- Get law translation working
- Get Perfect Stamp Alert translation working 
- Get Shift Summary translation working
- Get UI translation working
- Give Passport Prompt should not appear if the passport has not been stamped, this check would be in main game
- Hook up game won, level lost, and level won scenes to gameUI scene
- If potatoes are rejected, they should exit through the right side instead of the left
- If you deny/accept a potato and then that potato times out, it still checks the stamps
- If you restart on shift summary screen, it advances to the next level
- Implement screen shake on stamping, missile hit, perfect missile hit of varying intensity
- Improve art quality of stamp bar interface (basic doodling that isn't copy/paste)
- Law text disappearing when you pick up the opened law document
- LawReceipt: Use BBCode to display the important elements of laws
- Lower delay between stamps
- Lower z-index of crater below that of the potato_person runner
- Make explosions smaller
- Make Missiles Travel Faster and More Consistently
- Make quota include difficulty level as well
- Make rejected potatoes walk away even slower
- Make sure interacting with a stamp blocks picking items up
- Make sure quota is added before shift ends (shows 7/8 often now)
- Make sure stamp bar controller does NOT show on top of shift summary screen
- Make sure strikes are added before shift ends
- Make sure survival bonus alert shows on shift summary screen
- Make sure that game state is reset properly between story and score attack modes within the Global.gd and GameState.gd, and make sure that narrative progress and high scores for each narrative level and each score attack level are saved appropriately
- Make sure that stamp consistently marks the same spot on the document, NOT based on where the player clicks on the stamp
- Make the missile travel time consistent and predictable
- Make the score attack button on main_menu_with_animations load the appropriate score attack mode scene similar to main_game_ui.tscn
- Make the tutorial interactive instead of a text panel with the book
- Make two sets of paths, one which start in the office and one which doesn't for Spud runner, only do the office start when they are already in office
- Megaphone: Update core to have button for mouse interactions instead of Area2D (Or alongside Area2D if you don't feel like updating other code references)
- Move shift summary to end of game, not end of shift, on quota reached restart, on strikes reached end game
- New game button starts day 1 instead of day 0!
- New game continues right now, should go back to tutorial
- New game must always use tutorial, and SHOULD wipe data, then load the correct level
- No ambience or background music playing
- Office Shutter / Bug: The user should not be able to pass the potato documents if the shutter is closed
- Office Shutter: Shutter opens even when open when a potato comes into the office
- Office Shutter: When shutter is automatically raised, the potatoes stay shadow-y
- Only show take passport dialogue if the passport has been stamped
- Overhauled interaction system
- Overhauled rocket system
- Overhauled stamping system
- Playtest: Beat Story mode, and test vengeance ending 
- Possibly exit the game from the lose screen
- Potato footsteps appearing on top of shift summary screen (two tweens were conflicting)
- Potato stays in shadow when the shutter automatically raises
- Potatoes continued to escape during the Shift Summary, make sure to disable QueueManager and BorderRunnerSystem in the game_over function.
- Potatoes in queue don't seem to match up with potatoes that enter customs office (MugshotGenerator is using diff potatoes lol)
- Progression for story not saving/loading properly
- QoL: Shadow fade-in similar to Papers, Please for potatoes entering the office
- QoL: Shadow when shutter is closed
- Queue Interaction: Highlight on hover of potato
- Quota maximum not updating at start of shift
- Quota met, shift completed not translating as expected
- Record and add 3 GIFs of gameplay to all store pages
- Record new screenshots showing different aspects of gameplay
- Record new trailer showing 1 shift of gameplay
- Reduce lead time for missiles
- Reduce z-index of the potato footsteps and add them to a group for end_shift fade
- Regenerate potato images for each character in narrative, 16 total
- Remake Score Attack mode and score at least 25 potatoes
- Remove Italics in the story text that represented actions, Tester understood after 2-3 texts
- Remove Law slider and keep law pamphlet as a draggable object
- Remove the date and score from the bottom of the screen (move to upper left, ala Rogue Genesia?)
- Replace missile sprite
- Resolve missing passport documents in story mode
- Rewrite laws to make sense, bad wording (I rewrote 3 of them, not sure what this meant, it's from months ago)
- Rounds end too abruptly, need to tell the player why they failed
- Runner Escaped! Strike Added! Message shown in English <- BorderRunnerSystem?
- Runner potatoes are registering TWO strikes instead of just 1
- Runners: If a runner is currently emoting when they begin a run, it seems to spawn two emotes
- Save game and load game, especially difficulty, camera shake, max level reached and local highscores
- Score might not be resetting between rounds on leaderboard. Must be reset in Continue, Restart, Main Menu calls.
- Score not resetting when continuing shifts
- Score should always be represented as a float on backend, check and make sure this is the case save for printing it to the UI
- See if pitch variation can be added to background music
- Select additional background music for /music folder
- Set a highlight shader on the closed passport if the document goes untouched for >15 seconds
- Set a highlight shader on the speaker/start button if the booth goes empty for >15 seconds
- Set a highlight shader on the stamps or stamp bar open if the document is open on the table for >15 seconds
- Set main game audio to mute when dialogue starts and start a new background song on BGMPlayer when dialogue finishes
- Shift end bonus not applying properly
- Shift increasing by 2 on shift completion; game goes from shift 10 to shift 12 and appears to skip the end of the game
- Should trigger show day transition after Continue button pressed
- Show the missile immediately on click from customs office, or from off-screen
- Shrink missile firing zone on the bottom, overlaps with inspection table
- Shrink texture for missiles and impacts, sizing of pixels is off-putting
- Shutter raises everytime a potato enters the office
- Simplified story
- Simplify stamp controls explanation in Guide book
- Skip button not disappearing, and resetting the shift when pressed
- Slow down base speed of runners
- Slow down the end shift sequence
- Snap closed passport to position of mouse cursor to avoid bad offset
- Sometimes the potatoes don't give you a passport
- Spud runner attempts never stops. Alt tabbed out, paused, shift summary, no matter what, the spuds escape like clockwork.
- Stamp rejection doesn't update score
- Stamp System: Stamps disappear when picked up and dragged
- Stamp System: Why are the particle effects and global alert not visible / not triggering when a perfect stamp is placed in the top and middle 1/3rd of a document?
- Strike removed! +250 points! Message shown in English <- BorderRunnerSystem?
- Submit score button is responding, but continue, main menu, and restart are not working on the shift summary screen anymore
- Test megaphone to make sure it works in all cases
- Test new font in Shift Summary Screen and menus
- Test Shift 6 - 11 and see if end credits trigger
- There is no continuing shift, after you reach quota you hit the shift summary and end the game
- Troubleshoot shutter lever disappearing
- Turn down the splashscreen sound on game start
- Update ATTRIBUTION.md with MODERN DOS font
- Update backend for megaphone dialogue prompt in-game to allow for future translation
- Update color palette for Shift Summary screen and update font spacing
- Update cursor in the main menu when hover over buttons
- Update cursor to show a select icon when above the megaphone 
- Update cursor when hovering over the megaphone
- Update explosion
- Update guide to use just left-click interactions rather than requiring both mouse buttons
- Update leaderboard logic to refer to appropriate new leaderboards
- Update menus with new MODERN DOS font
- Update potato rain to look more natural
- Update stamp buttons to use the correct offsets and starting positions
- Update stats on potato escape and missile kill
- Update store translations for description and short description
- Update text on Guide book
- Update tutorial step with exploding runner
- Update where strikes and quota show on UI
- Updated art for border_chaos, fix dog-face man and best employee picture
- Updated art for checkpoint_interior, fix hat direction
- Updated art for loyalist_outcome, too human
- Updated art for night_attack, remove human man in background
- Updated art for night_checkpoint, messed up characters
- Updated art for personal quarters, style break, random
- Updated art for processing_facility, remove random messed up potatoes
- Updated art for reckoning, fix grain
- Updated art for security_lockdown, washed out
- Use the "Default cursor shape" property to update cursor state
- Use the smoke spritesheet to animate a trail for the missiles
- victory_scene, fucked up faces
- violation_expired_document translation key not loading
- violation_females_only translating key not loading, loading extra? selection under the Game Tab
- When gate is lowered, have the potatoes in shadow and allow no interaction
- When hit with a missile, make the Runner corpse spin up in an arc opposite the direction of the missile impact, then bounce on the ground at the same y-level as corpse started at before coming to a rest
- When maximum strike reached nothing happens, only checks when above maximum strikes instead of equal to
- When potato escapes, if it does so mid click (such as clicking on the speaker or a passport), the missile fires at the place you clicked on the screen. Constrain it to the Area2D for targeting potatoes on the left side of the screen, you could simply check cursor status.
- When the passport is on left side of the inspection table it should remain open to make it easier for users to line up with the stamp bar
- When you correctly reject a potato it does not give you the 250 points
- Wrong shift displaying on shift summary screen
- Yukon Gold potatoes must be fresh given an error when it should be passing
- Z-index: Dragged passport appears below the suspect table
If a label is marked with *INTERNAL USE* then do *NOT* include it in the official release post to Steam.
The tasks which have be completed and pushed to Steam.
When adding to the lists, please either rephrase immediately or separate your tasks to be rephrased later for proper release.