extends Node2D

var border_runner_system
var regular_potato_speed = 0.5

# Track game states
var is_game_paused: bool = false
var close_sound_played: bool = false
var open_sound_played: bool = false
var is_potato_in_office: bool = false
var game_start_time: float = 0.0

# track the current potato's info
var current_potato_info
var current_potato

# Track win and lose parameters
var difficulty_level

var ui_hint_system: UIHintSystem

# Track multipliers and streaks
var point_multiplier: float = 1.0
var correct_decision_streak: int = 0
var original_runner_chance: float = 0.15  

# storing and sending rule assignments
signal rules_updated(new_rules)
var current_rules = []

var queue_manager: Node2D

var previous_quota: int = -1
var previous_strikes: int = -1

# Potato spawn manager
var potato_count: int = 0
var max_potatoes: int = 20
@onready var spawn_timer = $SystemManagers/Timers/SpawnTimer

#Narrative manager
@onready var narrative_manager = %NarrativeManager

# Grab BGM Player
@onready var bgm_player = $SystemManagers/AudioManager/BackgroundMusicPlayer

# Musical intervals (simplified selection)
var musical_intervals = {
	"original": 1.0,        # Original pitch
	"major_third_down": 0.8, # More somber
	"major_third_up": 1.25,  # Brighter feel
	"fifth_down": 0.67,      # Much darker
	"fifth_up": 1.5          # Brighter, heroic
}

# Current tracks
var bgm_tracks = []
var current_track_index = 0

# Passport
var passport: Sprite2D
var passport_spawn_point_begin: Node2D
var passport_spawn_point_end: Node2D
var inspection_table: Sprite2D
@onready var suspect_panel = $Gameplay/SuspectPanel
var suspect_panel_front: Sprite2D
var suspect: Sprite2D

var default_cursor = Input.CURSOR_ARROW

# Character Generation
@onready var mugshot_generator = $Gameplay/MugshotPhotoGenerator
@onready var passport_generator = $Gameplay/InteractiveElements/Passport/OpenPassport/PassportPhotoGenerator

@onready var megaphone = $Gameplay/InteractiveElements/Megaphone
@onready var megaphone_dialogue_box = $Gameplay/InteractiveElements/Megaphone/MegaphoneDialogueBox
@onready var enter_office_path = $Gameplay/Paths/EnterOfficePath
@onready var stats_manager = $SystemManagers/StatsManager
var shift_stats: ShiftStats
@onready var shift_summary = preload("res://scripts/systems/ShiftSummaryScreen.tscn")

## Label used to display alerts and notifications to the player
@onready var alert_label = $UI/Labels/MarginContainer/AlertLabel
@onready var alert_timer = $SystemManagers/Timers/AlertTimer

# Unpause timer so we don't sinkhole ourselves
var safety_unpause_timer: Timer


var current_shift: int = 1

# Combo system variables
var combo_count = 0
var combo_timer = 0.0
var combo_timeout = 15.0  # Seconds before combo resets
var max_combo_multiplier = 3.0

# Drag and drop manager 
@onready var drag_and_drop_manager = $SystemManagers/DragAndDropManager

# Stamp System Manager
@onready var stamp_system_manager: StampSystemManager

# Office Shutter Controller
@onready var office_shutter_controller: OfficeShutterController = $Gameplay/InteractiveElements/OfficeShutterController

# Character generator, used for fade in/out 
@export var character_generator: CharacterGenerator

func get_level_manager():
	var parent = get_parent()
	while parent:
		if parent is LevelListManager:
			return parent
		
		# Look for the manager in children
		for child in parent.get_children():
			if child is LevelListManager:
				return child
				
		parent = parent.get_parent()
	
	return null

func _ready():
	# Setup the default z_indexes for elements
	$UI/ScreenBorders.z_index = ConstantZIndexes.Z_INDEX.SCREEN_BORDERS
	$UI/Environment.z_index = ConstantZIndexes.Z_INDEX.ENVIRONMENT
	$Gameplay/InspectionTable.z_index = ConstantZIndexes.Z_INDEX.INSPECTION_TABLE
	%OfficeShutterController.z_index = ConstantZIndexes.Z_INDEX.OFFICE_SHUTTER
	$Gameplay/SuspectPanel.z_index = ConstantZIndexes.Z_INDEX.SUSPECT_PANEL
	$Gameplay/MugshotPhotoGenerator.z_index = ConstantZIndexes.Z_INDEX.SUSPECT
	
	safety_unpause_timer = Timer.new()
	safety_unpause_timer.one_shot = true
	safety_unpause_timer.wait_time = 10.0  # 10 seconds safety timeout
	safety_unpause_timer.timeout.connect(_on_safety_unpause_timeout)
	add_child(safety_unpause_timer)
	
	# Initialize core systems
	_setup_managers()
	_setup_game_state()
	
	# Initialize UI and connect signals
	_setup_ui()
	_connect_signals()
	
	# Start gameplay systems
	_setup_gameplay_systems()
	
	# Start the narrative for this shift
	_start_narrative()
	
	

func _setup_managers():
	# Initialize drag and drop manager
	if not drag_and_drop_manager:
		var manager = DragAndDropManager.new()
		manager.name = "DragAndDropManager"
		$SystemManagers.add_child(manager)
		drag_and_drop_manager = manager
	
	drag_and_drop_manager.initialize(self)
	
	# Initialize other systems
	setup_stamp_system()
	setup_spawn_timer()
	
	# Get essential system references
	queue_manager = %QueueManager
	border_runner_system = %BorderRunnerSystem
	original_runner_chance = border_runner_system.runner_chance

func _setup_game_state():
	# Initialize game state and stats
	current_shift = Global.shift
	Global.shift = current_shift  # Ensure synchronization
	
	shift_stats = stats_manager.get_new_stats()
	game_start_time = Time.get_ticks_msec() / 1000.0
	
	# Load difficulty settings
	difficulty_level = Global.difficulty_level
	set_difficulty(difficulty_level)
	
	# Generate game rules
	generate_rules()
	
	# Initialize tracking variables
	previous_quota = 0
	previous_strikes = 0
	
	# Load tracks for music system
	load_tracks()

func _setup_ui():
	# Initialize UI hints system
	ui_hint_system = UIHintSystem.new()
	add_child(ui_hint_system)
	
	# Register UI hint elements
	_register_ui_hints()
	
	# Update UI displays
	update_score_display()
	update_quota_display()
	update_strikes_display()
	# TODO: update_date_display()
	# TODO: update_combo_display()
	
	# Display high score if available
	_check_and_display_high_score()
	
	# Set UI element references
	_setup_ui_references()

func _register_ui_hints():
	ui_hint_system.register_hintable($Gameplay/InteractiveElements/Passport/ClosedPassport, "passport", 15.0)
	ui_hint_system.register_hintable(megaphone, "megaphone", 15.0)
	ui_hint_system.register_hintable($Gameplay/InteractiveElements/StampBarController, "stamp_bar", 15.0)

func _check_and_display_high_score():
	var high_score = GameState.get_high_score(current_shift)
	if high_score > 0:
		Global.display_green_alert(alert_label, alert_timer, "High score for this level: " + str(high_score))
	
	if Global.final_score > 0:
		Global.score = Global.final_score
		update_score_display()
	
	if Global.quota_met > 0:
		update_quota_display()

func _setup_ui_references():
	passport = $Gameplay/InteractiveElements/Passport
	passport_spawn_point_begin = $Gameplay/InteractiveElements/PassportSpawnPoints/BeginPoint
	passport_spawn_point_end = $Gameplay/InteractiveElements/PassportSpawnPoints/EndPoint
	inspection_table = $Gameplay/InspectionTable
	suspect_panel = $Gameplay/SuspectPanel
	suspect_panel_front = $Gameplay/SuspectPanel/SuspectPanelFront
	suspect = $Gameplay/MugshotPhotoGenerator/SizingSprite
	update_strikes_display()

