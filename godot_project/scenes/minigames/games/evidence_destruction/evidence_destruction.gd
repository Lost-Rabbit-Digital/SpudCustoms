class_name EvidenceDestructionMinigame
extends MinigameContainer
## Evidence Destruction Minigame - Clear your desk before the security inspection!
##
## Replaces standard gameplay in Shift 9. Player must examine items on their desk
## and decide whether to shred (destroy evidence) or stash (keep safe items).
##
## Wrong choices raise suspicion. Evidence left on desk or stashed will be found.
## Timer counts down to inspection - must clear desk before time runs out.

## Signals for UI updates
signal item_examined(item: EvidenceItem)
signal item_disposed(item: EvidenceItem, action: String)
signal suspicion_changed(new_value: float)

## Configuration
@export var items_to_show: int = 12
@export var suspicion_threshold: float = 100.0
@export var base_time_limit: float = 180.0  # 3 minutes

## Item grid layout
@export var grid_columns: int = 6
@export var grid_rows: int = 2

## All possible items (loaded from item definitions)
var _all_items: Array[EvidenceItem] = []

## Items currently on the desk
var _desk_items: Array[EvidenceItem] = []

## Items that have been processed
var _shredded_items: Array[EvidenceItem] = []
var _stashed_items: Array[EvidenceItem] = []

## Current game state
var _suspicion: float = 0.0
var _currently_examining: EvidenceItem = null
var _items_remaining: int = 0

## Node references (set in _ready or via scene)
var _desk_grid: GridContainer
var _examine_panel: Control
var _examine_image: TextureRect
var _examine_name: Label
var _examine_description: RichTextLabel
var _examine_monologue: RichTextLabel
var _shred_button: Button
var _stash_button: Button
var _suspicion_bar: ProgressBar
var _suspicion_label: Label
var _items_remaining_label: Label
var _shredder_area: Control
var _drawer_area: Control

## Item button scenes/references
var _item_buttons: Array[Button] = []

## Textures
var _card_back_texture: Texture2D
var _item_textures: Dictionary = {}


func _ready() -> void:
	super._ready()
	minigame_type = "evidence_destruction"
	time_limit = base_time_limit
	skippable = true  # Allow skip for accessibility
	reward_multiplier = 1.0  # No bonus multiplier - this is narrative

	# Load item definitions
	_load_item_definitions()

	# Load card back texture
	_card_back_texture = load("res://assets/minigames/evidence_destruction/ui/item_card_back.svg")


func _on_minigame_start(config: Dictionary) -> void:
	# Apply config overrides
	if config.has("time_limit"):
		time_limit = config.time_limit
		_time_remaining = time_limit

	if config.has("items_to_show"):
		items_to_show = config.items_to_show

	# Setup the game
	_setup_ui_references()
	_reset_game_state()
	_select_items_for_desk()
	_populate_desk_grid()
	_update_ui()

	# Update title and instructions
	if title_label:
		title_label.text = "SECURITY INSPECTION IMMINENT"
	if instruction_label:
		instruction_label.text = "Clear your desk! Shred evidence, stash work items."


func _setup_ui_references() -> void:
	# Get references to UI nodes in the subviewport
	if not subviewport:
		push_error("[EvidenceDestruction] No subviewport found!")
		return

	var game_root: Control = subviewport.get_node_or_null("GameRoot")
	if not game_root:
		push_error("[EvidenceDestruction] No GameRoot found in subviewport!")
		return

	_desk_grid = game_root.get_node_or_null("DeskArea/ItemGrid")
	_examine_panel = game_root.get_node_or_null("ExaminePanel")
	_suspicion_bar = game_root.get_node_or_null("HUD/SuspicionBar")
	_suspicion_label = game_root.get_node_or_null("HUD/SuspicionLabel")
	_items_remaining_label = game_root.get_node_or_null("HUD/ItemsRemainingLabel")
	_shredder_area = game_root.get_node_or_null("DeskArea/Shredder")
	_drawer_area = game_root.get_node_or_null("DeskArea/Drawer")

	if _examine_panel:
		_examine_image = _examine_panel.get_node_or_null("ItemImage")
		_examine_name = _examine_panel.get_node_or_null("ItemName")
		_examine_description = _examine_panel.get_node_or_null("ItemDescription")
		_examine_monologue = _examine_panel.get_node_or_null("InnerMonologue")
		_shred_button = _examine_panel.get_node_or_null("ShredButton")
		_stash_button = _examine_panel.get_node_or_null("StashButton")

		# Connect buttons
		if _shred_button:
			_shred_button.pressed.connect(_on_shred_pressed)
		if _stash_button:
			_stash_button.pressed.connect(_on_stash_pressed)

		# Hide examine panel initially
		_examine_panel.visible = false


