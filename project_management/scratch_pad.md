# Scratch Pad
These are our goals, to-do tasks, and completed tasks.

DEMO RELEASE GOALS: 2024-11-22
  Urgent Tasks: Needed for Steam approval
    [ ] - Potato stamp approval doesn't update score
    [ ] - Don't set stamps to go invisible when quota reached in Endless mode
    [ ] - Hook up game won, level lost, and level won scenes to gameUI scene
    [ ] - There is no continuing shift, after you reach quota you hit the shift summary and end the game
    [ ] - Move shift summary to end of game, not end of shift, on quota reached restart, on strikes reached end game
    [ ] - Sometimes the potatoes don't give you a passport
    [ ] - Don't allow grab while passport is moving, toggle a is_currently_animated boolean to check when picking up
    [ ] - Passport comes from random x/y, instead of down the slot
  Tasks:
    Graphics:
      [ ] - Change "Runner Escaped" to capitals 
      [ ] - "You have caused unnecessary suffering" is in the wrong format, should be large red text
      [ ] - Potatoes appear above table instead of under when border runner leaves map on south side
      [ ] - Missile gets stuck if border runner leaves while airborne, keep track of last spot and send missile there
      [ ] - Replace missile sprite
      [ ] - Make sure scores are shown above their respective action (stamping, missiles, scanning)
      [ ] - If the player has 0 points do not say "-500 points" when a potato escapes
      [ ] - Display the score for longer, a few seconds, so the player can read it
      [ ] - Rewrite laws to make sense, bad wording
      [ ] - Faces and hair doesn't line up on potatoes
      [ ] - You can see the potato come in from the right
      [ ] - Fade in potatoes when they come into the customs office
    Audio:
      [ ] - No ambience or background music playing
    Scoring:
      [ ] - Randomly lose combo when doing potato border runner system
      [ ] - A strike is not removed when you successfully murder a potato with an air-to-surface missile
      [ ] - When a potato escapes by running a strike is not added
      [ ] - If the player has 0 points do not remove 500 points when a potato escapes
      [ ] - Points are not added when correctly allowing entry to potatoes
      [ ] - When maximum strike reached nothing happens, only checks when above maximum strikes instead of equal to
      [ ] - Went from 3 strikes to 7, border runners may add but not update strikes
      [ ] - Expiration rule is wrong, passport was expired and got strike for denying entry
      [ ] - Update stats on potato escape and missile kill
      [ ] - Check and see whether strikes are actually removing
      [ ] - Balance points (missiles, stamping, scanning)
    Interaction:
      [ ] - Lower delay between stamps
      [ ] - Border runner system went off twice and cancelled the first one out
      [ ] - Set default selection for main menu for keyboard control
      [ ] - Expand area for perfect hit chance on border runner system
      [ ] - Bound missile mini-game to area2d, check update_cursor for area2d mouse checking code
      [ ] - Mouse has to be over passport to be able to stamp
      [ ] - Able to drag stamps off interaction table, bound them to lower half of screen
      [ ] - Able to drag passport off interaction table, bound them to lower half of screen
      [ ] - Snap closed passport to position of mouse cursor to avoid bad offset
  
FULL RELEASE GOALS: 2024-11-27
## To Be Completed
These are tasks which must be completed before the submission to Steam deadline, November 24th.

