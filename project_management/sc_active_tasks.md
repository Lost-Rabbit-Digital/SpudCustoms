# CURRENTLY ACTIVE TASKS
These are my, BodenGameDev, tasks which I'm currently working on.
I will move the tasks to the scratch_pad completed section when the task has been completed.

# STRETCH GOALS

# GRAPHICS

# QUEUE INTERACTION SYSTEM

# CURSOR MANAGER
- Cursor: After dragging a document the cursor returns to default even if the cursor is still hovering over a document 

# MEGAPHONE DIALOGUE SYSTEM
- Megaphone Dialogue: Rename to Bubble Dialogue System
- Bubble Dialogue: Implement into the Drag and Drop system for dropping a passport onto a potato

# DRAG AND DROP SYSTEM
- Drag and Drop: Passport text and photo appear over the LawReceipt
- Drag and Drop: Stamps disappear on passport while being dragged
- Drag and Drop: Law receipt passes between the passport description/photo and the passport background
- Drag and Drop: If the passport hasn't been stamped and is hovered over the potato, it should not prompt the dialogue
- Drag and Drop: If the passport hasn't been stamped and is dropped on the potato, it should return to table

# EMOTE SYSTEM
- Emote System: If you click the same potato 3+ times they get angry and show POPPING_VEINS emote
- Emote System / Bug: Dot animation only shows one dots then stops
	- Move animation to 1.0.3
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

- Check shutter_state when I do the check in drag_and_drop_system.gd for dropping the passport on the potato