func _reset_game_state() -> void:
	_suspicion = 0.0
	_currently_examining = null
	_desk_items.clear()
	_shredded_items.clear()
	_stashed_items.clear()
	_item_buttons.clear()
	_items_remaining = 0


func _load_item_definitions() -> void:
	_all_items.clear()

	# === EVIDENCE ITEMS (Must Shred) ===

	var pamphlet := EvidenceItem.new()
	pamphlet.id = "resistance_pamphlet"
	pamphlet.display_name = "Resistance Pamphlet"
	pamphlet.category = EvidenceItem.ItemCategory.EVIDENCE
	pamphlet.texture_path = "res://assets/minigames/evidence_destruction/items/evidence/resistance_pamphlet.svg"
	pamphlet.description = "A crudely printed underground flyer. \"THE TRUTH ABOUT ROOT RESERVE\" - the headline screams in smudged ink."
	pamphlet.inner_monologue = "They're right about everything. But if they find this..."
	pamphlet.found_if_stashed = true
	_all_items.append(pamphlet)

	var sasha_letter := EvidenceItem.new()
	sasha_letter.id = "sasha_letter"
	sasha_letter.display_name = "Sasha's Letter"
	sasha_letter.category = EvidenceItem.ItemCategory.EVIDENCE
	sasha_letter.texture_path = "res://assets/minigames/evidence_destruction/items/evidence/sasha_letter.svg"
	sasha_letter.description = "A handwritten letter on cream paper. Her handwriting. Meeting times, locations, and a small heart near the signature."
	sasha_letter.inner_monologue = "Her handwriting. The way she dotted her i's. You can almost smell her perfume on the paper."
	sasha_letter.found_if_stashed = true
	sasha_letter.required_variable = "pro_sasha_choice"
	sasha_letter.required_min_value = 2
	_all_items.append(sasha_letter)

	var coded_schedule := EvidenceItem.new()
	coded_schedule.id = "coded_schedule"
	coded_schedule.display_name = "Annotated Schedule"
	coded_schedule.category = EvidenceItem.ItemCategory.EVIDENCE
	coded_schedule.texture_path = "res://assets/minigames/evidence_destruction/items/evidence/coded_schedule.svg"
	coded_schedule.description = "Your shift schedule, but the margins are filled with coded annotations. Circled times. Small symbols. Anyone looking would know this isn't normal."
	coded_schedule.found_if_stashed = true
	_all_items.append(coded_schedule)

	var fake_id := EvidenceItem.new()
	fake_id.id = "fake_id"
	fake_id.display_name = "Forged Documents"
	fake_id.category = EvidenceItem.ItemCategory.EVIDENCE
	fake_id.texture_path = "res://assets/minigames/evidence_destruction/items/evidence/fake_id.svg"
	fake_id.description = "The identity papers from that operative at the checkpoint. The stamps are good, but not good enough to survive close inspection."
	fake_id.inner_monologue = "You helped them through. This is the proof."
	fake_id.found_if_stashed = true
	fake_id.required_variable = "critical_choice"
	fake_id.required_value = "help"
	_all_items.append(fake_id)

	var smuggled_photo := EvidenceItem.new()
	smuggled_photo.id = "smuggled_photo"
	smuggled_photo.display_name = "Factory Photograph"
	smuggled_photo.category = EvidenceItem.ItemCategory.EVIDENCE
	smuggled_photo.texture_path = "res://assets/minigames/evidence_destruction/items/evidence/smuggled_photo.svg"
	smuggled_photo.description = "A blurry polaroid of the Root Reserve processing floor. Conveyor belts. Industrial machinery. \"DO NOT DISTRIBUTE\" stamped across it."
	smuggled_photo.inner_monologue = "They need to see this. Everyone needs to see this. But not today."
	smuggled_photo.found_if_stashed = true
	smuggled_photo.required_variable = "pro_sasha_choice"
	smuggled_photo.required_min_value = 3
	_all_items.append(smuggled_photo)

	var murphy_note := EvidenceItem.new()
	murphy_note.id = "murphy_note"
	murphy_note.display_name = "Murphy's Warning"
	murphy_note.category = EvidenceItem.ItemCategory.EVIDENCE
	murphy_note.texture_path = "res://assets/minigames/evidence_destruction/items/evidence/murphy_note.svg"
	murphy_note.description = "A torn piece of paper with Murphy's scratchy handwriting: \"They're watching. Burn after reading. -M\""
	murphy_note.inner_monologue = "Murphy's chicken-scratch. He slipped this to you three days ago. Before everything went wrong."
	murphy_note.found_if_stashed = true
	murphy_note.required_variable = "murphy_alliance"
	murphy_note.required_value = "ally"
	_all_items.append(murphy_note)

	var contact_list := EvidenceItem.new()
	contact_list.id = "contact_list"
	contact_list.display_name = "Coded Contact List"
	contact_list.category = EvidenceItem.ItemCategory.EVIDENCE
	contact_list.texture_path = "res://assets/minigames/evidence_destruction/items/evidence/contact_list.svg"
	contact_list.description = "A notebook page with a list of names. Some crossed out. Symbols next to each. The code is obvious to anyone who knows what to look for."
	contact_list.found_if_stashed = true
	contact_list.required_variable = "pro_sasha_choice"
	contact_list.required_min_value = 4
	_all_items.append(contact_list)

	# === SAFE ITEMS (Must Stash) ===

	var official_stamp := EvidenceItem.new()
	official_stamp.id = "official_stamp"
	official_stamp.display_name = "Official Stamp"
	official_stamp.category = EvidenceItem.ItemCategory.SAFE
	official_stamp.texture_path = "res://assets/minigames/evidence_destruction/items/safe/official_stamp.svg"
	official_stamp.description = "Your customs approval stamp. Worn smooth from thousands of documents. You need this for work."
	official_stamp.shred_suspicion = 20
	_all_items.append(official_stamp)

	var shift_schedule := EvidenceItem.new()
	shift_schedule.id = "shift_schedule"
	shift_schedule.display_name = "Shift Schedule"
	shift_schedule.category = EvidenceItem.ItemCategory.SAFE
	shift_schedule.texture_path = "res://assets/minigames/evidence_destruction/items/safe/shift_schedule.svg"
	shift_schedule.description = "The official weekly rotation schedule. Completely normal. A small coffee stain in the corner."
	shift_schedule.shred_suspicion = 10
	_all_items.append(shift_schedule)

	var regulations := EvidenceItem.new()
	regulations.id = "regulations_manual"
	regulations.display_name = "Regulations Manual"
	regulations.category = EvidenceItem.ItemCategory.SAFE
	regulations.texture_path = "res://assets/minigames/evidence_destruction/items/safe/regulations_manual.svg"
	regulations.description = "Immigration Procedures Volume III. Dog-eared and well-worn. Every officer has one."
	regulations.shred_suspicion = 15
	_all_items.append(regulations)

	var loyalty_cert := EvidenceItem.new()
	loyalty_cert.id = "loyalty_certificate"
	loyalty_cert.display_name = "Loyalty Certificate"
	loyalty_cert.category = EvidenceItem.ItemCategory.SAFE
	loyalty_cert.texture_path = "res://assets/minigames/evidence_destruction/items/safe/loyalty_certificate.svg"
	loyalty_cert.description = "Your Oath of Service certificate. Signed and dated. The government seal gleams."
	loyalty_cert.inner_monologue = "You signed this. You believed it once."
	loyalty_cert.shred_suspicion = 25
	_all_items.append(loyalty_cert)

	var commendation := EvidenceItem.new()
	commendation.id = "commendation_letter"
	commendation.display_name = "Commendation Letter"
	commendation.category = EvidenceItem.ItemCategory.SAFE
	commendation.texture_path = "res://assets/minigames/evidence_destruction/items/safe/commendation_letter.svg"
	commendation.description = "\"Outstanding Service\" - signed by Supervisor Russet herself. Gold seal embossed at the bottom."
	commendation.shred_suspicion = 15
	_all_items.append(commendation)

	var family_photo := EvidenceItem.new()
	family_photo.id = "family_photo"
	family_photo.display_name = "Family Photograph"
	family_photo.category = EvidenceItem.ItemCategory.SAFE
	family_photo.texture_path = "res://assets/minigames/evidence_destruction/items/safe/family_photo.svg"
	family_photo.description = "Mom, Dad, and little Sprout. Posed in front of the old house. The frame is slightly chipped."
	family_photo.inner_monologue = "They don't know what you've become. What you're about to do."
	family_photo.shred_suspicion = 5
	_all_items.append(family_photo)

	var pay_stub := EvidenceItem.new()
	pay_stub.id = "pay_stub"
	pay_stub.display_name = "Pay Stub"
	pay_stub.category = EvidenceItem.ItemCategory.SAFE
	pay_stub.texture_path = "res://assets/minigames/evidence_destruction/items/safe/pay_stub.svg"
	pay_stub.description = "This week's wages. Government header, perforated edge. Proof you're a normal, employed citizen."
	pay_stub.shred_suspicion = 10
	_all_items.append(pay_stub)

	# === AMBIGUOUS ITEMS (Either Choice OK) ===

	var bookmark := EvidenceItem.new()
	bookmark.id = "bookmark"
	bookmark.display_name = "Fabric Bookmark"
	bookmark.category = EvidenceItem.ItemCategory.AMBIGUOUS
	bookmark.texture_path = "res://assets/minigames/evidence_destruction/items/ambiguous/bookmark.svg"
	bookmark.description = "A handmade bookmark with a pressed flower inside. She lent you a book once. This was inside."
	bookmark.inner_monologue = "Sasha's. She probably forgot it was there. Or maybe she didn't."
	bookmark.shred_suspicion = 5
	bookmark.stash_suspicion = 0
	_all_items.append(bookmark)

	var doodle := EvidenceItem.new()
	doodle.id = "doodle"
	doodle.display_name = "Checkpoint Doodle"
	doodle.category = EvidenceItem.ItemCategory.AMBIGUOUS
	doodle.texture_path = "res://assets/minigames/evidence_destruction/items/ambiguous/doodle.svg"
	doodle.description = "A scrap of paper with idle sketches. The checkpoint, some stick figures, the fence line. Bored meeting doodles... or reconnaissance?"
	doodle.shred_suspicion = 0
	doodle.stash_suspicion = 5
	_all_items.append(doodle)

	var newspaper := EvidenceItem.new()
	newspaper.id = "newspaper_clipping"
	newspaper.display_name = "Newspaper Clipping"
	newspaper.category = EvidenceItem.ItemCategory.AMBIGUOUS
	newspaper.texture_path = "res://assets/minigames/evidence_destruction/items/ambiguous/newspaper_clipping.svg"
	newspaper.description = "A torn headline: \"MISSING CITIZENS RELOCATED TO BETTER OPPORTUNITIES\". Some words are circled in red pen."
	newspaper.shred_suspicion = 5
	newspaper.stash_suspicion = 10
	_all_items.append(newspaper)

	var unsigned_note := EvidenceItem.new()
	unsigned_note.id = "unsigned_note"
	unsigned_note.display_name = "Unsigned Note"
	unsigned_note.category = EvidenceItem.ItemCategory.AMBIGUOUS
	unsigned_note.texture_path = "res://assets/minigames/evidence_destruction/items/ambiguous/unsigned_note.svg"
	unsigned_note.description = "\"Usual place. Midnight.\" No signature. Could be romantic. Could be conspiracy."
	unsigned_note.shred_suspicion = 0
	unsigned_note.stash_suspicion = 5
	_all_items.append(unsigned_note)

	var snack_wrapper := EvidenceItem.new()
	snack_wrapper.id = "snack_wrapper"
	snack_wrapper.display_name = "Snack Wrapper"
	snack_wrapper.category = EvidenceItem.ItemCategory.AMBIGUOUS
	snack_wrapper.texture_path = "res://assets/minigames/evidence_destruction/items/ambiguous/snack_wrapper.svg"
	snack_wrapper.description = "A crumpled wrapper from Spuddy's Crispy Chips. Her favorite. You bought them to share."
	snack_wrapper.inner_monologue = "She always picked out the burnt ones. Said they had more flavor."
	snack_wrapper.shred_suspicion = 0
	snack_wrapper.stash_suspicion = 0
	_all_items.append(snack_wrapper)

	var cigarette_case := EvidenceItem.new()
	cigarette_case.id = "cigarette_case"
	cigarette_case.display_name = "Viktor's Cigarette Case"
	cigarette_case.category = EvidenceItem.ItemCategory.AMBIGUOUS
	cigarette_case.texture_path = "res://assets/minigames/evidence_destruction/items/ambiguous/cigarette_case.svg"
	cigarette_case.description = "A tarnished metal case. Inside the lid: \"ELENA\" engraved in flowing script. Viktor's wife. The one on the manifest."
	cigarette_case.inner_monologue = "He gave this to you for safekeeping. Said he couldn't bear to look at it anymore."
	cigarette_case.shred_suspicion = 0
	cigarette_case.stash_suspicion = 0
	cigarette_case.required_variable = "viktor_allied"
	cigarette_case.required_value = "yes"
	_all_items.append(cigarette_case)


