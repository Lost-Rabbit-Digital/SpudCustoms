# Scratch Pad
These are our goals, to-do tasks, and completed tasks.

# FULL RELEASE TASKS - 2025-02-28 - 1.0.2

## Tasks
### Graphics
  [ ] - Missile explosion animations continue playing in the pause menu
  [ ] - No female potatoes sprites ever generated in mugshot generator, despite female passports?
  [ ] - Add a yellow alert with information about the shift displayed like a typewriter in the middle of the screen, "Shift 1, Happy Days, 07:00" that then fades away
  [ ] - Make sure scores are shown above their respective action (stamping, missiles, scanning)
  [ ] - Add new potato type art and re-institute potato type rules
  [ ] - Fix text on main menu and other scenes with background photos
  [ ] - Physics on suspect panel and interaction table with items (Gravity, dropping, throwing)
  [ ] - Add ink flecks from stamping that randomly stain the document around the stamp application edges
  [ ] - Add dialogue emotes randomly to the potatoes
  ===
  [ ] - Add different types of documents, entry passes, work permits, baggage, visas, marriage licenses, bribes 
  [ ] - Add an Entry ticket document and law requirement
### Gameplay
  [ ] - Allow murdering accepted potatoes on their way through the border checkpoint using existing border runner system with a strike, 500 points deducted, and "Totneva Convention Violation!" warning through Global.display_red_alert
  [ ] - BONUSES section in shift summary should show both perfect hits bonus score, as well as stamp accuracy bonuses. 
  [ ] - Set a highlight shader on the closed passport if the document goes untouched for >5 seconds
  [ ] - Set a highlight shader on the speaker/start button if the booth goes empty for >5 seconds
  [ ] - Set a highlight shader on the stamps or stamp bar open if the document is open on the table for >5 seconds
  [ ] - Display max score for each shift and 0-3 golden potatoes / stamps based on score benchmarks for each shift
  [ ] - Change position so kill text flying up with the score update ("Runner " + potato.first_name + potato.last_name + " neutralized...")
  [ ] - Add clearer feedback for game over conditions ("Too many strikes, you lose!")
  [ ] - Add flash arrow pointing from the left to the right indicator for megaphone
  [ ] - Conversation with potato while checking documents, similar to customs office dialogue, Terry Pratchett inspired
  [ ] - Fix z-ordering issues on the summary screen
  [ ] - Make sure that game state is reset properly between modes and with the Global.gd and GameState.gd files both managing states
  [ ] - Potatoes emote (Kenny emotes) while waiting in line
  [ ] - Wave a mouse over bombs placed on the wall or upper wall in the background to defuse them for scoring
  [ ] - Repaint each cutscene that stands out as rough in Aseprite (use dedicated 16-32 color palettes, repaint in simpler forms)
  ===
  [ ] - Set default selection for main menu for keyboard control
  [ ] - Lower delay between stamps
  [ ] - Make the instructions an overlay which you could close
  [ ] - Show Missile counter on an LCD display on the desk or on UI
### Audio
### Score System
  [ ] - Balance points (missiles, stamping, scanning)
### Backend
  [ ] - Save game and load game, especially max level reached and local highscores
### General Bugs
  [ ] - Score might not be resetting between rounds on leaderboard. Fairly sure mine just kept going up.
  [ ] - Potatoes appear above table instead of under when border runner leaves map on south side
  [ ] - Add Difficulty selection UI after selecting endless mode? Should explain difficulty parameters if so.
  [ ] - Add message queue system and delay between messages so they don't override each other, add GDScript to alert_label
  [ ] - Change time to a shift-based time, such as 8 hours over a day
  [ ] - Check why date rules keep failing make sure expiration date is referencing correct variable, and that it's evaluating properly, especially months_until_expiry()
  [ ] - Expiration rule is wrong, passport was expired and got strike for denying entry
  [ ] - Link summary screen to restart back into endless mode instead of story mode
  [ ] - Make sure the endless doesn't end too early
  [ ] - Make two sets of paths, one which start in the office and one which doesn't for Spud runner, only do the office start when they are already in office
  [ ] - Possibly exit the game from the lose screen
  [ ] - Randomly lose combo when doing potato border runner system
  [ ] - Update ATTRIBUTION.md with MODERN DOS font
  [ ] - Update menus with new MODERN DOS font
  [ ] - Update stats on potato escape and missile kill
