extends Node
## ------------------------------------------------------------------------------
## Purpose: Centralized repository for all z-index values throughout the game
## ------------------------------------------------------------------------------
## This file defines a comprehensive z-index system for proper layering of all
## game elements. Z-index values determine which objects appear in front of
## or behind others when they occupy the same 2D space.
##
## Usage:
##   1. Autoload this script as a singleton (Project > Project Settings > AutoLoad)
##   2. Reference values using: z_index = Z_INDEX.LAYER_NAME
## ------------------------------------------------------------------------------

## The master reference for all z-index values in the game
## Values are organized in logical groups with numeric gaps between groups to
## allow for future additions without reorganizing the entire system
const Z_INDEX = {
	# ----------------------------------------------------------------------
	# Core Layers
	# ----------------------------------------------------------------------
	## Furthest back - skybox, distant mountains, etc.
	"SCREEN_BORDER": null,         
	
	# ----------------------------------------------------------------------
	# Ground-Level Detail Layers
	# ----------------------------------------------------------------------
	## Shadows cast by game objects
	"ENVIRONMENTAL_SHADOWS": null,                
	## Terrain features like hills and permanent landscape
	"ENVIRONMENT": null,
	
	# ----------------------------------------------------------------------
	# Game Object Layers
	# ----------------------------------------------------------------------
	## Missiles launcher by the player
	"MISSILES": null,
	## Dead bodies that remain on ground
	"CORPSES": null,                
	## Corpse fragments after explosions
	"GIBS": null,                   
	## Vehicles on the main road             
	"VEHICLES": null,
	
	# ----------------------------------------------------------------------
	# Character Layers
	# ----------------------------------------------------------------------
	## NPCs that walk/run in the game, also known as "runners"
	"NPC": null,              
	## The player character(s)
	"PLAYER": null,                
	
	# ----------------------------------------------------------------------
	# Interactive Environment Layers
	# ----------------------------------------------------------------------
	## The main table surface
	"INSPECTION_TABLE": null,                 
	## The suspect which moves through the office
	"SUSPECT": null,
	## The shutter which opens/closes in the office
	"OFFICE_SHUTTER": null,
	
	# ----------------------------------------------------------------------
	# Interactive Object Layers
	# ----------------------------------------------------------------------
	## Documents which are not actively interacted with
	"IDLE_DOCUMENT": null,             
	## Documents which are actively been dragged
	"DRAGGED_DOCUMENT": null,
	"STAMPS": null,                # Stamps and inking tools
	"INKWELL": null,               # Inkwell and other similar desk tools
	
	# ----------------------------------------------------------------------
	# Visual Effect Layers
	# ----------------------------------------------------------------------
	## General particle systems (dust, smoke, etc.)
	"STAMP_PARTICLES": null,      
	## Explosion effects
	"EXPLOSIONS": null,            
	## Footprints left by NPCs
	"FOOTPRINTS": null,
	
	# ----------------------------------------------------------------------
	# User Interface Layers (high values to always appear on top)
	# ----------------------------------------------------------------------
	"LABELS": null,         # UI panel backgrounds
	"UI_BACKGROUND": null,         # UI panel backgrounds
	"UI_ELEMENTS": null,          # Standard UI elements
	"UI_FOREGROUND": null,        # UI elements that should appear in front of others
	"TOOLTIPS": null,             # Tooltip popups
	"CURSOR": null,               # Custom mouse cursor
	"SCREEN_BORDERS": null,       # Border elements framing the screen
	
	# ----------------------------------------------------------------------
	# Top-Level Game Elements
	# ----------------------------------------------------------------------
	"DIALOGUE": null,             # Dialogue boxes and text
	"NOTIFICATIONS": null,        # Popup notifications and alerts
	"PAUSE_MENU": null,           # Pause menu (appears above everything else)
	"TRANSITION_EFFECTS": null,   # Scene transition effects
	"DEBUG_OVERLAY": null        # Debug information (highest z-index)
}

# ------------------------------------------------------------------------------
# Helper functions for commonly used z-index operations
# ------------------------------------------------------------------------------

## Returns the z-index value for a specified layer
func get_z_index(layer_name: String) -> int:
	if Z_INDEX.has(layer_name):
		return Z_INDEX[layer_name]
	else:
		push_error("Z_INDEX: Requested layer '" + layer_name + "' does not exist")
		return 0

## Returns a z-index value slightly above the specified layer
## Useful for making sure something appears just above another object
func above(layer_name: String, offset: int = 1) -> int:
	return get_z_index(layer_name) + offset

# Returns a z-index value slightly below the specified layer
# Useful for making sure something appears just below another object
func below(layer_name: String, offset: int = 1) -> int:
	return get_z_index(layer_name) - offset

# ------------------------------------------------------------------------------
# Debugging functions
# ------------------------------------------------------------------------------

## Prints all z-index values in a formatted way for debugging
func print_all_layers() -> void:
	print("\n=== Z-INDEX LAYERS ===")
	var keys = Z_INDEX.keys()
	keys.sort_custom(Callable(self, "_sort_by_value"))
	
	for key in keys:
		print("%4d : %s" % [Z_INDEX[key], key])
	print("=====================\n")

## Custom sort function for sorting keys by their z-index values
func _sort_by_value(a: String, b: String) -> bool:
	return Z_INDEX[a] < Z_INDEX[b]