func _select_items_for_desk() -> void:
	_desk_items.clear()

	# Filter items based on story conditions
	var available_items: Array[EvidenceItem] = []
	for item in _all_items:
		if item.should_appear():
			available_items.append(item)

	# Shuffle available items
	available_items.shuffle()

	# Ensure we have a good mix of categories
	var evidence_items: Array[EvidenceItem] = []
	var safe_items: Array[EvidenceItem] = []
	var ambiguous_items: Array[EvidenceItem] = []

	for item in available_items:
		match item.category:
			EvidenceItem.ItemCategory.EVIDENCE:
				evidence_items.append(item)
			EvidenceItem.ItemCategory.SAFE:
				safe_items.append(item)
			EvidenceItem.ItemCategory.AMBIGUOUS:
				ambiguous_items.append(item)

	# Select items: prioritize evidence, then fill with safe and ambiguous
	var target_evidence: int = mini(evidence_items.size(), 4)
	var target_safe: int = mini(safe_items.size(), 5)
	var target_ambiguous: int = mini(ambiguous_items.size(), 3)

	for i in range(target_evidence):
		_desk_items.append(evidence_items[i])

	for i in range(target_safe):
		_desk_items.append(safe_items[i])

	for i in range(target_ambiguous):
		_desk_items.append(ambiguous_items[i])

	# Shuffle final selection
	_desk_items.shuffle()

	# Limit to items_to_show
	if _desk_items.size() > items_to_show:
		_desk_items.resize(items_to_show)

	_items_remaining = _desk_items.size()


