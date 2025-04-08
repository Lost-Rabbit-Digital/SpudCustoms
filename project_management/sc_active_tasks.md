# Spud Customs Active Tasks
These are my, BodenGameDev, tasks which I'm currently working on.
I will move the tasks to the scratch_pad completed section when the task has been completed.


## Stretch Goals
- At the beginning of your shift, see your potato character walk into the customs office
- Menu Audio: Tick sounds when adjusting volume sliders
- Environment: Cars passing by
- Office Shutter / Bug: Fade out the foreground shadow when the potatoes leave the office
- Office Shutter / Bug: Do not fade out transparency of potato when enter or leaving office, only the foreground shadow
- Emote System: If you click the same potato 3+ times they get angry and show POPPING_VEINS emote
- Emote System: Potatoes should play small sound upon emoting
- Emote System: Skew emote display chance towards angry and confused

## Audio

## Graphics
- Passport: The shadow is still on the spud for the picture, is this a bug or should it be visually enhanced? 
- Explosions appear above the inspection table
- Potato footsteps appear above the customs office
- Potato gibs appear below the screen borders

## Queue Interaction System

## Drag and Drop Manager
- Drag and Drop / Bug: Documents released appear in front of the suspect panel background

## Emote System

## Office Shutter System

## Cursor Manager
- Cursor: After dragging a document the cursor returns to default even if the cursor is still hovering over a document 
- Cursor: Update cusor to work with Maaacks menu

## Megaphone Dialogue System

## Code Loopholes (Bugs)

## Currently active tasks
- Potato in office: Should move up and down like breathing animation, simple tween
- Stamp System: Do not make random, make it linear, use notes from David

- Bubble Dialogue: Implement into the Drag and Drop system for dropping a passport onto a potato to have varied dialogue instead of the same hardcoded text
	- Replacing "GivePromptDialogue" with "BubbleDialogue" with the category "Document interaction"