func _on_safety_unpause_timeout():
	# Force unpause if dialogue takes too long or gets stuck
	if get_tree().paused:
		print("Safety unpause triggered - dialogue may have gotten stuck")
		get_tree().paused = false
		is_game_paused = false
		# Try to recover the game flow
		_on_dialogue_finished()

func _connect_signals():
	# Narrative signals
	narrative_manager.intro_dialogue_finished.connect(_on_intro_dialogue_finished)
	narrative_manager.end_dialogue_finished.connect(_on_end_dialogue_finished)
	
	# System signals
	drag_and_drop_manager.drag_system.passport_returned.connect(_on_passport_returned)
	Global.score_updated.connect(_on_score_updated)
	border_runner_system.game_over_triggered.connect(_on_game_over)
	
	# UI signals
	ui_hint_system.hint_deactivated.connect(_on_hint_deactivated)
	
	# Dialogic signals
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_finished)

func _setup_gameplay_systems():
	# Enable border runner system
	border_runner_system.is_enabled = true

func _start_narrative():
	# Set shift in narrative manager
	narrative_manager.current_shift = current_shift
	
	# Start the intro dialogue for current shift
	narrative_manager.start_level_dialogue(current_shift)

# Dedicated function to set up the stamp system
func setup_stamp_system():
	# Create the stamp system manager
	stamp_system_manager = StampSystemManager.new()
	stamp_system_manager.name = "StampSystemManager"
	$SystemManagers.add_child(stamp_system_manager)
	
	# Initialize it with a reference to this scene
	stamp_system_manager.initialize(self)
	
	# IMPORTANT: Pass the reference to the drag_and_drop_manager
	if drag_and_drop_manager:
		drag_and_drop_manager.set_stamp_system_manager(stamp_system_manager)
	
	# Connect to the stamp decision signal
	stamp_system_manager.stamp_decision_made.connect(_on_stamp_decision_made)
	
	# Make sure the passport is stampable
	_setup_passport_stampable()
	
	# Get reference to the stamp bar controller
	var stamp_bar_controller = $Gameplay/InteractiveElements/StampBarController
	if stamp_bar_controller:
		# Connect stamp_bar signals to the stamp system
		if not stamp_bar_controller.stamp_selected.is_connected(stamp_system_manager.stamp_system.on_stamp_requested):
			stamp_bar_controller.stamp_selected.connect(stamp_system_manager.stamp_system.on_stamp_requested)
	else:
		push_error("StampBarController not found in scene")

# Add this function to mainGame.gd
func _setup_passport_stampable():
	# Get references to necessary nodes
	var passport_node = $Gameplay/InteractiveElements/Passport
	var open_passport_node = $Gameplay/InteractiveElements/Passport/OpenPassport
	
	if passport_node and open_passport_node:
		# Define the stamp area - where stamps should be placed for a "perfect" stamp
		# This depends on your passport UI layout
		var passport_rect = passport_node.get_rect()
		var stamp_area = Rect2(
			passport_node.global_position + Vector2(120, 120),  # Adjust based on your layout
			Vector2(160, 80)  # Adjust based on desired stamp area size
		)
		
		# Get reference to the stamp system from the manager
		var stamp_system = stamp_system_manager.stamp_system
		if stamp_system:
			# Register the passport with the stamp system
			stamp_system_manager.passport_stampable = stamp_system.register_stampable(
				passport_node,
				open_passport_node,
				stamp_area
			)
		else:
			push_error("Stamp system not found in stamp_system_manager")
	else:
		push_error("Passport node or OpenPassport node not found")

# Handle stamp decisions
func _on_stamp_decision_made(decision: String, is_perfect: bool):
	if decision == "approved":
		process_decision(true)
	elif decision == "rejected":
		process_decision(false)
	ui_hint_system.reset_timer("stamp_bar")

func _on_passport_returned(item):
	remove_stamp()

func add_to_combo():
	combo_count += 1
	combo_timer = 0.0
	
	# Calculate multiplier (starts at 1.0, maxes at max_combo_multiplier)
	var multiplier = min(1.0 + (combo_count * 0.1), max_combo_multiplier)
	
	# Show combo notification
	if combo_count > 1:
		var combo_text = "COMBO x" + str(combo_count) + " (" + str(multiplier) + "x points)"
		Global.display_green_alert(alert_label, alert_timer + " : " + combo_text, 1.5)
	
	return multiplier

func reset_combo():
	if combo_count > 1:
		Global.display_red_alert(alert_label, alert_timer + " : Combo Broken!", 1.5)
	combo_count = 0
	combo_timer = 0.0

func award_points(base_points: int):
	var multiplier = add_to_combo()
	var total_points = base_points * multiplier
	Global.add_score(total_points)
	return total_points

func end_shift(success: bool = true):
	# First check if we've hit the demo limit
	if Global.build_type == "Demo Release" and Global.shift >= 2 and success:
		# We only show the demo limit message if the player successfully completed shift 2
		# This will prevent the normal shift completion flow
		await get_tree().create_timer(1.0).timeout  # Small delay for better flow
		show_demo_limit_dialog()
		return
	# Disable player inputs 
	set_process_input(false)
	
	# Disable all systems that generate footprints
	if queue_manager:
		# Stop all active potatoes from creating more footprints
		for potato in queue_manager.potatoes:
			if is_instance_valid(potato):
				# Disable _process on potatoes to prevent new footprints
				potato.set_process(false)
	
	# Disable timer that spawns potatoes
	if spawn_timer:
		spawn_timer.stop()
	
	# Completely disable border runner system
	if border_runner_system:
		border_runner_system.disable()
		border_runner_system.is_enabled = false
	
	if queue_manager:
		if queue_manager.has_method("disable"):
			queue_manager.disable()
		else:
			# Fallback if method isn't added yet
			queue_manager.set_process(false)
	
	# Disable UI hints
	if ui_hint_system:
		ui_hint_system.set_all_hints_enabled(false)
	
	# Disable all path following for any active runners
	var root = get_tree().current_scene
	var active_potatoes = get_tree().get_nodes_in_group("PotatoPerson")
	for potato in active_potatoes:
		if potato:
			potato.set_process(false)  # Stop processing/movement
			# If it has path following, disable it directly
			if potato.has_method("leave_path"):
				potato.leave_path()
	
	# Fade out all corpses and footprints
	fade_out_group_elements()
	
	# Reset the shutter state for the next shift
	office_shutter_controller.shutter_opened_this_shift = false
	
	# Calculate final time taken if not already done
	if shift_stats.time_taken == 0:
		shift_stats.time_taken = (Time.get_ticks_msec() / 1000.0) - game_start_time
		
	# Get border runner statistics if not already copied
	if shift_stats.missiles_fired == 0:
		var runner_stats = border_runner_system.shift_stats
		shift_stats.missiles_fired = runner_stats.missiles_fired
		shift_stats.missiles_hit = runner_stats.missiles_hit
		shift_stats.perfect_hits = runner_stats.perfect_hits
	
	# Calculate the hit rate
	shift_stats.hit_rate = 0.0 if shift_stats.missiles_fired == 0 else (float(shift_stats.missiles_hit) / shift_stats.missiles_fired * 100.0)
	
	# IMPORTANT: Process any pending stamp decision before finalizing
	var stamp_decision = ""
	if stamp_system_manager and stamp_system_manager.passport_stampable:
		stamp_decision = stamp_system_manager.process_passport_decision()
		if stamp_decision != "":
			# Process the last decision before ending
			process_decision(stamp_decision == "approved")
	
	
	# If it was a successful shift completion, add bonus
	if success and Global.quota_met >= Global.quota_target:
		# Add survival bonus
		var survival_bonus = 500
		Global.display_green_alert(
			alert_label, 
			alert_timer, 
			tr("alert_quota_met").format({"bonus": str(survival_bonus)})
		)
		Global.add_score(survival_bonus)
				
		# Lower the shutter with animation when successful
		if not office_shutter_controller.shutter_opened_this_shift:
			office_shutter_controller.lower_shutter(1.0)
		
		# Setting high score for current level and difficulty
		print("Setting high score of: ", Global.score, " for : ", current_shift, " and difficulty level", difficulty_level)
		GameState.set_high_score(current_shift, Global.difficulty_level, Global.score)
	
	GlobalState.save()
	
	# Update quota display one last time to ensure it's correct
	update_quota_display()
	
	# Update strike display
	update_strikes_display()
	
	# Update shift_stats with shift_number before ending shift
	shift_stats.shift_number = Global.shift
	
	# calculate end of shift bonuses
	shift_stats.processing_speed_bonus = shift_stats.get_speed_bonus()
	shift_stats.accuracy_bonus = shift_stats.get_accuracy_bonus()
	shift_stats.perfect_hit_bonus = shift_stats.get_missile_bonus()
	
	# Add bonuses to Score
	shift_stats.final_score = Global.score + shift_stats.get_total_bonus()
	
	# Store game stats
	Global.store_game_stats(shift_stats)
	
	# Convert ShiftStats to a dictionary
	var stats_dict = {
		"shift": Global.shift,
		"time_taken": shift_stats.time_taken,
		"processing_time_left": shift_stats.processing_time_left,
		"score": Global.score,
		"missiles_fired": shift_stats.missiles_fired,
		"missiles_hit": shift_stats.missiles_hit,
		"perfect_hits": shift_stats.perfect_hits,
		"total_stamps": shift_stats.total_stamps,
		"potatoes_approved": shift_stats.potatoes_approved,
		"potatoes_rejected": shift_stats.potatoes_rejected,
		"perfect_stamps": shift_stats.perfect_stamps,
		"hit_rate": shift_stats.hit_rate,
		"runner_attempts": shift_stats.runner_attempts,
		"processing_speed_bonus": shift_stats.processing_speed_bonus,
		"accuracy_bonus": shift_stats.accuracy_bonus,
		"perfect_hit_bonus": shift_stats.perfect_hit_bonus,
		"final_score": shift_stats.final_score,
		"quota_met": Global.quota_met,
		"quota_target": Global.quota_target,
		"strikes": Global.strikes,
		"max_strikes": Global.max_strikes,
		"success": success
	}
	
	# After updating all stats but before showing the summary screen
	GlobalState.save()
	
	# Before starting end dialogue, ensure we're in a state that allows dialogue to run
	get_tree().paused = false  # Temporarily unpause
	is_game_paused = false     # Clear the game pause flag
	# Add to end_shift function:
	print("Ending shift ", current_shift, " with success: ", success)
	print("Tree paused state: ", get_tree().paused)
	print("Game paused state: ", is_game_paused)
	# Check if there's an end dialogue for this shift
	if narrative_manager and narrative_manager.LEVEL_END_DIALOGUES.has(current_shift):
		print("Starting end dialogue for shift: ", current_shift)
		# If this is shift 10, we need to ensure the final confrontation plays
		if current_shift == 10:
			narrative_manager.start_level_end_dialogue(current_shift)
			# Wait for dialogue to finish before showing summary
			await narrative_manager.end_dialogue_finished
			return  # Skip showing shift summary for final confrontation
		else:
			# For other shifts, continue with normal end dialogue
			narrative_manager.start_level_end_dialogue(current_shift)
			await narrative_manager.end_dialogue_finished
	
	# If no dialogue, show the summary screen immediately
	_show_shift_summary_screen(stats_dict)
	
