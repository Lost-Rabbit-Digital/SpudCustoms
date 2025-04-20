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
	"SCREEN_BORDER": 20,         
	
	# ----------------------------------------------------------------------
	# Ground-Level Detail Layers
	# ----------------------------------------------------------------------
	#"ENVIRONMENTAL_SHADOWS": 1,                # Shadows cast by game objects
	"ENVIRONMENT": 8,            # Terrain features like hills and permanent landscape
	
	# ----------------------------------------------------------------------
	# Game Object Layers
	# ----------------------------------------------------------------------
	"ITEMS": 3,                  # Collectible items and pickups
	"CORPSES": 5,                # Dead bodies that remain on ground
	"BLOOD": 6,                  # Blood splatter effects
	"GIBS": 7,                   # Character fragments after explosions
	"FOOTPRINTS": 2,             # Footprint marks left by characters
	
	# ----------------------------------------------------------------------
	# Character Layers
	# ----------------------------------------------------------------------
	"RUNNERS": 10,               # NPCs that run/move in the game
	"ENEMIES": 11,               # Enemy characters
	"PLAYER": 12,                # The player character(s)
	"WEAPONS": 13,               # Weapons held by characters
	
	# ----------------------------------------------------------------------
	# Interactive Environment Layers
	# ----------------------------------------------------------------------
	"TABLE": 15,                 # The main table surface
	"DOCUMENTS": 20,             # Papers and documents on the table
	"STAMPS": 25,                # Stamps and inking tools
	"INKWELL": 26,               # Inkwell and other similar desk tools
	
	# ----------------------------------------------------------------------
	# Visual Effect Layers
	# ----------------------------------------------------------------------
	"PARTICLE_EFFECTS": 30,      # General particle systems (dust, smoke, etc.)
	"EXPLOSIONS": 35,            # Explosion effects (always on top of gameplay elements)
	
	# ----------------------------------------------------------------------
	# User Interface Layers (high values to always appear on top)
	# ----------------------------------------------------------------------
	"LABELS": 12,         # UI panel backgrounds
	"UI_BACKGROUND": 90,         # UI panel backgrounds
	"UI_ELEMENTS": 100,          # Standard UI elements
	"UI_FOREGROUND": 110,        # UI elements that should appear in front of others
	"TOOLTIPS": 120,             # Tooltip popups
	"CURSOR": 125,               # Custom mouse cursor
	"SCREEN_BORDERS": 130,       # Border elements framing the screen
	
	# ----------------------------------------------------------------------
	# Top-Level Game Elements
	# ----------------------------------------------------------------------
	"DIALOGUE": 200,             # Dialogue boxes and text
	"NOTIFICATIONS": 210,        # Popup notifications and alerts
	"PAUSE_MENU": 250,           # Pause menu (appears above everything else)
	"TRANSITION_EFFECTS": 900,   # Scene transition effects
	"DEBUG_OVERLAY": 1000        # Debug information (highest z-index)
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
