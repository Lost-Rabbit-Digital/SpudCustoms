# Scratch Pad
These are our goals, to-do tasks, and completed tasks.

## Steam Minor Update 1.0.3 - Next Update
## Tasks
### Stretch Features
  - Add tooltip with potato info when you hover over them in line
  - Add cars that drive by (where would these go? On road from bottom to top on far left of screen?)
  - Baggage inspection, grab bags and shake them with bugs and coins flying out until you get a "BAG CLEAN" and a small number of points, or contraband detected where you get points for clicking it
  - Multiplayer? 8th / 15th of November for schedule
  - Use top 3 scores for leaderboard, then show ... and show 3 scores above player and 3 scores below player (if any), with players score in middle. 
  - UV lamp represents a high-risk way to maximize points.
  - Randomly toggle the lights on and off in customs office and Border Wall like people are using the rooms
  - Make sure scores are shown above their respective action (stamping, missiles, scanning)
### Graphics
  - Add message queue system and delay between messages so they don't override each other, add GDScript to alert_label
  - Add different types of documents, entry passes, work permits, baggage, visas, marriage licenses, bribes 
  - Add an Entry ticket document and law requirement
  - Documents should have gravity on the suspect panel and should fall to the counter
  - Add dialogue emotes randomly to the potatoes
  - Physics on suspect panel and interaction table with items (Gravity, dropping, throwing)
  - Add ink flecks from stamping that fly up when you stamp
### Backend
  - Localise the game
### Gameplay
  - Change time to a shift-based time, such as 8 hours over a day
  - Make the instructions an overlay which you could close
  - Potatoes emote (Kenny emotes) while waiting in line
  - Show Missile counter on an LCD display on the desk or on UI
  - Change position so kill text flying up with the score update ("potato.first_name + potato.last_name" + "neutralized...")
  - Wave a mouse over bombs placed on the wall or upper wall in the background to defuse them for scoring, runner potatoes throw timed-bombs which stick on the top-wall
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
### Graphics  
  - Add minor random size scaling to explosions for visual variety
  - When hit with a missile, make the corpse spin up in an arc opposite the direction of the missile impact, then bounce on the ground at the same y-level as corpse started at before coming to a rest.
  - Add a growth bounce tween or shrink bounce tween to the quota and strikes labels when they change
  - Add an animated counter up for each of the increases of the score
  - Have animated counters up for each of the values in the shift summary screen
  - Make a two-stage downward tween with the stamp and then the stamp handle to emulate pressing down an internal mechanism (whole stamp descends, just the stamp handle descends, stamp handle comes back up, whole stamp comes back up)
  - When gate is lowered, have the potatoes in shadow and allow no interaction
  - if you restart on shift summary screen, it advances to the next level
  - Set a highlight shader on the closed passport if the document goes untouched for >15 seconds
  - Set a highlight shader on the speaker/start button if the booth goes empty for >15 seconds
  - Set a highlight shader on the stamps or stamp bar open if the document is open on the table for >15 seconds
  - Cause stamps to wiggle and slam in and then fade into color on shift summary
  - Center closed version of documents on the mouse position, it often appears offset
  - Fix stamping animations so that they move down from the stamp crossbar but are behind it
  - Add random y-axis variation on the position selected in the return to table function
  - Add logic to check if game paused or in dialogic before updating cursor to target cursor
  - Concrete steps should be smaller and darker than the grass footsteps
  - Law text disappearing when you pick up the opened law document
  - Only show take passport dialogue if the passport has been stamped
  - Shrink texture for missiles and impacts, sizing of pixels is off-putting
  - When shift ends, treat the last guy in office as rejected
  - Stamps go over edge of passport
  - Update cursor to show a select icon when above the approval or rejection stamp
  - Update cursor to show a select icon when above the megaphone 
  - Update cursor when hovering over the megaphone
  - Update grab logic to check for alpha of 0 and don't grab (for transparent outlines on documents)