func _populate_desk_grid() -> void:
	if not _desk_grid:
		push_error("[EvidenceDestruction] No desk grid found!")
		return

	# Clear existing buttons
	for child in _desk_grid.get_children():
		child.queue_free()
	_item_buttons.clear()

	# Create button for each item
	for i in range(_desk_items.size()):
		var item := _desk_items[i]
		var button := Button.new()
		button.custom_minimum_size = Vector2(100, 100)
		button.icon = _card_back_texture
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true

		# Store item reference
		button.set_meta("item_index", i)
		button.set_meta("revealed", false)
		button.pressed.connect(_on_item_button_pressed.bind(button))

		_desk_grid.add_child(button)
		_item_buttons.append(button)


func _on_item_button_pressed(button: Button) -> void:
	var item_index: int = button.get_meta("item_index", -1)
	if item_index < 0 or item_index >= _desk_items.size():
		return

	var item := _desk_items[item_index]

	# Reveal the item if not already revealed
	if not button.get_meta("revealed", false):
		button.set_meta("revealed", true)
		# Load and set the actual item texture
		var texture := load(item.texture_path) as Texture2D
		if texture:
			button.icon = texture

	# Show examine panel
	_show_examine_panel(item, button)


func _show_examine_panel(item: EvidenceItem, source_button: Button) -> void:
	_currently_examining = item

	if not _examine_panel:
		return

	# Update examine panel content
	if _examine_image:
		var texture := load(item.texture_path) as Texture2D
		if texture:
			_examine_image.texture = texture

	if _examine_name:
		_examine_name.text = item.display_name

	if _examine_description:
		_examine_description.text = item.description

	if _examine_monologue:
		if item.inner_monologue.is_empty():
			_examine_monologue.visible = false
		else:
			_examine_monologue.visible = true
			_examine_monologue.text = "[i]" + item.inner_monologue + "[/i]"

	# Store reference to source button for removal
	_examine_panel.set_meta("source_button", source_button)

	# Show the panel
	_examine_panel.visible = true

	emit_signal("item_examined", item)