func _show_shift_summary_screen(stats_dict: Dictionary):
	# Set game process mode to handle pause better during transitions
	get_tree().paused = false
	
	# Set Stamp Bar Controller to be below shift summary screen
	$Gameplay/InteractiveElements/StampBarController.z_index = 1
	
	# Create a tween for a cleaner fade transition
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport_rect().size
	fade_rect.z_index = 23
	add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_interval(2)  # Add a delay

	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0.75), 1.5)
	
	tween.tween_callback(func():
		# Play the motion sound for the shift summary screen descending
		if $SystemManagers/AudioManager/SFXPool:
			var motion_sound = load("res://assets/audio/ui_feedback/motion_straight_air.wav")
			if motion_sound:
				$SystemManagers/AudioManager/SFXPool.stream = motion_sound
				$SystemManagers/AudioManager/SFXPool.play()
			else:
				push_warning("Failed to load motion_straight_air.wav sound")
	)
	
	tween.tween_callback(func():
		# Show summary screen after fade
		var summary = shift_summary.instantiate()
		
		# Connect the signals
		summary.continue_to_next_shift.connect(_on_shift_summary_continue)
		summary.restart_shift.connect(_on_shift_summary_restart)
		summary.return_to_main_menu.connect(_on_shift_summary_main_menu)
		
		add_child(summary)
		summary.show_summary(stats_dict)
	)
	
	
func _on_shift_summary_continue():
	print("Continuing to next shift")
	
	# Save the current shift number before advancing
	var completed_shift = current_shift
	
	# Check for demo limit before proceeding
	if Global.build_type == "Demo Release" and completed_shift >= 2:
		# Show demo limit message
		show_demo_limit_dialog()
		return
	
	# Save high score for the current level
	GameState.set_high_score(completed_shift, Global.difficulty_level, Global.score)
	
	# Advance the shift and story state
	Global.advance_shift()
	Global.advance_story_state()
	
	# Make sure GameState is updated with our progress
	GameState.level_reached(Global.shift)
	
	# Show day transition
	narrative_manager.show_day_transition(completed_shift, completed_shift + 1)
	
	# Reload the game scene for the next shift
	if SceneLoader:
		print("Using SceneLoader to reload")
		SceneLoader.reload_current_scene()
	else:
		push_error("SceneLoader not found, falling back to change_scene_to_file")
		get_tree().change_scene_to_file("res://scenes/game_scene/mainGame.tscn")

func _on_shift_summary_restart():
	# Keep the same shift but reset the stats
	Global.reset_shift_stats()
	Global.reset_game_state()
	GlobalState.save()
	if SceneLoader:
		SceneLoader.reload_current_scene()
	else:
		push_error("SceneLoader not found, falling back to change_scene_to_file")
		get_tree().change_scene_to_file("res://scenes/game_scene/mainGame.tscn")

func _on_shift_summary_main_menu():
	# Save state before transitioning to main menu
	GlobalState.save()
	fade_transition()
	# Access SceneLoader directly
	push_warning("Using direct change_scene_to_file, SceneLoader not working as expected.")
	get_tree().change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	
	
func set_difficulty(level):
	difficulty_level = level
	
	# Set strike limits based on difficulty
	match difficulty_level:
		"Easy":
			Global.max_strikes = 6
			regular_potato_speed = 0.4
		"Normal":
			Global.max_strikes = 4
			regular_potato_speed = 0.5
		"Expert":
			Global.max_strikes = 3
			regular_potato_speed = 0.6
	
	update_quota_display()
	update_strikes_display()

func generate_rules():
	# Get the full list of rules from LawValidator
	var all_rules = LawValidator.LAW_CHECKS.keys()
	
	# Randomly select 2-3 rules
	all_rules.shuffle()
	current_rules = all_rules.slice(0, randi() % 2 + 2)
	
	update_rules_display()
	
func update_rules_display():
	var laws_text = "[center][u]" + tr("LAWS") + "[/u]\n\n"
	
	for rule_key in current_rules:
		laws_text += tr(rule_key) + "\n"
	
	laws_text += "[/center]"
	
	if $Gameplay/InteractiveElements/LawReceipt/OpenReceipt/ReceiptNote:
		$Gameplay/InteractiveElements/LawReceipt/OpenReceipt/ReceiptNote.text = laws_text
	
	# Emit the signal with the formatted laws text
	emit_signal("rules_updated", laws_text)
	
func is_potato_valid(potato_info: Dictionary) -> bool:
	# Use the LawValidator to check violations
	var validation = LawValidator.check_violations(potato_info, current_rules)
	return validation.is_valid

func update_date_display():
	var current_date = Time.get_date_dict_from_system()
	var formatted_date = "%04d.%02d.%02d" % [current_date.year, current_date.month, current_date.day]
	$UI/Labels/DateLabel.text = formatted_date