### Bugs
[ ] - Check why date rules keep failing (make sure expiration date is referencing correct variable, and that it's evaluating properly, especially months_until_expiry()
[ ] - Change position so kill text flying up with the score update
[ ] - Fix missile getting stuck bug, store last position of mouse on potato escape 
[ ] - Update menus with new MODERN DOS font
[ ] - Update ATTRIBUTION.md with MODERN DOS font
[ ] - Lower z-index of crater below that of the potato_person runner
[ ] - Don't allow the player to move the passport while the animation is playing for it to pass into the customs table
[ ] - Stamps go over edge of passport

### Urgent
[ ] - Difficulty selection UI after selecting endless mode
[ ] - Add dialogue emotes randomly to the potatoes
[ ] - Change megaphone dialogue box to be text files printed on instead of hardcoded words for ease of localisation
[ ] - Explain how to flip the pages on the document in the tutorial
[ ] - Add flash arrow pointing from the left to the right indicator for megaphone
[ ] - Add flash indicator pointing at corner of first page 
[ ] - How to give visual feedback of controls to the player? 
[ ] - Fix the pixel resolution of the text
[ ] - "Change verbiage to 2 and under"
[ ] - Make the instructions an overlay which you could close
[ ] - Custom cursor for hover, click, grab, drag
[ ] - Save game and load game
[ ] - Make it clearer that the potato is running the border, add agency
[ ] - UV Lamp mini-game



## General Tasks
These are more general tasks which would add a layer of quality to the game if completed before submission deadline. 

### Quality of life (QoL)
[ ] - Save in a global if the player has finished the tutorial so every shift doesn't start the same interaction
[ ] - Physics on suspect panel and interaction table with items (Gravity, dropping, throwing)

## Stretch Goals
These are various goals which are out of scope for the current roadmap, but if possible would add more to the game.

### Features
[ ] - Baggage inspection
[ ] - Multiplayer? 8th / 15th of November for schedule
[ ] - Use top 3 scores for leaderboard, then show ... and show 3 scores above player and 3 scores below player (if any), with players score in middle. 
[ ] - UV lamp represents a high-risk way to maximize points.

### Graphics
[ ] - Entry ticket
[ ] - Different documents, entry passes, work permits, baggage, visas, marriage licenses, bribes, 
[ ] - Randomly toggle the lights on and off like people are using the rooms

### Interaction
[ ] - Conversation with potato while checking documents
[ ] - Potatoes emote (Kenny emotes) while waiting in line


# Completed tasks list
The tasks which have be completed and pushed to VCS.

[o] - The potato does not leave the customs office when the time runs out, set x/y
[o] - Update "You made the right choice officer" and implement the green number score system instead
[o] - Approval message is the wrong format, should be large green text
[o] - Reduce time before start of queue
[o] - Laws are not showing up in the guide book
[o] - Laws are not displaying on first potato
[o] - Hook up restart / main menu buttons from summary menu
[o] - The potatoes generate new images too early, when added to queue instead of when called into customs office
[o] - Cursor disappears after stamping
[o] - Remove invalid/inconsistent rules (remove expiration related rules and just properly process expiration)
[o] - Enable pause menu
[o] - Remove camera shake from options
[o] - Remove Anti-aliasing from options
[o] - Remove reset game data from options
[o] - Windowed mode breaks resolution and causes you to see outside viewport
[o] - Shadows when the player begins to drag the item, they can click with no reaction
[o] - Cursor which changes on interaction hover 
[o] - Remove potato types from mugshots and passports and replace with procedural character generator
[o] - Remove potato types from mugshots and passports and replace with procedural character generator
[o] - Update missile smoke system
[o] - Ability to kill potato after it is accepted if there is a runner, penalty of 500 points
[o] - If you do not kill a potato while it is running the border it repeats
[o] - Potatoes which run the border after being denied entry don't trigger BorderRunnerSystem
[o] - Add 10 paths for accepted potatoes
[o] - Add 10 paths for runner potatoes
[o] - Add 10 paths for rejected potatoes
[o] - Randomize path that the runners traverse
[o] - Make sure missile leaves a crater
[o] - Fix text color, should be white with black outline
[o] - Integrate bgm handler, sfx handler
[o] - Show the appropriate leaderboard out of 3 Leaderboards based on the difficulty_level global
[o] - Steam.uploadLeaderboardScore( score, keep_best, details, handle ) 
[o] - Use Steam name and avatar on the leaderboard use Steam.AVATAR_SMALL for the leaderboard
[o] - Make difficulty a global var
[o] - Add 8 different potato gibs that explode from a hit potato, with more exploding from a perfectly hit potato
[o] - Potato persons flip upside down when called into the office
[o] - Stamp doesn't match the rest of the pixel feel, different resolution
[o] - Picking up stamp hides cursor
[o] - Cut items off when they leave interaction table
[o] - Splash-screen text 
[o] - Collision for the draggables to stay in the lower half of screen
[o] - Fix stamp animation
[o] - If you spam stamps then multiple show up
[o] - Overlay of potato customs officer talking
[o] - Make full-screen appear in the main game instead of just the main menu
[o] - Make an options menu
[o] - More papers to shuffle around
[o] - Discuss new font
[o] - Move tutorial to the front of the document
[o] - Move 4th page of instructions to page 1
[o] - Update pause menu
[o] - Settings menu with graphics, audio, accessibility, rebinds
[o] - Potato persons are above the customs office when called into the office
[o] - Rephrase all laws to be more clearly negative
[o] - Make intuitive stamp mechanic
[o] - How do we tell the new player what to do to get through first potato processing?
[o] - Use flashing circles and text to walk the player through processing their first document. Click by click. 
[o] - Transition to game win scene, "Your shift is over, you will be re-planted, you have served the potato motherland."
[o] - What do we tell the player when they win?
[o] - Transition to game lose scene, "You have unjustly denied permitted potatoes entry, you will be roasted. You have disgraced the potato motherland."
[o] - What do we tell the player when they lose? 
[o] - Add score to both the success_scene.tscn and the game_over.tscn, then end of shifts functions as a soft-end and a way to heal for high-scoring.
[o] - Make stamp interaction be, left click to pick up, left click to stamp, right click to drop. 
[o] - Make the flashing icon on the megaphone larger
[o] - Remove Mr. Potato from first names
[o] - Alert, larger and centeredHighlight on the speaker
[o] - Update first page of Pamphlet with instructions
[o] - Hit 25 points without getting 3 strikes. 
[o] - Add global score and shifts to extend play session
[o] - Transition to win game screen, outline limit "Only allow 25 permitted potatoes to enter. You will be returned to your family if successful. Otherwise you will be roasted."
[o] - Measure and trigger the win condition on score, similar to quit. 
[o] - Change score display to be out of 25. Change scene to success_scene once completed. In success_scene, move back to mainGame and pass the score back.
[o] - Tuberstan and Pratie Point rules, one is not evaluating properly
[o] - Troubleshoot Colcannon rule
[o] - years_until_expiry, returning impossibly high numbers
[o] - days_until_expiry, returning IMPOSSIBLY high numbers
[o] - Potato moving in after decision processing, before megaphone pressed
[o] - Reset score if you fail
[o] - Explain how to flip the pages on the document in the tutorial
[o] - Move tutorial to the front of the document
[o] - Make the flashing icon on the megaphone larger
[o] - Add dialogue to the megaphone
[o] - Make toggle audio button on main menu work
[o] - Add letter with brief explainer on your job as a Spudarado Border Officer
[o] - FullscSwitch megaphone alert to be off when the box has someone in it
[o] - Make music start on main menu instead of gamereen button
[o] - Audio settings
[o] - Bulletin card system
[o] - Slow down potato leaving the customs office
[o] - Clock on the suspect table
[o] - Close passport
[o] - Open passport
[o] - Music system (Main menu scene, smooth transition, game scene)
[o] - Fade out passport when giving potato documents back
[o] - Check potato sex check logic, only males is giving points on allowing female potato
[o] - Date system
[o] - when you open document
[o] - when you close document
[o] - speaker sound when click megaphone for next person to come up
[o] - generate_rules() has 7 entries in current_rules, this should be expanded. 
[o] - current_rules should have a maximum of 1-2 rules. 
[o] - is_potato_valid() must support multiple active rules in current_rules at once. 
[o] - Review rules and make sure applying properly
[o] - Potato expiration dates are always in the past, need a separate FUTURE facing function
[o] - Flip to game over and show high score when 3 strikes hit. 
[o] - Change spawn timer to not stop timer when hitting max
[o] - Add 3 strike system and warn when wrong.
[o] - Add working game over constraints
[o] - Score is added or removed based on accuracy of judgement.
[o] - Passports break after 2nd potato enters
[o] - Credits menu (Main menu scene)
[o] - Disclaimer menu (Main menu scene)
[o] - Redraw megaphone
[o] - Fix bug where passport re-appears after callback for departed potato
[o] - Add number of eyes as an attribute of personally identifiable information to the spuddy passports
[o] - Fix fade from/to black outline for potato mugshot
[o] - Fix bug with clicking speaker before first potato 
[o] - Create Label (DateLabel) and add to the Potato Customs Table so the player can see the current date and judge if passports are expired.
[o] - Scale up potato information in the passport to be more visible.
[o] - Re-enable Label (ScoreLabel) on Customs Table
[o] - Fix potato mugshot changing to the next potato in line before the current potato has been processed
[o] - Add random selection of background music on launch
[o] - Update the process_decision logic to make the potato in customs office move through the customs office and all the way to the left side of the screen after their immigration decision is made and is positive.
[o] - Update the process_decision logic to make the oldest potato move through the customs office get blown up with mini-nuke particle effects after their immigration decision is made and is negative.
[o] - Potato walks up, puts in document. 
[o] - Player clicks document. 
[o] - Document displays in evidence drawer.
[o] - Player drags closed document to evidence drawer. 
[o] - Player reviews document. 
[o] - Player clicks stamp drawer to bring stamps into evidence drawer. 
[o] - Player clicks approve or reject stamp and a stamp comes down on the passport. 
[o] - Passport has a transparent stamp applied, player picks up and returns to potato.
[o] - Potato fades out and appears to left of customs office. 
[o] - Potato walks off-screen to left or is destroyed mid-way.
[o] - Update the remove_stamp function or create a new function to Tween the Sprite2D (Potato Mugshot) to move to the left of the Sprite2D (Suspect Panel) and disappear.
[o] - Then use the approval_status to decide whether to add the PotatoPerson to the Path2D (ApprovePath) or the Path2D (RejectPath) based on approved or rejected status respectively and move them to the end of the path, then remove them. 
[o] - Initially the Sprite2D Passport is hidden until a PotatoPerson is called into the customs office, at which point the child Sprite2D (Close Passport) is animated going across the suspect panel and settling at the bottom for the player to pick up. 
[o] - Split out the customs office and megaphone and create sprites for them so the potatoes will appear to go inside the office
[o] - When the player clicks on the Sprite2D (Megaphone) on top of the customs office in mainGame.tscn, the next PotatoPerson is removed from the front of the Path2D (SpuddyQueue) and the QueueManager, and the PotatoPerson is moved along the Path2D (EnterOfficePath), then the PotatoPerson is removed and the Sprite2D (PotatoMugshot) slides onto the Sprite2D (Suspect Panel) from the right and goes from a dark black outline to the regular texture.
[o] - Then the Sprite2D (Close Passport) is animated going down from the Sprite2D (PotatoMugshot) and settling at the bottom of the InteractionTableBackground for the player to pick up. 
[o] - when dragging, set shadow for stamp to visible and invisible otherwise
[o] - When clicked, the book object morphs into an opened document showing the information for the potato immigrating.
[o] - An approval stamp and rejection stamp that you pick up with left click, drag over the document to set approve or reject status. 
[o] - Click the document and drag the document onto the potato to return the document.
[o] - main menu
[o] - Split out the customs office and megaphone and create sprites for them so the potatoes will appear to go inside the office
[o] - stamp interaction instead of buttons
[o] - Replace the buttons for Welcome to Taterland and No Entry with stamps that the player can pick up and use to stamp the potato person's documents, punch down stamp with right click while dragging.
[o] - Create NodePath2d for rejected spuddies
[o] - Create NodePath2d for approved spuddies
[o] - Create NodePath2d for border running spuddies
[o] - Create NodePath2d for spuddies entering office
[o] - Change the texture of the Sprite2D on the PotatoPerson to the appropriate type based on their potato_info.type
[o] - Merge the new_potato and spawn_new_potato functions and have them managed by the queueManager
[o] - Give more time to make decisions (30 seconds suggested by @KotBud)
[o] - Make a closed passport icon (128x128px)
[o] - Customize the passport document to be fully original
[o] - Create approved and rejected stamps images that fit the size of the passport document
[o] - Update the queue_manager to store potato information about each potato in the queue including condition, type, and name.
[o] - Update the potato information to include sex, country of issue, date of birth, expiration date.
[o] - Update rules to include potato information.
[o] - Split stamp into two separate objects
[o] - Fill in additional detail on stamp objects
[o] - Change the texture for Sprite2D (PotatoMugshot) to match the type of potato using these headshot paths: 
[o] - Add restart button to game over screen