func _on_shred_pressed() -> void:
	if not _currently_examining:
		return

	_process_item_action(_currently_examining, "shred")


func _on_stash_pressed() -> void:
	if not _currently_examining:
		return

	_process_item_action(_currently_examining, "stash")


func _process_item_action(item: EvidenceItem, action: String) -> void:
	# Calculate suspicion change
	var suspicion_change: int = 0

	if action == "shred":
		suspicion_change = item.shred_suspicion
		_shredded_items.append(item)
	else:  # stash
		suspicion_change = item.stash_suspicion
		_stashed_items.append(item)

	# Apply suspicion
	if suspicion_change > 0:
		_suspicion = minf(_suspicion + suspicion_change, suspicion_threshold)
		emit_signal("suspicion_changed", _suspicion)

	# Remove item from desk
	_desk_items.erase(item)
	_items_remaining = _desk_items.size()

	# Remove the button
	if _examine_panel:
		var source_button: Button = _examine_panel.get_meta("source_button", null)
		if source_button and is_instance_valid(source_button):
			source_button.queue_free()
			_item_buttons.erase(source_button)

	# Hide examine panel
	_examine_panel.visible = false
	_currently_examining = null

	emit_signal("item_disposed", item, action)

	# Update UI
	_update_ui()

	# Check win condition
	if _items_remaining <= 0:
		_on_desk_cleared()