func megaphone_clicked():
	# Check if there's already a potato in the Customs Office
	if is_potato_in_office:
		#print("A potato is already in the customs office!")
		megaphone_dialogue_box.set_random_message_from_category("spud_in_office")
		return
		
	var potato = queue_manager.remove_front_potato()
	if potato:
		if office_shutter_controller.active_shutter_state == office_shutter_controller.ShutterState.CLOSED:
			# Fade out the foreground shadow on the potato when they enter, only in story mode
			if Global.game_mode == "score_attack":
				pass
			else:
				character_generator.fade_out_foreground_shadow()
	
		# Only raise the shutter on the first megaphone click of the shift
		megaphone_dialogue_box.set_random_message_from_category("spud_being_called")
		is_potato_in_office = true
		
		# Use the potato info directly from the potato object instead of generating new info
		current_potato_info = potato.get_potato_info()
		current_potato = potato
		
		# Move potato to the office
		move_potato_to_office(potato)
	else: # No potatoes
		megaphone_dialogue_box.set_random_message_from_category("misc")
		
func move_potato_to_office(potato_person: PotatoPerson):
	print("Moving potato to customs office")
	print("Potato info: Race: ", potato_person.potato_info.race, 
		  " Sex: ", potato_person.potato_info.sex,
		  " Character Data: ", potato_person.potato_info.character_data if potato_person.potato_info.has("character_data") else "MISSING")
	
	if potato_person.get_parent():
		potato_person.get_parent().remove_child(potato_person)
		
	var path_follow = PathFollow2D.new()
	path_follow.rotates = false 
	enter_office_path.add_child(path_follow)
	path_follow.add_child(potato_person)
	
	potato_person.position = Vector2.ZERO
	path_follow.progress_ratio = 0.0
	
	# Calculate a better duration based on path length
	var path_length = enter_office_path.curve.get_baked_length()
	var duration = path_length / 300.0  # Adjust 300.0 to control the speed
	duration = clamp(duration, 0.5, 2.0)  # Ensure reasonable bounds
		
	var tween = create_tween()
	tween.tween_property(path_follow, "progress_ratio", 1.0, duration)
	tween.tween_callback(func():
		# Before cleanup, make sure we've fully captured the potato data including character data
		if !current_potato_info.has("character_data") and potato_person.potato_info.has("character_data"):
			current_potato_info["character_data"] = potato_person.potato_info.character_data
			print("Debug: Fixed missing character data during office transition")
			
		# Clean up the path and potato instance
		potato_person.queue_free()
		path_follow.queue_free()
		
		# Now animate mugshot and passport with the complete info
		animate_mugshot_and_passport()
		# Reset the perfect bonus state for the new potato
		if stamp_system_manager:
			stamp_system_manager.reset_perfect_bonus_state()
	)

# Add this new function to handle path completion
func _on_potato_path_completed(potato: PotatoPerson):
	# Clean up potato and show mugshot
	potato.set_state(potato.TaterState.IN_OFFICE)
	
	potato.queue_free()
	animate_mugshot_and_passport()
	
func animate_mugshot_and_passport():
	# Lift up the office shutter if it's closed
	if office_shutter_controller.active_shutter_state == office_shutter_controller.ShutterState.CLOSED:
		office_shutter_controller.raise_shutter()
	
	print("Starting animate_mugshot_and_passport with potato info:", current_potato_info.race, current_potato_info.sex)
	
	# IMPORTANT: Save a reference to original info
	var original_potato_info = current_potato_info.duplicate()
	
	# Update the display with current potato info
	update_potato_info_display()
	
	# Get references to nodes
	var mugshot_generator = $Gameplay/MugshotPhotoGenerator
	var suspect_panel = $Gameplay/SuspectPanel
	var suspect_panel_spawn_node = $Gameplay/InteractiveElements/SuspectSpawnNode
	var suspect_panel_front = $Gameplay/SuspectPanel/SuspectPanelFront
	var passport = $Gameplay/InteractiveElements/Passport
	var passport_spawn_point_begin = $Gameplay/InteractiveElements/PassportSpawnPoints/BeginPoint
	var passport_spawn_point_end = $Gameplay/InteractiveElements/PassportSpawnPoints/EndPoint

	# Reset positions and visibility
	mugshot_generator.position.x = suspect_panel_spawn_node.position.x + suspect_panel_front.texture.get_width()
	passport.visible = false
	passport.z_index = 7
	passport.position = Vector2(passport_spawn_point_begin.position.x, passport_spawn_point_begin.position.y)

	var tween = create_tween()
	tween.set_parallel(true)

	# Animate potato mugshot
	tween.tween_property(mugshot_generator, "position:x", suspect_panel_spawn_node.position.x, 1)
	tween.tween_property(mugshot_generator, "modulate:a", 1, 1)
	
	# Animate passport
	tween.tween_property(passport, "modulate:a", 1, 1)
	tween.tween_property(passport, "visible", true, 0).set_delay(1)
	tween.tween_property(passport, "position:y", passport_spawn_point_end.position.y, 0.4).set_delay(1)

	# IMPORTANT: After animation finishes, restore the original potato info 
	# to prevent it from being overwritten
	tween.chain().tween_callback(func():
		print("Animation finished, restoring original potato info")
		current_potato_info = original_potato_info
		
		# Update the display again to ensure consistency
		update_potato_info_display()
		
		print("Finished animating mugshot and passport")
	)

func setup_spawn_timer():
	spawn_timer = $SystemManagers/Timers/SpawnTimer
	spawn_timer.set_wait_time(1.0)
	spawn_timer.set_one_shot(false)
	if spawn_timer.is_connected("timeout", Callable(self, "_on_spawn_timer_timeout")):
		pass
		#print("HEY GOOSE: spawn_timer signal is already connected!")
	else:
		spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	# add_child(spawn_timer)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if queue_manager.can_add_potato():
		queue_manager.spawn_new_potato()
	else:
		#print("Potato queue limit reached, skip spawning.")
		spawn_timer.stop()

# Called when player interacts with passport
func _on_passport_interaction():
	ui_hint_system.reset_timer("passport")

# Called when player clicks on megaphone
func _on_megaphone_interaction_button_pressed() -> void:
	ui_hint_system.reset_timer("megaphone")
	megaphone_clicked()
	# Reset the perfect bonus state when a new potato is called
	if stamp_system_manager:
		stamp_system_manager.reset_perfect_bonus_state()
	
# Optional: Callback for hint activation/deactivation
func _on_hint_activated(node_name: String):
	# You could play a sound effect here
	pass
	
func _on_hint_deactivated(node_name: String):
	# You could play a different sound effect here
	pass

var displayed_give_prompt = false

func _process(_delta):
	# Skip hint processing if game is paused or in dialogue
	if is_game_paused or narrative_manager.is_dialogue_active():
		return
		
	 # Update UI hints based on game state
	if is_potato_in_office:
		# We have a potato in the office, so no need to hint megaphone
		ui_hint_system.reset_timer("megaphone")
		
		if drag_and_drop_manager.is_document_open("passport"):
			# Passport is open, so no need to hint it
			ui_hint_system.reset_timer("passport")
			
			# Check if passport has been stamped
			var has_stamp = false
			if stamp_system_manager and stamp_system_manager.passport_stampable:
				has_stamp = stamp_system_manager.passport_stampable.get_decision() != ""
				
			if has_stamp:
				# Passport has been stamped, no need to hint stamp bar
				ui_hint_system.reset_timer("stamp_bar")
			else:
				# Process hint for stamp bar only
				ui_hint_system.process_hints(_delta)
		else:
			# Passport is not open, so hint passport but not stamp bar
			ui_hint_system.reset_timer("stamp_bar")
			ui_hint_system.process_hints(_delta)
	else:
		# No potato in office, so hint megaphone but not passport or stamp bar
		ui_hint_system.reset_timer("passport")
		ui_hint_system.reset_timer("stamp_bar")
		ui_hint_system.process_hints(_delta)
		
	# Handle prompt dialogue visibility
	var mouse_pos = get_global_mouse_position()
	var suspect = $Gameplay/MugshotPhotoGenerator/SizingSprite
	var passport = $Gameplay/InteractiveElements/Passport
	
	# Only show the dialogue if the shutter is OPEN and the passport has been STAMPED
	var should_show_prompt = false
	
	if suspect.get_rect().has_point(suspect.to_local(mouse_pos)) and drag_and_drop_manager.is_document_open("passport") == false and drag_and_drop_manager.drag_system.get_dragged_item() == passport:
		if office_shutter_controller.active_shutter_state == office_shutter_controller.ShutterState.OPEN:
			if stamp_system_manager.passport_stampable.get_decision() != "":
				should_show_prompt = true

	# Hide megaphone dialogue box when the officer sound stops playing
	if !%SFXPool.is_playing():
		megaphone_dialogue_box.visible = false
	
	# Only update if state has changed
	if should_show_prompt != displayed_give_prompt:
		displayed_give_prompt = should_show_prompt
		
		if displayed_give_prompt:
			# Only show the message when newly displaying the prompt
			%GivePromptBubbleDialogueBox.set_random_message_from_category("document_interaction")
			%GivePromptBubbleDialogueBox.visible = true
		else:
			%GivePromptBubbleDialogueBox.visible = false
		
	# Update combo timer
	if combo_count > 0:
		combo_timer += _delta
		if combo_timer > combo_timeout:
			# Combo expired
			reset_combo()

