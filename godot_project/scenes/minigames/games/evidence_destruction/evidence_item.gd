class_name EvidenceItem
extends Resource
## Data class representing an item on the desk that can be examined and disposed of.
##
## Items have three categories:
## - EVIDENCE: Must be shredded or will be found during inspection
## - SAFE: Must be stashed or shredding raises suspicion
## - AMBIGUOUS: Either choice is valid with minor consequences

enum ItemCategory {
	EVIDENCE,    ## Must destroy - incriminating material
	SAFE,        ## Must keep - normal work items
	AMBIGUOUS    ## Player choice - minor consequences either way
}

## Unique identifier for this item
@export var id: String = ""

## Display name shown when examining
@export var display_name: String = ""

## Category determining correct action
@export var category: ItemCategory = ItemCategory.AMBIGUOUS

## Path to the item's texture
@export var texture_path: String = ""

## Short description shown in examine panel
@export_multiline var description: String = ""

## Internal monologue when examining (optional, for emotional items)
@export_multiline var inner_monologue: String = ""

## Suspicion change if shredded (positive = bad)
@export var shred_suspicion: int = 0

## Suspicion change if stashed (positive = bad)
@export var stash_suspicion: int = 0

## If true, this item is found during inspection when stashed
@export var found_if_stashed: bool = false

## Dialogic variable condition for this item to appear (e.g., "pro_sasha_choice >= 2")
@export var appearance_condition: String = ""

## Dialogic variable to check (simpler single variable check)
@export var required_variable: String = ""

## Required value for the variable (for simple checks)
@export var required_value: String = ""

## Minimum value for numeric comparisons
@export var required_min_value: int = -1


## Check if this item should appear based on current story state
func should_appear() -> bool:
	# If no conditions, always appear
	if required_variable.is_empty() and appearance_condition.is_empty():
		return true

	# Check simple variable condition
	if not required_variable.is_empty():
		if not Dialogic or not Dialogic.VAR:
			return false

		var current_value = Dialogic.VAR.get_variable(required_variable)

		# Numeric comparison
		if required_min_value >= 0:
			var numeric_value: int = int(current_value) if current_value else 0
			return numeric_value >= required_min_value

		# String comparison
		if not required_value.is_empty():
			return str(current_value) == required_value

		# Just check if variable exists and is truthy
		return current_value != null and current_value != "" and current_value != "0"

	return true


## Get the correct action for this item
func get_correct_action() -> String:
	match category:
		ItemCategory.EVIDENCE:
			return "shred"
		ItemCategory.SAFE:
			return "stash"
		ItemCategory.AMBIGUOUS:
			return "either"
	return "either"


## Check if an action is correct for this item
func is_correct_action(action: String) -> bool:
	match category:
		ItemCategory.EVIDENCE:
			return action == "shred"
		ItemCategory.SAFE:
			return action == "stash"
		ItemCategory.AMBIGUOUS:
			return true  # Both are acceptable
	return true