func _update_ui() -> void:
	if _suspicion_bar:
		_suspicion_bar.value = _suspicion
		_suspicion_bar.max_value = suspicion_threshold

	if _suspicion_label:
		_suspicion_label.text = "Suspicion: %d%%" % int((_suspicion / suspicion_threshold) * 100)

	if _items_remaining_label:
		_items_remaining_label.text = "Items: %d" % _items_remaining


func _on_desk_cleared() -> void:
	# Check for stashed evidence (will be found during inspection)
	var evidence_found: Array[String] = []
	for item in _stashed_items:
		if item.found_if_stashed:
			evidence_found.append(item.id)

	# Determine outcome
	var inspection_result: String = "clean"

	if evidence_found.size() > 0:
		inspection_result = "compromised"
	elif _suspicion >= suspicion_threshold * 0.5:
		inspection_result = "suspicious"

	# Set Dialogic variable for narrative branching
	if Dialogic and Dialogic.VAR:
		Dialogic.VAR.set_variable("inspection_result", inspection_result)
		Dialogic.VAR.set_variable("evidence_found", evidence_found.size() > 0)
		if evidence_found.size() > 0:
			Dialogic.VAR.set_variable("evidence_found_type", evidence_found[0])

	# Complete with results
	complete_success(0, {
		"inspection_result": inspection_result,
		"suspicion_level": _suspicion,
		"evidence_found": evidence_found,
		"items_shredded": _shredded_items.size(),
		"items_stashed": _stashed_items.size()
	})


func _on_time_up() -> void:
	# Time ran out - inspection happens with desk as-is
	var evidence_on_desk: Array[String] = []
	var evidence_stashed: Array[String] = []

	# Check remaining items on desk
	for item in _desk_items:
		if item.category == EvidenceItem.ItemCategory.EVIDENCE:
			evidence_on_desk.append(item.id)

	# Check stashed items
	for item in _stashed_items:
		if item.found_if_stashed:
			evidence_stashed.append(item.id)

	var all_evidence: Array[String] = evidence_on_desk + evidence_stashed
	var inspection_result: String = "compromised" if all_evidence.size() > 0 else "suspicious"

	# Set Dialogic variables
	if Dialogic and Dialogic.VAR:
		Dialogic.VAR.set_variable("inspection_result", inspection_result)
		Dialogic.VAR.set_variable("evidence_found", all_evidence.size() > 0)

	# Override parent behavior - we want specific handling
	_result.success = false
	_result.score_bonus = 0
	_result.time_taken = time_limit
	_result.merge({
		"inspection_result": inspection_result,
		"evidence_found": all_evidence,
		"timed_out": true
	})

	if instruction_label:
		if all_evidence.size() > 0:
			instruction_label.text = "Time's up! They found the evidence..."
		else:
			instruction_label.text = "Time's up! The inspection was... thorough."

	_on_minigame_complete()
	await get_tree().create_timer(1.5).timeout
	_finish()


func _on_minigame_complete() -> void:
	# Clean up any remaining UI state
	if _examine_panel:
		_examine_panel.visible = false