func generate_potato_info():
	# IMPORTANT: Don't generate new info if valid info already exists
	if current_potato_info != null and !current_potato_info.is_empty():
		print("WARNING: Attempted to regenerate potato info but using existing data")
		return current_potato_info
		
	var expiration_date: String
	if randf() < 0.2:
		expiration_date = get_past_date(0, 3)
	else:
		expiration_date = get_future_date(0,3)
		
	# Generate gender first since it affects character generation
	var sex = get_random_sex()
	
	# Generate character appearance only when creating new potato info
	var character_data = {}
	if mugshot_generator:
		mugshot_generator.set_sex("Female" if sex == "Female" else "Male")
		# This will now only happen when a new potato is called in
		character_data = mugshot_generator.get_character_data()
		
		# Also update passport generator
		if passport_generator:
			passport_generator.set_character_data(character_data)
	
	# For race, retrieve it from character_data if available,
	# otherwise just use a fixed default like "Russet"
	var race = character_data.get("race", "Russet")
	
	return {
		"name": get_random_name(),
		"condition": get_random_condition(),
		"sex": sex,
		"race": race,
		"country_of_issue": get_random_country(),
		"date_of_birth": get_past_date(1, 10),
		"expiration_date": expiration_date,
		"character_data": character_data
	}
	
func update_potato_info_display():
	print("Updating potato info display with: ", current_potato_info)
	
	if current_potato_info:
		$Gameplay/InteractiveElements/Passport/OpenPassport/PotatoHeader.text = """{name}""".format(current_potato_info)
		
		# Create translated versions of sex and condition
		var translated_sex = tr("sex_" + current_potato_info.sex.to_lower())
		var translated_condition = tr("condition_" + current_potato_info.condition.to_lower().replace(" ", "_"))
		
		var display_info = current_potato_info.duplicate()
		display_info.sex = translated_sex
		display_info.condition = translated_condition
		
		$Gameplay/InteractiveElements/Passport/OpenPassport/PotatoInfo.text = """{date_of_birth}
		{sex} 
		{country_of_issue}
		{expiration_date} 
		{condition}
		""".format(display_info)
	else:
		print("No current_potato_info found.")
		
	# Update mugshot and passport visuals
	update_potato_texture()

func get_random_name():
	var first_names = [
		"Spud", "Tater", "Mash", "Spudnik", "Tater Tot", "Potato", "Chip", 
		"Murph", "Yam", "Tato", "Spuddy", "Tuber", "Russet", "Fry", "Hash", 
		"Wedge", "Rosti", "Gnocchi", "Gratin", "Duchess", "Rösti", "Hasselback",
		"Dauphinoise", "Fondant", "Croquette", "Scallop", "Pomme", "Aloo", "Batata",
		"Patata", "Kartoffel", "Jicama", "Sunchoke", "Yuca", "Oca", "Taro",
		"Cassava", "Mandioca", "Malanga", "Rutabaga", "Parmentier", "Poutine",
		"Latke", "Ratte", "Fingerling", "Bintje"
		]
	var last_names = [
		"Ouwiw", "Sehi", "Sig", "Heechou", "Oufug", "Azej", "Holly",
		"Ekepa", "Nuz", "Chegee", "Kusee", "Houf", "Fito", "Mog", "Urife",
		"Quib", "Zog", "Yux", "Wug", "Vij", "Thog", "Spaz", "Rix", "Quog", "Pud",
		"Nax", "Mub", "Loz", "Kiv", "Juf", "Hix", "Gub", "Faz", "Duv", "Coz",
		"Bix", "Anj", "Zin", "Yad", "Woz", "Vix", "Tuj", "Sab", "Riv", "Poz"  
		]
	return "%s %s" % [first_names[randi() % first_names.size()], last_names[randi() % last_names.size()]]

func get_random_condition():
	var conditions = ["Fresh", "Extra Eyes", "Rotten", "Sprouted", "Dehydrated", "Frozen"]
	return conditions[randi() % conditions.size()]

func get_random_sex():
	return ["Male", "Female"][randi() % 2]
	
func get_random_country():
	var countries = [
		"Spudland", "Potatopia", "Tuberstan", "North Yamnea", "Spuddington", 
		"Tatcross", "Mash Meadows", "Tuberville", "Chip Hill", 
		"Murphyland", "Colcannon", "Pratie Point"
		]
	return countries[randi() % countries.size()]
	
func get_past_date(years_ago_start: int, years_ago_end: int) -> String:
	var current_date = Time.get_date_dict_from_system()
	var year = current_date.year - years_ago_start - randi() % (years_ago_end - years_ago_start + 1)
	var month = randi() % 12 + 1
	var day = randi() % 28 + 1  # Simplified to avoid month-specific day calculations
	return "%04d.%02d.%02d" % [year, month, day]

func get_future_date(years_ahead_start: int, years_ahead_end: int) -> String:
	var current_date = Time.get_date_dict_from_system()
	var year = current_date.year + years_ahead_start + randi() % (years_ahead_end - years_ahead_start + 1)
	var month = randi() % 12 + 1
	var day = randi() % 28 + 1  # Simplified to avoid month-specific day calculations
	return "%04d.%02d.%02d" % [year, month, day]
	
func calculate_age(date_of_birth: String) -> int:
	var current_date = Time.get_date_dict_from_system()
	var birth_parts = date_of_birth.split('.')
	
	if birth_parts.size() != 3:
		print("Invalid date format: ", date_of_birth)
		return 0
	
	var birth_year = birth_parts[0].to_int()
	var birth_month = birth_parts[1].to_int()
	var birth_day = birth_parts[2].to_int()
	
	var age = current_date.year - birth_year
	
	# Adjust age if birthday hasn't occurred this year
	if current_date.month < birth_month or (current_date.month == birth_month and current_date.day < birth_day):
		age -= 1
	
	return age
	
# Update score display when global score changes
func _on_score_updated(new_score: int):
	#$UI/Labels/ScoreLabel.text = "Score: " + str(new_score)
	$UI/Labels/ScoreLabel.text = tr("ui_score").format({"score": str(new_score)})
	