### Gameplay
  - Allow missiles to kill approved potatoes, resulting in a Taterneva Convention violation (-250 points)
  - Now that the Runner System has support for multiple runners, include a chance to run while waiting in line for each potato instead of waiting for rejection or the global timer
  - Do not allow the user to pick up the document through the stamp bar
  - Make sure that game state is reset properly between modes and with the Global.gd and GameState.gd files both managing states
### Audio
  - Hand gripping sound to document
  - Whooshing sound when documents are dragged quickly
  - Whooosh sound when document is returned to table
  - Add whoosh to shift summary journal and leaderboard journal
  - Add small amount of random pitch variation to the document open and close sounds
  - Check if there is a Dialogic 2 end audio function, implement after each keyboard audio call through all 11 .dtl resources
  - Add pitch variation to the positive and negative score sound
### Menus
  - Add leaderboards for each level to support shift summary screen
### Backend
  - Save game and load game, especially max level reached and local highscores
  - Code: Move cursor system out of drag system
  - Megaphone Dialogue System: Implement the different categories of dialogue from the JSON file into the megaphone_clicked function code in mainGame.gd
  - Update take passport dialogue in mainGame.gd to use the new dialogue system (Same as for megaphone) 
### General Bugs
  - Strikes on endless mode do not reset after summary screen, summary > main menu > endless mode
  - Cursor does not update when hovering above megaphone
  - Cursor does not update when hovering above stamp bar button
  - Potatoes in queue don't seem to match up with potatoes that enter customs office
  - Escape key for menu stopped working after I alt tabbed a few times and completed the first "day".
  - Expiration rule is wrong, passport was expired and got strike for denying entry
  - Fix skip story bug not hiding the history button quickly
  - Fix the issue where the game continues running during story sequences
  - Make sure the endless doesn't end too early
  - Potatoes appear above table instead of under when border runner leaves map on south side
  - Potatoes continued to escape during the Shift Summary, make sure to disable QueueManager and BorderRunnerSystem in the game_over function.
  - Score might not be resetting between rounds on leaderboard. Must be reset in Continue, Restart, Main Menu calls.
  - Corpses added too high to tree, screen shake not affecting them
  - Corpses need a slightly lower z-index to show BEHIND explosions

### Completed Tasks for 1.0.2
  - Slow down the end shift sequence
  - Footsteps must be positioned at the bottom of the potato sprites
  - Submit score button is responding, but continue, main menu, and restart are not working on the shift summary screen anymore
  - Potato footsteps appearing on top of shift summary screen (two tweens were conflicting)
  - Shrink missile firing zone on the bottom, overlaps with inspection table
  - Documents appear above the stamp bar when dragged
  - Make sure stamp bar controller does NOT show on top of shift summary screen
  - Make sure survival bonus alert shows on shift summary screen
  - Make sure quota is added before shift ends (shows 7/8 often now)
  - Update ATTRIBUTION.md with MODERN DOS font
  - Update menus with new MODERN DOS font
  - Select additional background music for /music folder
  - Check for failing date rules, especially months_until_expiry()
  - Turn down the splashscreen sound on game start
  - Fix bug where summary screen restarts back into endless mode instead of story mode
  - Cannot generate female potatoes via mugshot generator
  - Add new potato type corpse art
  - Add new potato type art and re-institute potato type rules
  - Troubleshoot shutter lever disappearing
  - Add smooth animations for the shutter gate lever going up and down
  - Color match the lever to dark blue / grey tones, and improve the quality
  - Test new font in Shift Summary Screen and menus
  - Update potato rain to look more natural
  - Update color palette for Shift Summary screen and update font spacing
  - QoL: Shadow fade-in similar to Papers, Please for potatoes entering the office
  - QoL: Shadow when shutter is closed
  - See if pitch variation can be added to background music
  - Add 25 variations of main menu music and 75 variations of main game music
  - Adding in initial 4 potato races, laws, and suspect booth/world sprites for them
  - Cause potatos on shift summary screen to rotate based on their horizontal speed
