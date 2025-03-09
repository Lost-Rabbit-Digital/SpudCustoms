# Scratch Pad
These are our goals, to-do tasks, and completed tasks.

# FULL RELEASE TASKS - 2025-02-28 - 1.0.2

## Tasks
### Graphics
  [ ] - Add dialogue emotes randomly to the potatoes
  [ ] - Add different types of documents, entry passes, work permits, baggage, visas, marriage licenses, bribes 
  [ ] - Add an Entry ticket document and law requirement
  [ ] - Fix text on main menu and other scenes with background photos
  [ ] - Make sure scores are shown above their respective action (stamping, missiles, scanning)
  [ ] - Physics on suspect panel and interaction table with items (Gravity, dropping, throwing)
  [ ] - Randomly toggle the lights on and off like people are using the rooms
  [ ] - Replace missile sprite
  [ ] - Update explosion
  [x] - Add a version counter
  [x] - Change "Runner Escaped" to capitals 
  [x] - Display the score for longer, a few seconds, so the player can read it
  [x] - Fade in potatoes when they come into the customs office
  [X] - Improve art quality of stamp bar interface (basic doodling that isn't copy/paste)
### Gameplay
  [ ] - Add a Metal shutter that rolls down cinematically with segments that cascade down, dust particles as it hits bottom, a satisfying "clunk" sound effect
  [ ] - Add a missile targeting restriction region to prevent accidental missile launches when clicking UI elements
  [ ] - Add clearer feedback for game over conditions
  [ ] - Add flash arrow pointing from the left to the right indicator for megaphone
  [ ] - Add flash indicator pointing at corner of first page 
  [ ] - Add simple fade to game over summary
  [ ] - Allow 3 missiles at once
  [ ] - Allow firing missiles even when no active runner
  [ ] - Allow multiple missiles at once
  [ ] - Allow multiple simultaneous runners
  [ ] - Change position so kill text flying up with the score update
  [ ] - Conversation with potato while checking documents
  [ ] - Expand area for perfect hit chance on border runner system
  [ ] - Fix the issue where the game continues running during story sequences
  [ ] - Fix z-ordering issues on the summary screen
  [ ] - Icon showing missile Y-level, with arrow pointing where it is off-screen briefly, change color of icon if there are multiple
  [ ] - Lower delay between stamps
  [ ] - Make sure that game state is reset properly between modes and with the Global.gd and GameState.gd files both managing states
  [ ] - Make the instructions an overlay which you could close
  [ ] - Make the missile travel time consistent and predictable
  [ ] - Potatoes continued to escape during the Shift Summary.
  [ ] - Potatoes emote (Kenny emotes) while waiting in line
  [ ] - Retouch each cutscene that stands out as rough (use dedicated 16-32 color palettes, repaint in simpler forms)
  [ ] - Score might not be resetting between rounds on leaderboard. Fairly sure mine just kept going up.
  [ ] - Set a highlight shader on the closed passport if the document goes untouched for >5 seconds
  [ ] - Set a highlight shader on the speaker/start button if the booth goes empty for >5 seconds
  [ ] - Set a highlight shader on the stamps or stamp bar open if the document is open on the table for >5 seconds
  [ ] - Set default selection for main menu for keyboard control
  [ ] - Show Missile counter on an LCD display on the desk or on UI
  [ ] - Show the missile immediately on click from customs office, or from off-screen with missile icon in white circle with arrow pointing towards off-screen object
  [x] - Add ability to skip to end of Dialogic timeline with button in Upper left "Skip"
  [x] - Add day-by-day shift selection the player unlocks as they progress
  [x] - Faster velocity or more centralized location for missile
  [x] - Reduce lead time for missiles
  [x] - Simplify stamp controls explanation in Guide book
  [x] - Spud runner attempts never stops. Alt tabbed out, paused, shift summary, no matter what, the spuds escape like clockwork.
  [x] - Update guide to use just left-click interactions rather than requiring both mouse buttons
  [x] - Update text on Guide book
### Audio
  [x] - No ambience or background music playing
### Score System
  [ ] - Balance points (missiles, stamping, scanning)
### Backend
  [ ] - Save game and load game
### General Bugs
  [ ] - *INTERNAL USE* Speed up passport through slot, decrease by 0.5-1.5 seconds
  [ ] - A slider for the law book to slide in from the bottom as a note-card
  [ ] - Able to drag passport off interaction table, bound them to lower half of screen
  [ ] - Able to drag stamps off interaction table, bound them to lower half of screen
  [ ] - Add Difficulty selection UI after selecting endless mode
  [ ] - Add message queue system and delay between messages so they don't override each other, add GDScript to alert_label
  [ ] - Add new missile explosion animation
  [ ] - Add new potato type art and re-institute potato type rules
  [ ] - Border runner system went off twice and cancelled the first one out
  [ ] - Can't see the mouse cursor > Attribute: https://steamcommunity.com/app/3291880/discussions/0/4637115050041082833/
  [ ] - Change time to a shift-based time, such as 8 hours over a day
  [ ] - Changed character action text from italics to colored text
  [ ] - Check why date rules keep failing (make sure expiration date is referencing correct variable, and that it's evaluating properly, especially months_until_expiry()
  [ ] - Don't allow grab while passport is moving, toggle a is_currently_animated boolean to check when picking up
  [ ] - Don't set stamps to go invisible when quota reached in Endless mode
  [ ] - Escape key for menu stopped working after I alt tabbed a few times and completed the first "day". Not sure of cause on that one.
  [ ] - Expiration rule is wrong, passport was expired and got strike for denying entry
  [ ] - Fix missile getting stuck bug, store last position of mouse on potato escape. If the missile is in flight when the spud escapes off the road, the missile freezes and remains until the next escape attempt.
  [ ] - Halfway through instructions while we begin to explain the stamps the wording become confusing and she was lost
  [ ] - Hook up game won, level lost, and level won scenes to gameUI scene
  [ ] - If you accept a potato at the same time the timer runs out then the potato duplicates and you get both results
  [ ] - If you deny/accept a potato and then that potato times out, it still checks the stamps
  [ ] - Italics in the story text that represented actions, understood after 2-3 texts
  [ ] - Link summary screen to restart back into endless mode instead of story mode
  [ ] - Lower z-index of crater below that of the potato_person runner
  [ ] - Make sure the endless doesn't end too early
  [ ] - Make two sets of paths, one which start in the office and one which doesn't for Spud runner, only do the office start when they are already in office
  [ ] - Mouse has to be over passport to be able to stamp
  [ ] - Move shift summary to end of game, not end of shift, on quota reached restart, on strikes reached end game
  [ ] - Option to disable the timer in Story and Endless mode  > Attribute: https://steamcommunity.com/app/3291880/discussions/0/603016087419796439/
  [ ] - Possibly exit the game from the lose screen
  [ ] - Potatoes appear above table instead of under when border runner leaves map on south side
  [ ] - Randomly lose combo when doing potato border runner system
  [ ] - Resolve missing passport documents in story mode
  [ ] - Rewrite laws to make sense, bad wording
  [ ] - Rounds end too abruptly, need to tell the player why they failed
  [ ] - Snap closed passport to position of mouse cursor to avoid bad offset
  [ ] - Sometimes the potatoes don't give you a passport
  [ ] - Stamps go over edge of passport
  [ ] - There is no continuing shift, after you reach quota you hit the shift summary and end the game
  [ ] - Update ATTRIBUTION.md with MODERN DOS font
  [ ] - Update menus with new MODERN DOS font
  [ ] - Update stats on potato escape and missile kill
  [ ] - When potato escapes, if it does so mid click (such as clicking on the speaker or a passport), the missile fires at the place you clicked on the screen. Constrain it to the Area2D for targeting potatoes on the left side of the screen, you could simply check cursor status.
  [ ] - When you correctly reject a potato it does not give you the 1,000 points
  [x] - Confused with the story initially, too many characters going on, understood after a few texts
  [x] - Copy the stamp system from Papers Please
  [x] - Ended on first runner
  [x] - Faces and hair doesn't line up on potatoes
  [x] - Game begins with a Spud runner and says "Continue Shift"
  [x] - Make sure the game scene is paused while the story mode is running
  [x] - Make sure there aren't incorrect starting strike counts
  [x] - Points are not added when correctly allowing entry to potatoes
  [x] - Rockets too slow
  [x] - She took too long to realise there was a timer and immediately failed while reading instructions
### Law Bugs
  [ ] - "Change verbiage to 2 and under" on laws, currently says "(under 2 years)"
  [ ] - "Frozen potatoes require a special permit", change to not allowed because there is not special permit
  [ ] - "Reject Spuddington potatoes because of visa counterfeiting activity.", there is no visa system, reword "visa" to "document"
  [ ] - "Rotten potatoes strictly forbidden" and "all potatoes must be fresh" entry granted, said good job, gave +1 to quota and +1 to strikes
  [ ] - "Sprouted potatoes need additional verification and must be denied", change to not include verification
  [ ] - "Young potatoes (under 2 years) need guardian.", there is no guardian system, reword
### Score Bugs
  [ ] - Add a loss of 500 points on top of strike if the rejection was incorrect (Use the same code as the border runner system to check for point penalty)
  [ ] - Check if the stamp rejection was correct before triggering the border run system for the scores to be accurate
  [ ] - Fix checking stamp on rejection, the fuck does this mean old Boden? Strike check on rejection?
  [ ] - Rewrite the runner system to include chance to run while waiting in line instead of waiting for rejection
  [ ] - Score is sometimes presented as a float and sometimes as a integer. Not sure if intentional or just some minor bug from early project, but figured i would point it out.
  [ ] - Stamp rejection doesn't update score
  [ ] - Strikes on endless mode do not reset after summary screen, summary > main menu > endless mode
  [ ] - When maximum strike reached nothing happens, only checks when above maximum strikes instead of equal to
### Stretch Features
  [ ] - Add cars that drive by
  [ ] - Baggage inspection
  [ ] - Multiplayer? 8th / 15th of November for schedule
  [ ] - Shooting from the office instead of a missile?
  [ ] - Use top 3 scores for leaderboard, then show ... and show 3 scores above player and 3 scores below player (if any), with players score in middle. 
  [ ] - UV lamp represents a high-risk way to maximize points.



## Steam Minor Update 1.0.2 - WORK IN PROGRESS
### To-Do
  [ ] - Check if there is a Dialogic 2 end audio function, implement after each keyboard audio call through all 11 .dtl
  [ ] - Make the laws slide out similar to the stamps
  [ ] - Remove the date and score from the bottom of the screen
  [ ] - Change the color of the missile marker to green/red to indicate if you can fire a missile
  [ ] - Update backend for megaphone dialogue prompt in-game to allow for future translation
    [ ] - *INTERNAL USE* Change megaphone dialogue box to be text files printed on instead of hardcoded words for ease of localisation
    [ ] - *INTERNAL USE* Speak duration parameter
    [ ] - *INTERNAL USE* Have audio built into dialogue box
    [ ] - *INTERNAL USE* Have two JSON sections, "next queue" and "general sayings", different names but you get the idea
    [ ] - *INTERNAL USE* JSON to store strings instead of hard-coding into images
    [ ] - *INTERNAL USE* Just one background image for the dialogue box
  [ ] - Add Flash Indicator for Megaphone via shader
  [ ] - Add Version Counter into menus
  [ ] - Display Score for Longer Duration
  [ ] - Add logic to check if game paused or in dialogic before updating cursor to target cursor

### Currently Doing
  [ ] - Add if check to BorderRunnerSystem.gd to check if user is currently in dialogic timeline
  [ ] - Add a skip button to dialogic

### Completed Tasks for 1.0.2
  - Make Missiles Travel Faster and More Consistently
  - Change "Runner Escaped" to Capitals
  - Make the tutorial interactive instead of a text panel with the book
  - *INTERNAL USE* Cleaned up the old git branches from various updates



# COMPLETED TASKS
The tasks which have be completed and pushed to VCS.
When adding to the lists, please either rephrase or separate your tasks to be rephrased later for proper release.
If a label is marked with *INTERNAL USE* then do *NOT* include it in the official release post to Steam.

## Steam Minor Update 1.0.1: General bug fixes - ALREADY RELEASED
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
  - FullscSwitch megaphone alert to be off when the box has someone in it
  - Make music start on main menu instead of gamereen button
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