func process_decision(allowed):
	print("Evaluating immigration decision in process_decision()...")
	if !current_potato_info or current_potato_info.is_empty():
		print("No potato to process.")
		return
	shift_stats.total_stamps += 1
	if allowed:
		shift_stats.potatoes_approved += 1
	else:
		shift_stats.potatoes_rejected += 1
			
   # Get validation result
	var validation = LawValidator.check_violations(current_potato_info, current_rules)
	var correct_decision = validation.is_valid
   # Update stats based on correctness of decision
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		Global.quota_met += 1
		correct_decision_streak += 1
	   # Check if quota met
		if Global.quota_met >= Global.quota_target:
			office_shutter_controller.lower_shutter(0.7)
			print("Quota complete!")
			end_shift(true) # end shift with success condition
			return # Cease processing
	   # Increase multiplier for streaks
		if correct_decision_streak >= 3:
			point_multiplier = 1.5
		if correct_decision_streak >= 5:
			point_multiplier = 2.0
	   # Award points for correct decisions
		var decision_points = 250 * point_multiplier
		var alert_text = tr("alert_correct_decision").format({"points": str(decision_points)})

		if !allowed and validation.violation_reason:
			alert_text += "\n" + tr(validation.violation_reason)
			
		Global.display_green_alert(alert_label, alert_timer, alert_text)
		Global.add_score(decision_points)
	else:
		# Decision was incorrect
		#var alert_text = "You have caused unnecessary suffering, officer..."
		var alert_text = tr("alert_wrong_decision")
		
		if allowed and !correct_decision:
			# Player approved an invalid potato
			if validation.violation_reason:
				alert_text += "\n" + tr(validation.violation_reason)
		else:
			# Player rejected a valid potato
			alert_text += "\n" + tr("alert_potato_should_be_approved")
			#alert_text += "\nThis potato meets all requirements and should have been approved."
				
		
		Global.display_red_alert(alert_label, alert_timer, alert_text)
		correct_decision_streak = 0
		point_multiplier = 1.0
		Global.strikes += 1
		if Global.strikes >= Global.max_strikes:
			#alert_text = "Maximum strikes exceeded! Your shift is over."
			alert_text = tr("alert_strike_out")
			Global.display_red_alert(alert_label, alert_timer, alert_text)
			# Lower the shuttere when max strikes reached
			office_shutter_controller.lower_shutter(0.7)  
			end_shift(false) # end shift with failure condition
			return # Cease processing
			
	update_score_display()
	update_quota_display()
	update_strikes_display()
	if queue_manager.can_add_potato() and spawn_timer.is_stopped():
		spawn_timer.start()

func update_score_display():
	#$UI/Labels/ScoreLabel.text = "Score: " + str(Global.score)
	$UI/Labels/ScoreLabel.text = tr("ui_score").format({"score": str(Global.score)})
	if point_multiplier > 1.0:
		$UI/Labels/ScoreLabel.text += " (x" + str(point_multiplier) + ")"