### Law Bugs
  [ ] - "Rotten potatoes strictly forbidden" and "all potatoes must be fresh" entry granted, said good job, gave +1 to quota and +1 to strikes
  [ ] - "Sprouted potatoes need additional verification and must be denied", change to not include verification
### Score Bugs
  [ ] - Strikes on endless mode do not reset after summary screen, summary > main menu > endless mode
  [ ] - Stamp rejection doesn't update score
  [ ] - Check if the stamp rejection was correct before triggering the border run system for the scores to be accurate
  [ ] - Now that the Runner System has support for multiple runners, include a chance to run while waiting in line for each potato instead of waiting for rejection or the global timer
  [ ] - Score should always be represented as a float on backend, check and make sure this is the case save for printing it to the UI
### Stretch Features
  [ ] - Add cars that drive by (where would these go? On road from bottom to top on far left of screen?)
  [ ] - Baggage inspection, grab bags and shake them with bugs and coins flying out until you get a "BAG CLEAN" and a small number of points, or contraband detected where you get points for clicking it
  [ ] - Multiplayer? 8th / 15th of November for schedule
  [ ] - Use top 3 scores for leaderboard, then show ... and show 3 scores above player and 3 scores below player (if any), with players score in middle. 
  [ ] - UV lamp represents a high-risk way to maximize points.
  [ ] - Randomly toggle the lights on and off in customs office and Border Wall like people are using the rooms


## Steam Minor Update 1.0.2 - WORK IN PROGRESS
### To-Do
  [ ] - Stamps go over edge of passport
  [ ] - Update cursor when hovering over the megaphone
  [ ] - Check if there is a Dialogic 2 end audio function, implement after each keyboard audio call through all 11 .dtl resources
  [ ] - Update backend for megaphone dialogue prompt in-game to allow for future translation
    [ ] - *INTERNAL USE* Change megaphone dialogue box to be text files printed on instead of hardcoded words for ease of localisation
    [ ] - *INTERNAL USE* Speak duration parameter
    [ ] - *INTERNAL USE* Have audio built into dialogue box
    [ ] - *INTERNAL USE* Have two JSON sections, "next queue" and "general sayings", different names but you get the idea
    [ ] - *INTERNAL USE* JSON to store strings instead of hard-coding into images
    [ ] - *INTERNAL USE* Just one background image for the dialogue box
  [ ] - Add logic to check if game paused or in dialogic before updating cursor to target cursor
  [ ] - Improve stamp and interaction system integration
  [ ] - Turn down the splashscreen sound on game start
  [ ] - Code: Move cursor system out of drag system

### Currently Active Tasks for 1.0.2
  [ ] - Documents should have gravity on the suspect panel and should fall to the counter
  [ ] - Do not allow the user to pick up the document through the stamp bar
  [ ] - Documents should move themselves into the inspection table if opened and clipped outside the table
  [ ] - Add small amount of random pitch variation to the document open and close sounds
  [ ] - Update cursor to show a select icon when above the megaphone 
  [ ] - Update cursor to show a select icon when above the approval or rejection stamp
  [ ] - Only show take passport dialogue if the passport has been stamped
  [ ] - Update take passport dialogue to use the new dialogue system (Same as for megaphone) 
  [ ] - Add the different categories of megaphone into the megaphone_clicked function in mainGame.gd
  [ ] - Test megaphone to make sure it works in all cases
  [ ] - Bug: Documents appear above the stamp bar when dragged
  [ ] - Bug: Cursor does not update when hovering above megaphone
  [ ] - Bug: Cursor does not update when hovering above stamp bar button
  [ ] - Audio: Small sound for hovering above megaphone or stamp bar button

