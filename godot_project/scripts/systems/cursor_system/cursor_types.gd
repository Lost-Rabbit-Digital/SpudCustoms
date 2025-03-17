## An enumeration of all cursor types available in the system.
class_name CursorTypes
extends RefCounted

## Available cursor visual states
enum Type {
	DEFAULT,    ## Default arrow cursor
	POINTER,    ## Pointing hand for clickable UI elements
	HAND,       ## Hover hand for interactive items
	GRAB,       ## Grab cursor for draggable items
	GRABBING,   ## Grabbing cursor for when item is being dragged
	TEXT,       ## Text editing cursor
	CROSSHAIR,  ## Precision targeting cursor
	MOVE,       ## Four-directional move cursor
	RESIZE_H,   ## Horizontal resize cursor
	RESIZE_V,   ## Vertical resize cursor
	RESIZE_DIAG1, ## Diagonal resize (top-left to bottom-right)
	RESIZE_DIAG2  ## Diagonal resize (top-right to bottom-left)
}