func update_quota_display():
	var current_quota = Global.quota_met
	var quota_label = $UI/Labels/QuotaLabel
	
	# Ensure shift is at least 1 for calculation purposes, such as in shift 0 for tutorial
	# Update the text
	# quota_label.text = "Quota: " + str(current_quota) + " / " + str(Global.quota_target)
	
	# Update the text with translation
	quota_label.text = tr("ui_quota").format({
		"current": str(current_quota),
		"target": str(Global.quota_target)
	})
	
	# Check if there's a change OR if this is the first update (previous_quota is -1)
	if previous_quota != current_quota && previous_quota != -1:
		var tween = create_tween()
		
		if current_quota > previous_quota:
			# Positive change - bounce up animation
			tween.tween_property(quota_label, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(quota_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			
			# Optional: Change color briefly to green
			tween.parallel().tween_property(quota_label, "modulate", Color(0.5, 1.0, 0.5, 1.0), 0.1)
			tween.tween_property(quota_label, "modulate", Color(1.0, 0.782051, 0.655081, 1.0), 0.3)
		else:
			# Negative change - shake animation
			var original_pos = quota_label.position
			var shake_strength = 5.0
			
			# Series of position offsets to create shake effect
			tween.tween_property(quota_label, "position", original_pos + Vector2(-shake_strength, 0), 0.05)
			tween.tween_property(quota_label, "position", original_pos + Vector2(shake_strength, 0), 0.05)
			tween.tween_property(quota_label, "position", original_pos + Vector2(0, -shake_strength), 0.05)
			tween.tween_property(quota_label, "position", original_pos + Vector2(0, shake_strength), 0.05)
			tween.tween_property(quota_label, "position", original_pos, 0.05)
			
			# Change color briefly to red
			tween.parallel().tween_property(quota_label, "modulate", Color(1.0, 0.4, 0.4, 1.0), 0.1)
			tween.tween_property(quota_label, "modulate", Color(1.0, 0.782051, 0.655081, 1.0), 0.3)
	
	# Update previous quota for next comparison
	previous_quota = current_quota

func update_strikes_display():
	var current_strikes = Global.strikes
	var strikes_label = $UI/Labels/StrikesLabel
	
	# Update the text
	# strikes_label.text = "Strikes: " + str(current_strikes) + " / " + str(Global.max_strikes)
	
	# Update the text with translation
	strikes_label.text = tr("ui_strikes").format({
		"current": current_strikes, 
		"max": Global.max_strikes
	})
	# Check if there's a change OR if this is the first update (previous_strikes is -1)
	if previous_strikes != current_strikes && previous_strikes != -1:
		var tween = create_tween()
		
		if current_strikes > previous_strikes:
			# Strikes increased - negative shake animation
			var original_pos = strikes_label.position
			var shake_strength = 5.0
			
			# More intense shake for strikes
			tween.tween_property(strikes_label, "position", original_pos + Vector2(-shake_strength, -shake_strength), 0.05)
			tween.tween_property(strikes_label, "position", original_pos + Vector2(shake_strength, shake_strength), 0.05)
			tween.tween_property(strikes_label, "position", original_pos + Vector2(-shake_strength, shake_strength), 0.05)
			tween.tween_property(strikes_label, "position", original_pos + Vector2(shake_strength, -shake_strength), 0.05)
			tween.tween_property(strikes_label, "position", original_pos, 0.05)
			
			# Change color briefly to red
			tween.parallel().tween_property(strikes_label, "modulate", Color(1.0, 0.3, 0.3, 1.0), 0.1)
			tween.tween_property(strikes_label, "modulate", Color(1.0, 0.782051, 0.655081, 1.0), 0.3)
		else:
			# Strikes decreased - positive bounce animation
			tween.tween_property(strikes_label, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(strikes_label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			
			# Change color briefly to green
			tween.parallel().tween_property(strikes_label, "modulate", Color(0.5, 1.0, 0.5, 1.0), 0.1)
			tween.tween_property(strikes_label, "modulate", Color(1.0, 0.782051, 0.655081, 1.0), 0.3)
	
	# Update previous strikes for next comparison
	previous_strikes = current_strikes

func update_potato_texture():
	print("Updating potato textures with character generator")
	
	if current_potato_info == null or current_potato_info.is_empty():
		print("No valid potato info available")
		clear_potato_textures()
		return
	
	if !mugshot_generator or !passport_generator:
		print("ERROR: Character generators not found!")
		return
	
	# Use the correct race from potato_info
	var race = current_potato_info.race if current_potato_info.has("race") else "Russet"
	var sex = current_potato_info.sex if current_potato_info.has("sex") else "Male"
	
	# Set race and sex explicitly first
	mugshot_generator.set_race(race)
	mugshot_generator.set_sex(sex)
	passport_generator.set_race(race)
	passport_generator.set_sex(sex)
	
	# Then apply character data
	if current_potato_info.has("character_data"):
		# Don't let character data override the race and sex
		var character_data = current_potato_info.character_data.duplicate()
		character_data.race = race
		character_data.sex = sex
		
		mugshot_generator.set_character_data(character_data)
		passport_generator.set_character_data(character_data)
	else:
		print("WARNING: No character data found in potato_info!")
		
	print("Character display updated")

func clear_potato_textures():
	if mugshot_generator:
		# Reset to default state or hide
		mugshot_generator.set_sex("Male")  # Reset to default gender
		
	if passport_generator:
		# Reset to default state or hide
		passport_generator.set_sex("Male")  # Reset to default gender
	
func _input(event: InputEvent):
	# If game is paused or dialogue is active, don't process input
	if is_game_paused:
		return
		
	# Let the drag and drop manager handle drag events first
	if drag_and_drop_manager.handle_input(event):
		return
		

func remove_stamp():
	# Get the decision directly from the stamp system manager
	var decision = stamp_system_manager.process_passport_decision()
	
	if decision == "":
		print("DEBUG: No stamps found - aborting passport processing")
		return
		
	print("DEBUG: Processing passport with status:", decision)
	
	# Animate the potato mugshot and passport exit
	var mugshot_generator = $Gameplay/MugshotPhotoGenerator
	var passport = $Gameplay/InteractiveElements/Passport
	var suspect_panel_spawn_node = $Gameplay/InteractiveElements/SuspectSpawnNode
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Detemine which side the Spud should exit the Customs Office from
	if (decision == "approved"):
		# The left side if they are approved by the User
		tween.tween_property(mugshot_generator, "position:x", suspect_panel_spawn_node.position.x - suspect_panel_front.texture.get_width(), 0.7)
	else:
		# The right side if they are rejected by the User
		tween.tween_property(mugshot_generator, "position:x", suspect_panel_spawn_node.position.x + suspect_panel_front.texture.get_width(), 0.7)
		
	tween.tween_property(mugshot_generator, "modulate:a", 0, 0.7)
	tween.tween_property(passport, "modulate:a", 0, 0.7)
	# OPTIONAL: Lower the gate as the potato leaves
	#office_gate_controller.lower_gate(1.0)
	tween.chain().tween_callback(func(): 
		# Process the decision using the main game logic
		process_decision(decision == "approved")
		# Update quota display
		update_quota_display()
		move_potato_along_path(decision)
		is_potato_in_office = false
	)
	
func move_potato_along_path(approval_status):
	if current_potato_info == null:
		print("Error: No potato info available")
		return
		
	# Create a new potato with the current info
	var potato = PotatoFactory.create_potato_with_info(current_potato_info)
	add_child(potato)
	
	# Determine the appropriate path based on approval status
	var path = get_appropriate_path(approval_status)
	if path:
		# Set state based on approval status
		if approval_status == "approved":
			potato.set_state(potato.TaterState.APPROVED)		
			# For normal approved paths, use base speed
			potato.regular_path_speed = regular_potato_speed
		else:
			potato.set_state(potato.TaterState.REJECTED)
			potato.regular_path_speed = regular_potato_speed * 0.7
			# Check for border runner chance
			if approval_status == "rejected" and randf() < 0.15:
				if border_runner_system:
					# Instead of using path, hand over to border runner system
					border_runner_system.start_runner(potato, true)
					return

		
		# Attach to the selected path
		potato.attach_to_path(path)
		
		# Connect to path_completed signal
		potato.path_completed.connect(func():
			# When path is complete, we'll fade out and clean up
			potato.fade_out()
			# Reset the label for new scene
			$UI/Labels/JudgementLabel.text = ""
		)
	else:
		# No path found, just clean up
		potato.queue_free()
		print("No path found for approval status: ", approval_status)
		

# Helper function to get appropriate path
func get_appropriate_path(approval_status: String) -> Path2D:
	var paths_node
	var available_paths = []
	
	if approval_status == "approved":
		paths_node = $Gameplay/Paths/ApprovePaths
		# Collect all valid approve paths
		for child in paths_node.get_children():
			if child.name.begins_with("ApprovePath"):
				available_paths.append(child)
	else:
		paths_node = $Gameplay/Paths/RejectionPaths
		# Collect all valid reject paths
		for child in paths_node.get_children():
			if child.name.begins_with("RejectPath"):
				available_paths.append(child)
	
	if available_paths.is_empty():
		push_error("No " + approval_status + " paths found!")
		return null
		
	# Randomly select a path
	return available_paths[randi() % available_paths.size()]

func fade_out_group_elements():
	# Get all corpses and footprints
	var corpses = get_tree().get_nodes_in_group("CorpseGroup")
	var footprints = get_tree().get_nodes_in_group("FootprintGroup")
	
	# Fade out each corpse
	for corpse in corpses:
		if is_instance_valid(corpse):
			# Force immediate alpha change to ensure visibility
			corpse.modulate.a = 0.8
			
			var tween = create_tween()
			tween.tween_property(corpse, "modulate:a", 0.0, 2)
			tween.tween_callback(func():
				if is_instance_valid(corpse):
					corpse.queue_free()
			)
	
	# Fade out each footprint
	for footprint in footprints:
		if is_instance_valid(footprint):
			# Force immediate alpha change to ensure visibility
			footprint.modulate.a = 0.8
			
			var tween = create_tween()
			tween.tween_property(footprint, "modulate:a", 0.0, 2)
			tween.tween_callback(func(): 
				if is_instance_valid(footprint):
					footprint.queue_free()
			)

func _exit_tree():
	# Ensure cursor is restored when leaving the scene
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_dialogue_started():
	safety_unpause_timer.start()
	bgm_player.stop()
	# Completely pause all game systems
	is_game_paused = true
	# get_tree().paused = true
	# Tell the border runner system to pause with dialogic mode
	if border_runner_system:
		border_runner_system.set_dialogic_mode(true)
	disable_controls()
	border_runner_system.is_enabled = false
	
func _on_dialogue_finished():
	Dialogic.Audio.stop_all_channels()
	Dialogic.Audio.stop_all_one_shot_sounds()
	next_track_with_random_pitch()
	Global.quota_met = 0
	Global.strikes = 0
	# Completely unpause all game systems
	# get_tree().paused = false
	is_game_paused = false
	# Tell the border runner system dialogic mode is done
	if border_runner_system:
		border_runner_system.set_dialogic_mode(false)
	border_runner_system.is_enabled = true
	enable_controls()
	
	var skip_buttons = get_tree().get_nodes_in_group("DialogueSkipButtons")
	for button_layer in skip_buttons:
		if is_instance_valid(button_layer):
			button_layer.queue_free()
			
	if Global.current_story_state >= 10:
		# Game complete, show credits or return to menu
		get_tree().change_scene_to_file("res://scenes/end_credits/end_credits.tscn")
		print("ERROR: _on_dialogue_finished called StoryState.COMPLETED but no scene loaded")

func disable_controls():
	# Disable player interaction during dialogue
	print("disabling controls")
	set_process_input(false)
	border_runner_system.is_enabled = false
	
	# Disable border runner system and set spawn chance to 0
	if border_runner_system:
		border_runner_system.disable()
		border_runner_system.runner_chance = 0.0
	# Stop all timers and queues
	$SystemManagers/Timers/SpawnTimer.stop()

	# Disable UI hints
	if ui_hint_system:
		ui_hint_system.set_all_hints_enabled(false)

func enable_controls():
	# Re-enable controls after dialogue
	print("enabling controls")
	set_process_input(true)
	border_runner_system.is_enabled = true
	# Re-enable border runner system and restore original spawn chance
	if border_runner_system:
		border_runner_system.enable()
		border_runner_system.runner_chance = original_runner_chance
	# Stop all timers and queues
	$SystemManagers/Timers/SpawnTimer.start()
	# Enable UI hints
	if ui_hint_system:
		ui_hint_system.set_all_hints_enabled(true)
	
		
func _on_intro_dialogue_finished():
	# Enable all game systems
	enable_controls()
	is_game_paused = false
	
	# Make sure quota and strikes are reset
	Global.quota_met = 0
	Global.strikes = 0
	
	# Start the actual gameplay
	spawn_timer.start()
	
	# Update UI
	update_quota_display()
	update_strikes_display()

func _on_end_dialogue_finished():
	# This is called after an end dialogue completes
	
	# Special case for final confrontation (shift 10)
	if current_shift == 10:
		# Final confrontation just finished, go to credits
		fade_transition()
		if SceneLoader:
			SceneLoader.load_scene("res://scenes/end_credits/end_credits.tscn")
		else:
			push_error("SceneLoader not found, falling back to change_scene_to_file")
			get_tree().change_scene_to_file("res://scenes/end_credits/end_credits.tscn")
		return
	
	# For other shifts
	if current_shift >= 10:
		# Game complete, show credits
		fade_transition()
		if SceneLoader:
			SceneLoader.load_scene("res://scenes/end_credits/end_credits.tscn")
		else:
			push_error("SceneLoader not found, falling back to change_scene_to_file")
			get_tree().change_scene_to_file("res://scenes/end_credits/end_credits.tscn")
	else:
		# Continue to next shift
		#narrative_manager.show_day_transition(current_shift, current_shift + 1)
		#await narrative_manager.dialogue_finished
		
		# Load the next shift
		#current_shift += 1
		#fade_transition()
		#if SceneLoader:
		#	SceneLoader.reload_current_scene()
		#else:
		#	push_error("SceneLoader not found, falling back to change_scene_to_file")
		#	get_tree().change_scene_to_file("res://scenes/game_scene/mainGame.tscn")
		pass

func _on_game_over():
	# Disable all inputs and systems first
	set_process_input(false)
	if border_runner_system:
		border_runner_system.disable()
	
	# Capture time taken
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - game_start_time
	
	# Get border runner statistics
	var runner_stats = border_runner_system.shift_stats
	
	# Populate the ShiftStats object
	shift_stats.time_taken = elapsed_time
	shift_stats.missiles_fired = runner_stats.missiles_fired
	shift_stats.missiles_hit = runner_stats.missiles_hit
	shift_stats.perfect_hits = runner_stats.perfect_hits
	
	# Create a visual feedback before ending
	var flash_rect = ColorRect.new()
	flash_rect.color = Color(1, 0, 0, 0)
	flash_rect.size = get_viewport_rect().size
	flash_rect.z_index = 999
	add_child(flash_rect)
	
	# Red flash and screen shake for impact
	var flash_tween = create_tween()
	flash_tween.tween_property(flash_rect, "color", Color(1, 0, 0, 0.3), 0.2)
	flash_tween.tween_property(flash_rect, "color", Color(1, 0, 0, 0), 0.3)
	
	# Play a failure sound if available
	if $SystemManagers/AudioManager/SFXPool:
		var failure_sound = load("res://assets/audio/mechanical/button pressed 1.wav")
		if failure_sound:
			$SystemManagers/AudioManager/SFXPool.stream = failure_sound
			$SystemManagers/AudioManager/SFXPool.play()
	
	# Small delay for dramatic effect
	await get_tree().create_timer(0.5).timeout
	
	# Lower shutter if not already lowered
	office_shutter_controller.lower_shutter(0.8)
	
	# Small delay for shutter animation
	await get_tree().create_timer(0.8).timeout
	
	# After updating all stats but before showing the summary screen
	GlobalState.save()
	
	# This will handle storing stats and showing the summary screen
	end_shift(false) # false = not a success scenario
	
# Screen shake with configurable intensity and duration
# Mild: intensity 3-5, duration 0.2
# Medium: intensity 10-15, duration 0.3
# Strong: intensity 20-25, duration 0.4
func shake_screen(intensity: float = 10.0, duration: float = 0.3):
	Global.shake_screen(intensity, duration)

func parse_date(date_string: String) -> Dictionary:
	var parts = date_string.split(".")
	if parts.size() != 3:
		push_error("Invalid date format: " + date_string)
		return {}
	
	return {
		"year": parts[0].to_int(),
		"month": parts[1].to_int(),
		"day": parts[2].to_int()
	}

# Function to check if a date is before current date
func is_expired(expiration_date: String) -> bool:
	var current_date = Time.get_date_dict_from_system()
	var expiry_date = parse_date(expiration_date)
	
	# Compare years first
	if expiry_date.year < current_date.year:
		return true
	elif expiry_date.year > current_date.year:
		return false
		
	# Same year, check months
	if expiry_date.month < current_date.month:
		return true
	elif expiry_date.month > current_date.month:
		return false
		
	# Same year and month, check days
	return expiry_date.day < current_date.day

func load_tracks():
	# Replace with your actual music tracks
	bgm_tracks = [
	"res://assets/music/ambient_vol2_concern_main.mp3",
	"res://assets/music/ambient_vol2_glorious_main.mp3",
	"res://assets/music/ambient_vol2_low_action_main.mp3",
	"res://assets/music/ambient_vol2_lush_main.mp3",
	"res://assets/music/ambient_vol2_mysterious_main.mp3",
	"res://assets/music/ambient_vol2_suspense_main.mp3",
	"res://assets/music/ambient_vol3_defeat_main.mp3",
	"res://assets/music/ambient_vol3_evil_suspense_main.mp3",
	"res://assets/music/ambient_vol3_peace_main.mp3",
	"res://assets/music/ambient_vol3_sad_decisions_main.mp3",
	"res://assets/music/ambient_vol3_spirits_intensity_2.mp3",
	"res://assets/music/ambient_vol3_spirits_main.mp3",
	"res://assets/music/ambient_vol3_wonder_main.mp3",
	"res://assets/music/ambient_wonderful_main.mp3",
	"res://assets/music/horror_fog_main.mp3",
	"res://assets/music/opening_wonderlust_intensity.wav"
	]

func play_with_pitch_variation(interval_name: String = "original"):
	# Default to original if invalid interval name provided
	if !musical_intervals.has(interval_name):
		interval_name = "original"
		
	var pitch = musical_intervals[interval_name]
	
	# Apply pitch shift
	bgm_player.pitch_scale = pitch
	
	# Adjust volume to maintain perceived loudness (optional)
	bgm_player.volume_db = -3 * log(pitch) / log(2)
	
	# If not already playing, start playback
	if !bgm_player.playing:
		play_current_track()
	
	print("Music initiated: Interval [", interval_name.to_upper(), "] / Pitch [", pitch, "]")

func play_random_pitch_variation():
	# Select a random interval
	var keys = musical_intervals.keys()
	var random_interval = keys[randi() % keys.size()]
	play_with_pitch_variation(random_interval)
	
func next_track_with_random_pitch():
	# Move to next track
	current_track_index = (current_track_index + 1) % bgm_tracks.size()
	
	# Play with random pitch variation
	play_random_pitch_variation()

func play_current_track():
	if bgm_tracks.size() > 0:
		var track = load(bgm_tracks[current_track_index])
		if track:
			bgm_player.stream = track
			bgm_player.play()
			print("Now playing: ", bgm_tracks[current_track_index])
		else:
			print("Failed to load track: ", bgm_tracks[current_track_index])

func fade_transition():
	# Create a tween for a cleaner fade transition
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport_rect().size
	fade_rect.z_index = 100  # Ensure it's above everything
	add_child(fade_rect)
	
	# Fade out animation
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.5)
	
	
func check_demo_limit() -> bool:
	# Check if this is a demo build and if the player has reached the limit
	if Global.build_type == "Demo Release" and Global.shift >= 3:
		return true
	return false
	
func show_demo_limit_dialog():
	# Create a panel to display the message
	var demo_panel = PanelContainer.new()
	demo_panel.z_index = 100
	
	var vbox = VBoxContainer.new()
	vbox.set_custom_minimum_size(Vector2(500, 300))
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var title = Label.new()
	title.text = "Demo Version Limit Reached"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	
	var message = RichTextLabel.new()
	message.bbcode_enabled = true
	message.text = """
	[center]Thank you for playing the demo version of Spud Customs!

	You've reached the limit of the demo version.
	
	To continue your journey as a customs officer and experience the full story...
	
	Please purchase the full game, and leave a review!
	
	[url=https://store.steampowered.com/app/3291880/]Buy Spud Customs on Steam[/url][/center]
	"""
	message.fit_content = true
	message.custom_minimum_size = Vector2(450, 200)
	message.meta_clicked.connect(func(meta): OS.shell_open(meta))
	
	var button = Button.new()
	button.text = "Return to Main Menu"
	button.custom_minimum_size = Vector2(200, 50)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	vbox.add_child(title)
	vbox.add_child(message)
	vbox.add_child(button)
	
	demo_panel.add_child(vbox)
	add_child(demo_panel)
	
	# Center the panel
	demo_panel.position = (get_viewport_rect().size - demo_panel.size) / 2
	
	# Connect button to return to main menu
	button.pressed.connect(func():
		# Return to main menu
		get_tree().change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
		# Remove the panel
		demo_panel.queue_free()
	)
	
	# Add a nice animation
	demo_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(demo_panel, "modulate:a", 1.0, 0.5)
