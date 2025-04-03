# CURRENTLY ACTIVE TASKS
These are my, BodenGameDev, tasks which I'm currently working on.
I will move the tasks to the scratch_pad completed section when the task has been completed.

# STRETCH GOALS
- Feature: Potato tooltip if hovered over in line
- Queue Interaction System: Pop-up of a portrait of potato
- Main Menu: Potatoes moving in infinite lines behind the main menu, similar to Factorio
- Main Menu: Make a tile map for the paths
- Main Menu: Graphic button function to turn defaults into pretty buttons
- Control: Alt-Enter to toggle fullscreen 
- Control: F11 to toggle fullscreen 
- Backend: Error handling if Steam is not loaded

# GRAPHICS
- Heads up text: Wrong font sizing, causing blurry text

# SHIFT SUMMARY SCREEN
- Shift Summary: If the "Continue" button does not appear, it should balance out the "Main Menu" and "Restart" buttons

# CURSOR MANAGER
- Cursor: After dragging a document the cursor returns to default even if the cursor is still hovering over a document 

# MEGAPHONE DIALOGUE SYSTEM
- Megaphone Dialogue: Rename to Bubble Dialogue System
- Bubble Dialogue: ...

# DRAG AND DROP SYSTEM
- Drag and Drop: Passport text and photo appear over the LawReceipt
- Drag and Drop: Stamps disappear on passport while being dragged
- Drag and Drop: Law receipt passes between the passport description/photo and the passport background
- Drag and Drop: If the passport hasn't been stamped and is hovered over the potato, it should not prompt the dialogue
- Drag and Drop: If the passport hasn't been stamped and is dropped on the potato, it should return to table

# QUEUE INTERACTION SYSTEM
- Queue Interaction: Potatoes slightly wiggle while idle
- Queue Interaction: Potatoes wiggle when clicked

# EMOTE SYSTEM
- Emote System: All potatoes show exclamation marks when you shoot a missile
- Emote System: If you click the same potato 3+ times they get angry and show POPPING_VEINS emote
- Emote System / Bug: Dot animation only shows one dots then stops
- Emote System / Bug: When potatoes are clicked it only displays love emotes, could be set to display HAPPY category
- Emote System: Reduce frequency of emotes occuring

# OFFICE SHUTTER SYSTEM
- Office Shutter / Bug: Fade out the foreground shadow when the potatoes leave the office
- Office Shutter / Bug: Do not fade out transparency of potato when enter or leaving office, only the foreground shadow
- Office Shutter / Bug: Update button to exclude transparent pixels for more accurate clicks
	-	Could do this by writing a function to check for transparency under the cursor while hovering over the ShutterLever node
	- Would have to manually update cursor state

# RIGHT NOW
- Office Shutter / Bug: The potato should not pass documents through if the shutter is closed
- Office Shutter / Bug: The user should not be able to pass the potato documents if the shutter is closed
	- Add a check if the shutter is closed, if so do not allow interaction
	- Add a check if the shutter comes up for the potato to pass documents 


	- Check shutter_state when I do the check in drag_and_drop_system.gd for dropping the passport on the potato