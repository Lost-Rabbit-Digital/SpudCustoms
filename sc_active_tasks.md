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

# GRAPHICS
- Graphics: Fade out the foreground shadow when the potatoes leave the office
- Graphocs: Do not fade out transparency of potato when enter or leaving office, only the foreground shadow

# QUEUE INTERACTION SYSTEM
- Queue Interaction: Potatoes move wiggle while idle
- Queue Interaction: Potatoes wiggle when clicked
- Queue Interaction: White outlight on hover of potato

# CURSOR MANAGER
- Cursor: Update while hovering over megaphone
- Cursor: Update while dragging documents
- Cursor: Update while hovering over documents
- Cursor / Bug: Offset to the right a bit

# EMOTE SYSTEM
- Emote System: All show exclamation marks when you shoot a missile
- Emote System: If you click the same potato 3+ times they get angry and show POPPING_VEINS emote
- Emote System: If you click the potato once it has a question mark
- Emote System / Bug: Dot animation only shows one dots then stops
- Emote System / Bug: When potatoes are clicked it only displays loved emotes

# MEGAPHONE DIALOGUE SYSTEM
- Megaphone: Update core to have button for mouse interactions instead of Area2D (Or alongside Area2D if you don't feel like updating other code references)

# OFFICE SHUTTER SYSTEM
- Office Shutter: Update button to exclude transparent pixels

# RIGHT NOW
- Cursor: Add mulitple hover modes
- Cursor: We need a hover for grabbable documents (Passport, Law Receipt) and a hover for interactable objects (Potatoes, Megaphone)
	- We could probably achieve this by detecting whether the mouse is clicking/hovering over a BaseButton/TextureButton or an Area2D 
	- cursor_manager.gd > _on_button_mouse_entered(): If statement checking what the mouse hovers over, hover_1 for clickables or hover_2 for draggables