### Completed Tasks for 1.0.2
Before release, review GitHub commits using the following command `git log --since="last month" --pretty=format:'%h,%an,%ar,%s' > log.csv` - This artifact can then be fed into Claude or similar to analyze the changes.
  - Double vertical spacing on level select screen to fit in GOLDEN STAMPS
  - Bring Document Stats onto left side of Shift Summary Journal
  - Move SHIFT COMPLETE notice up closer to header in Shift Summary Journal
  - Increase horizontal width of level select display by 25% to accomodate level high scores as well as completion grade icons
  - Change FINAL SCORE to Total Score, move total score to PERFORMANCE section on Shift Summary
  - Make sure that the screen shake variable in the video sections of the options menu is being used by the screen_shake function in mainGame.gd, move screen shake to Global.gd and fetch current root node
  - Create a higher saturation cutout of the Leaderboard summary success stamp for the level select screen
  - Fix the issue where the game continues running during story sequences
  - Add footsteps behind potatoes that slowly fade out to 20% opacity
  - *INTERNAL USE* Speed up passport through slot, decrease by 0.5-1.5 seconds
  - Remove the date and score from the bottom of the screen (move to upper left, ala Rogue Genesia?)
  - Escape key for menu stopped working after I alt tabbed a few times and completed the first "day". Likely due to scene change causing viewport w/ options/pause menu to be lost.
  - Hook up game won, level lost, and level won scenes to gameUI scene
  - Move shift summary to end of shift, on quota reached restart, on strikes reached end game without option to continue
  - When maximum strike reached nothing happens, only checks when above maximum strikes instead of equal to
  - Potatoes continued to escape during the Shift Summary, make sure to disable QueueManager and BorderRunnerSystem in the game_over function.
  - Allow multiple simultaneous runners, can we multi-thread this?
  - Add a loss of 250 points on top of strike if the rejection was incorrect (Use the same code as the border runner system to check for point penalty)
  - Remove Law slider and keep law pamphlet as a draggable object
  - Rounds end too abruptly, need to tell the player why they failed
  - There is no continuing shift, after you reach quota you hit the shift summary and end the game
  - Add simple fade to game over summary
  - Make sure interacting with a stamp blocks picking items up
  - Add a Metal shutter that rolls down cinematically with segments that cascade down, dust particles as it hits bottom, a satisfying "clunk" sound effect
  - When the passport is on left side of the inspection table it should remain open to make it easier for users to line up with the stamp bar
  - If potatoes are rejected, they should exit through the right side instead of the left
  - Fix z-ordering with potatoes to pass them under the background layer 
  - Center explosions on the targeted location
  - Use the smoke spritesheet to animate a trail for the missiles
  - Resolve missing passport documents in story mode
  - Sometimes the potatoes don't give you a passport
  - Display Score for Longer Duration (2s -> 3.5s)
  - Implement screen shake on stamping, missile hit, perfect missile hit of varying intensity
  - Add if check to QueueManager.gd to check if user is currently in dialogic timeline, if so than do not spawn potatoes in queue
  - Add if check to launch_missile() in BorderRunnerSystem.gd to check if user is currently in dialogic timeline, if so than do not spawn potatoes
  - Add if check to BorderRunnerSystem.gd to check if user is currently in dialogic timeline, if so than do not spawn runners
  - Show the missile immediately on click from customs office, or from off-screen
  - Fixed law wording: "Frozen potatoes require a special permit", change to not allowed because there is not special permit
  - Fixed law wording: "Young potatoes (under 2 years) need guardian.", there is no guardian system, reword
  - Fixed law wording: "Reject Spuddington potatoes because of visa counterfeiting activity.", there is no visa system, reword "visa" to "document"
  - Add Version Counter into main menu
  - Add a skip button to dialogic
  - Make Missiles Travel Faster and More Consistently
  - Change "Runner Escaped" to Capitals
  - Make the tutorial interactive instead of a text panel with the book
  - *INTERNAL USE* Cleaned up the old git branches from various updates
  - Simplified story
  - Overhauled rocket system
  - Overhauled interaction system
  - Overhauled stamping system
  - No ambience or background music playing
  - Add ability to skip to end of Dialogic timeline with button in Upper left "Skip"
  - Add day-by-day shift selection the player unlocks as they progress
  - Faster velocity or more centralized location for missile
  - Reduce lead time for missiles
  - Simplify stamp controls explanation in Guide book
  - Spud runner attempts never stops. Alt tabbed out, paused, shift summary, no matter what, the spuds escape like clockwork.
  - Update guide to use just left-click interactions rather than requiring both mouse buttons
  - Update text on Guide book
  - Add a version counter
  - Change "Runner Escaped" to capitals 
  - Display the score for longer, a few seconds, so the player can read it
  - Fade in potatoes when they come into the customs office
  - Improve art quality of stamp bar interface (basic doodling that isn't copy/paste)
  - Add a missile targeting restriction region to prevent accidental missile launches when clicking UI elements
  - Allow firing multiple missiles at once
  - Allow firing missiles even when no active runner
  - When you correctly reject a potato it does not give you the 250 points
  - Lower z-index of crater below that of the potato_person runner
  - If you deny/accept a potato and then that potato times out, it still checks the stamps
  - Snap closed passport to position of mouse cursor to avoid bad offset
  - Able to drag passport off interaction table, bound them to lower half of screen
  - Able to drag stamps off interaction table, bound them to lower half of screen
  - Add new missile explosion animation
  - Border runner system went off twice and cancelled the first one out (We overhauled the entire system)
  - Changed character action text from italics to colored text (We represent story character actions differently now)
  - Fix missile getting stuck bug, store last position of mouse on potato escape. If the missile is in flight when the spud escapes off the road, the missile freezes and remains until the next escape attempt.
  - Rewrite laws to make sense, bad wording (I rewrote 3 of them, not sure what this meant, it's from months ago)
  - When potato escapes, if it does so mid click (such as clicking on the speaker or a passport), the missile fires at the place you clicked on the screen. Constrain it to the Area2D for targeting potatoes on the left side of the screen, you could simply check cursor status.
  - Make the missile travel time consistent and predictable
  - Replace missile sprite
  - Update explosion
  - Expand area for perfect hit chance on border runner system
  - Remove Italics in the story text that represented actions, Tester understood after 2-3 texts


# OFFICIALLY COMPLETED TASKS
The tasks which have be completed and pushed to Steam.
When adding to the lists, please either rephrase immediately or separate your tasks to be rephrased later for proper release.
If a label is marked with *INTERNAL USE* then do *NOT* include it in the official release post to Steam.

## Steam Minor Update 1.0.1: General bug fixes - ALREADY RELEASED
  - Can't see the mouse cursor > Attribute: https://steamcommunity.com/app/3291880/discussions/0/4637115050041082833/
  - Updated font for dialogue
  - Changed character actions from italic to colored text
  - Changed background color of dialogue boxes
  - Made expiration law apply as expected (if past date)
  - Added community members who helped with bug reports to credits
  - *INTERNAL USE* Cleaned up old tutorial code to pave road for new system
  - *INTERNAL USE* Updated alert system in endlessGame and BorderRunnerSystem
  - Reduced chance of Spud running the border from 30% to 15%
  - You can no longer see the Spud when it enters the office from the right
  - Rounded edges of UI elements
  - Passport will now always come out of the slot
  - Fixed a few issues with z-ordering on textures
  - Centered alert text
  - Fixed alert timer not triggering
  - No longer subtracts points if the player does not have points
  - Fixed strike additions when Spuds run the border
  - Fixed removal of strike when you successfully murder a potato with an air-to-surface missile
  - Fixed checking for strike total to send player to game over
  - *INTERNAL USE* Fixed passport closing after timed_out() called 
  - Fixed score update after approving Spuds for entry
  - Reduced approval score from 1,000 points to 250 points
  - Moved lowest path for rejected Spud higher to avoid z-order issues
  - Fixed wrong formatting on a few alert pop-ups 
  - Expired passports now properly apply rejection logic and give alerts to the player on processing.
  - Increased missile speed by 100 (500 -> 600)
  - Changed minimum speed of potato gibs to allow for more even gib distribution

## Steam Release 1.0.0: Demo release - ALREADY RELEASED
  - Custom cursor for hover, click, grab, drag
  - The potato does not leave the customs office when the time runs out, set x/y
  - Update "You made the right choice officer" and implement the green number score system instead
  - Approval message is the wrong format, should be large green text
  - Reduce time before start of queue
  - Laws are not showing up in the guide book
  - Laws are not displaying on first potato
  - Hook up restart / main menu buttons from summary menu
  - The potatoes generate new images too early, when added to queue instead of when called into customs office
  - Cursor disappears after stamping
  - Remove invalid/inconsistent rules (remove expiration related rules and just properly process expiration)
  - Enable pause menu
  - Remove camera shake from options
  - Remove Anti-aliasing from options
  - Remove reset game data from options
  - Windowed mode breaks resolution and causes you to see outside viewport
  - Shadows when the player begins to drag the item, they can click with no reaction
  - Cursor which changes on interaction hover 
  - Remove potato types from mugshots and passports and replace with procedural character generator
  - Remove potato types from mugshots and passports and replace with procedural character generator
  - Update missile smoke system
  - Ability to kill potato after it is accepted if there is a runner, penalty of 500 points
  - If you do not kill a potato while it is running the border it repeats
  - Potatoes which run the border after being denied entry don't trigger BorderRunnerSystem
  - Add 10 paths for accepted potatoes
  - Add 10 paths for runner potatoes
  - Add 10 paths for rejected potatoes
  - Randomize path that the runners traverse
  - Make sure missile leaves a crater
  - Fix text color, should be white with black outline
  - Integrate bgm handler, sfx handler
  - Show the appropriate leaderboard out of 3 Leaderboards based on the difficulty_level global
  - Steam.uploadLeaderboardScore( score, keep_best, details, handle ) 
  - Use Steam name and avatar on the leaderboard use Steam.AVATAR_SMALL for the leaderboard
  - Make difficulty a global var
  - Add 8 different potato gibs that explode from a hit potato, with more exploding from a perfectly hit potato
  - Potato persons flip upside down when called into the office
  - Stamp doesn't match the rest of the pixel feel, different resolution
  - Picking up stamp hides cursor
  - Cut items off when they leave interaction table
  - Splash-screen text 
  - Collision for the draggables to stay in the lower half of screen
  - Fix stamp animation
  - If you spam stamps then multiple show up
  - Overlay of potato customs officer talking
  - Make full-screen appear in the main game instead of just the main menu
  - Make an options menu
  - More papers to shuffle around
  - Discuss new font
  - Move tutorial to the front of the document
  - Move 4th page of instructions to page 1
  - Update pause menu
  - Settings menu with graphics, audio, accessibility, rebinds
  - Potato persons are above the customs office when called into the office
  - Rephrase all laws to be more clearly negative
  - Make intuitive stamp mechanic
  - How do we tell the new player what to do to get through first potato processing?
  - Use flashing circles and text to walk the player through processing their first document. Click by click. 
  - Transition to game win scene, "Your shift is over, you will be re-planted, you have served the potato motherland."
  - What do we tell the player when they win?
  - Transition to game lose scene, "You have unjustly denied permitted potatoes entry, you will be roasted. You have disgraced the potato motherland."
  - What do we tell the player when they lose? 
  - Add score to both the success_scene.tscn and the game_over.tscn, then end of shifts functions as a soft-end and a way to heal for high-scoring.
  - Make stamp interaction be, left click to pick up, left click to stamp, right click to drop. 
  - Make the flashing icon on the megaphone larger
  - Remove Mr. Potato from first names
  - Alert, larger and centeredHighlight on the speaker
  - Update first page of Pamphlet with instructions
  - Hit 25 points without getting 3 strikes. 
  - Add global score and shifts to extend play session
  - Transition to win game screen, outline limit "Only allow 25 permitted potatoes to enter. You will be returned to your family if successful. Otherwise you will be roasted."
  - Measure and trigger the win condition on score, similar to quit. 
  - Change score display to be out of 25. Change scene to success_scene once completed. In success_scene, move back to mainGame and pass the score back.
  - Tuberstan and Pratie Point rules, one is not evaluating properly
  - Troubleshoot Colcannon rule
  - years_until_expiry, returning impossibly high numbers
  - days_until_expiry, returning IMPOSSIBLY high numbers
  - Potato moving in after decision processing, before megaphone pressed
  - Reset score if you fail
  - Explain how to flip the pages on the document in the tutorial
  - Move tutorial to the front of the document
  - Make the flashing icon on the megaphone larger
  - Add dialogue to the megaphone
  - Make toggle audio button on main menu work
  - Add letter with brief explainer on your job as a Spudarado Border Officer
  - Switch megaphone alert to be off when the box has someone in it
  - Fullscreen button
  - Make music start on main menu instead of game
  - Audio settings
  - Bulletin card system
  - Slow down potato leaving the customs office
  - Clock on the suspect table
  - Close passport
  - Open passport
  - Music system (Main menu scene, smooth transition, game scene)
  - Fade out passport when giving potato documents back
  - Check potato sex check logic, only males is giving points on allowing female potato
  - Date system
  - when you open document
  - when you close document
  - speaker sound when click megaphone for next person to come up
  - generate_rules() has 7 entries in current_rules, this should be expanded. 
  - current_rules should have a maximum of 1-2 rules. 
  - is_potato_valid() must support multiple active rules in current_rules at once. 
  - Review rules and make sure applying properly
  - Potato expiration dates are always in the past, need a separate FUTURE facing function
  - Flip to game over and show high score when 3 strikes hit. 
  - Change spawn timer to not stop timer when hitting max
  - Add 3 strike system and warn when wrong.
  - Add working game over constraints
  - Score is added or removed based on accuracy of judgement.
  - Passports break after 2nd potato enters
  - Credits menu (Main menu scene)
  - Disclaimer menu (Main menu scene)
  - Redraw megaphone
  - Fix bug where passport re-appears after callback for departed potato
  - Add number of eyes as an attribute of personally identifiable information to the spuddy passports
  - Fix fade from/to black outline for potato mugshot
  - Fix bug with clicking speaker before first potato 
  - Create Label (DateLabel) and add to the Potato Customs Table so the player can see the current date and judge if passports are expired.
  - Scale up potato information in the passport to be more visible.
  - Re-enable Label (ScoreLabel) on Customs Table
  - Fix potato mugshot changing to the next potato in line before the current potato has been processed
  - Add random selection of background music on launch
  - Update the process_decision logic to make the potato in customs office move through the customs office and all the way to the left side of the screen after their immigration decision is made and is positive.
  - Update the process_decision logic to make the oldest potato move through the customs office get blown up with mini-nuke particle effects after their immigration decision is made and is negative.
  - Potato walks up, puts in document. 
  - Player clicks document. 
  - Document displays in evidence drawer.
  - Player drags closed document to evidence drawer. 
  - Player reviews document. 
  - Player clicks stamp drawer to bring stamps into evidence drawer. 
  - Player clicks approve or reject stamp and a stamp comes down on the passport. 
  - Passport has a transparent stamp applied, player picks up and returns to potato.
  - Potato fades out and appears to left of customs office. 
  - Potato walks off-screen to left or is destroyed mid-way.
  - Update the remove_stamp function or create a new function to Tween the Sprite2D (Potato Mugshot) to move to the left of the Sprite2D (Suspect Panel) and disappear.
  - Then use the approval_status to decide whether to add the PotatoPerson to the Path2D (ApprovePath) or the Path2D (RejectPath) based on approved or rejected status respectively and move them to the end of the path, then remove them. 
  - Initially the Sprite2D Passport is hidden until a PotatoPerson is called into the customs office, at which point the child Sprite2D (Close Passport) is animated going across the suspect panel and settling at the bottom for the player to pick up. 
  - Split out the customs office and megaphone and create sprites for them so the potatoes will appear to go inside the office
  - When the player clicks on the Sprite2D (Megaphone) on top of the customs office in mainGame.tscn, the next PotatoPerson is removed from the front of the Path2D (SpuddyQueue) and the QueueManager, and the PotatoPerson is moved along the Path2D (EnterOfficePath), then the PotatoPerson is removed and the Sprite2D (PotatoMugshot) slides onto the Sprite2D (Suspect Panel) from the right and goes from a dark black outline to the regular texture.
  - Then the Sprite2D (Close Passport) is animated going down from the Sprite2D (PotatoMugshot) and settling at the bottom of the InteractionTableBackground for the player to pick up. 
  - when dragging, set shadow for stamp to visible and invisible otherwise
  - When clicked, the book object morphs into an opened document showing the information for the potato immigrating.
  - An approval stamp and rejection stamp that you pick up with left click, drag over the document to set approve or reject status. 
  - Click the document and drag the document onto the potato to return the document.
  - main menu
  - Split out the customs office and megaphone and create sprites for them so the potatoes will appear to go inside the office
  - stamp interaction instead of buttons
  - Replace the buttons for Welcome to Taterland and No Entry with stamps that the player can pick up and use to stamp the potato person's documents, punch down stamp with right click while dragging.
  - Create NodePath2d for rejected spuddies
  - Create NodePath2d for approved spuddies
  - Create NodePath2d for border running spuddies
  - Create NodePath2d for spuddies entering office
  - Change the texture of the Sprite2D on the PotatoPerson to the appropriate type based on their potato_info.type
  - Merge the new_potato and spawn_new_potato functions and have them managed by the queueManager
  - Give more time to make decisions (30 seconds suggested by @KotBud)
  - Make a closed passport icon (128x128px)
  - Customize the passport document to be fully original
  - Create approved and rejected stamps images that fit the size of the passport document
  - Update the queue_manager to store potato information about each potato in the queue including condition, type, and name.
  - Update the potato information to include sex, country of issue, date of birth, expiration date.
  - Update rules to include potato information.
  - Split stamp into two separate objects
  - Fill in additional detail on stamp objects
  - Change the texture for Sprite2D (PotatoMugshot) to match the type of potato using these headshot paths: 
  - Add restart button to game over screen
