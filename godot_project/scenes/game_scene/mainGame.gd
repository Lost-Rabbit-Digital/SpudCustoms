extends Node2D

var border_runner_system
var regular_potato_speed = 0.5

# Track game states
var is_game_paused: bool = false
var close_sound_played: bool = false
var open_sound_played: bool = false
var is_potato_in_office: bool = false
var game_start_time: float = 0.0
var is_shift_ending: bool = false  # Guard to prevent end_shift() from running twice

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

# Minigame triggers
var _minigames_triggered_this_shift: int = 0
var _consecutive_perfect_stamps: int = 0
const STREAK_MINIGAME_THRESHOLD: int = 5
const STREAK_MINIGAME_CHANCE: float = 0.4  # 40% chance at milestone
const PERFECT_STAMP_MINIGAME_THRESHOLD: int = 3
const PERFECT_STAMP_MINIGAME_CHANCE: float = 0.5  # 50% chance after 3 perfect stamps

# Narrative-only shifts: These shifts skip regular potato processing gameplay
# and go directly from intro dialogue to end dialogue (climactic story moments)
const NARRATIVE_ONLY_SHIFTS: Array[int] = [9, 10]


## Returns the maximum number of minigames allowed for the current shift.
## Scales with game progression: early shifts get fewer, later shifts get more.
func _get_max_minigames_for_shift() -> int:
	var current_shift: int = Global.shift
	if current_shift <= 3:
		return 1  # Early game: 1 minigame max
	elif current_shift <= 6:
		return 2  # Mid game: 2 minigames max
	else:
		return 3  # Late game (shifts 7-10): 3 minigames max


## Check if more minigames can be triggered this shift
func _can_trigger_minigame() -> bool:
	return _minigames_triggered_this_shift < _get_max_minigames_for_shift()

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
	"original": 1.0,  # Original pitch
	"major_third_down": 0.8,  # More somber
	"major_third_up": 1.25,  # Brighter feel
	"fifth_down": 0.67,  # Much darker
	"fifth_up": 1.5  # Brighter, heroic
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
@onready
var passport_generator = $Gameplay/InteractiveElements/Passport/OpenPassport/PassportPhotoGenerator

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

# Minigame launcher for bonus activities
var minigame_launcher: MinigameLauncher

# Office Shutter Controller
@onready
var office_shutter_controller: OfficeShutterController = $Gameplay/InteractiveElements/OfficeShutterController

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

	# Track shift start
	# REFACTORED: Use GameStateManager
	var shift_num = GameStateManager.get_shift()
	Analytics.track_shift_started(shift_num)


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

	# Initialize minigame launcher
	minigame_launcher = MinigameLauncher.new()
	minigame_launcher.name = "MinigameLauncher"
	$SystemManagers.add_child(minigame_launcher)

	# Get essential system references
	queue_manager = %QueueManager
	border_runner_system = %BorderRunnerSystem
	border_runner_system.minigame_launcher = minigame_launcher
	original_runner_chance = border_runner_system.runner_chance

	# Disable border runners immediately for tutorial shift
	var is_tutorial = GameStateManager.is_tutorial_mode() if GameStateManager else false
	var shift_num = GameStateManager.get_shift() if GameStateManager else 0
	if shift_num == 0 or is_tutorial:
		border_runner_system.is_enabled = false
		border_runner_system.runner_chance = 0.0


func _setup_game_state():
	# Initialize game state and stats
	# REFACTORED: Use GameStateManager
	current_shift = GameStateManager.get_shift()
	# Global.shift = current_shift  # REMOVED: GameStateManager is source of truth

	shift_stats = stats_manager.get_new_stats()
	game_start_time = Time.get_ticks_msec() / 1000.0

	# Load difficulty settings
	# REFACTORED: Use GameStateManager
	difficulty_level = GameStateManager.get_difficulty()
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
	update_date_display()
	# TODO: update_combo_display()

	# Display high score if available
	_check_and_display_high_score()

	# Set UI element references
	_setup_ui_references()


func _register_ui_hints():
	ui_hint_system.register_hintable(
		$Gameplay/InteractiveElements/Passport/ClosedPassport, "passport", 15.0
	)
	ui_hint_system.register_hintable(megaphone, "megaphone", 15.0)
	ui_hint_system.register_hintable(
		$Gameplay/InteractiveElements/StampBarController, "stamp_bar", 15.0
	)


func _check_and_display_high_score():
	var high_score = GameState.get_high_score(current_shift)
	if high_score > 0:
		# REFACTORED: Use EventBus for alerts
		EventBus.show_alert("High score for this level: " + str(high_score), true)

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
	border_runner_system.game_over_triggered.connect(_on_game_over)

	# Megaphone hover sound
	var megaphone_button = megaphone.get_node_or_null("MegaphoneInteractionButton")
	if megaphone_button:
		megaphone_button.mouse_entered.connect(_on_megaphone_hover)

	# EventBus signals - REFACTORED to use EventBus instead of Global
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.strike_changed.connect(_on_strike_changed)
	EventBus.strike_removed.connect(_on_strike_removed)
	EventBus.quota_updated.connect(_on_quota_updated)
	EventBus.minigame_bonus_requested.connect(_on_minigame_bonus_requested)
	EventBus.minigame_from_runner_requested.connect(_on_minigame_from_runner_requested)
	EventBus.runner_escaped.connect(_on_runner_escaped)
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)
	EventBus.high_score_achieved.connect(_on_high_score_achieved)

	# UI feedback signals
	EventBus.alert_green_requested.connect(_on_alert_green_requested)
	EventBus.alert_red_requested.connect(_on_alert_red_requested)
	EventBus.screen_shake_requested.connect(_on_screen_shake_requested)

	# Game flow signals
	EventBus.game_over_triggered.connect(_on_eventbus_game_over)
	EventBus.max_strikes_reached.connect(_on_max_strikes_reached)

	# UI signals
	ui_hint_system.hint_deactivated.connect(_on_hint_deactivated)

	# Dialogic signals
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_finished)


func _setup_gameplay_systems():
	# Disable border runner system initially - it will be enabled after intro dialogue
	# This prevents missiles from being fired during cutscenes at game start
	border_runner_system.is_enabled = false
	if border_runner_system:
		border_runner_system.set_dialogic_mode(true)

	# Setup ambient audio
	_setup_ambient_audio()


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
		if not stamp_bar_controller.stamp_selected.is_connected(
			stamp_system_manager.stamp_system.on_stamp_requested
		):
			stamp_bar_controller.stamp_selected.connect(
				stamp_system_manager.stamp_system.on_stamp_requested
			)
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
		var stamp_area = Rect2(passport_node.global_position + Vector2(120, 120), Vector2(160, 80))  # Adjust based on your layout  # Adjust based on desired stamp area size

		# Get reference to the stamp system from the manager
		var stamp_system = stamp_system_manager.stamp_system
		if stamp_system:
			# Register the passport with the stamp system
			stamp_system_manager.passport_stampable = stamp_system.register_stampable(
				passport_node, open_passport_node, stamp_area
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

	# Track consecutive perfect stamps for minigame trigger
	if is_perfect:
		_consecutive_perfect_stamps += 1
		_try_trigger_perfect_stamp_minigame()
	else:
		_consecutive_perfect_stamps = 0


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
		# REFACTORED: Use EventBus for alerts
		EventBus.show_alert(combo_text, true, 1.5)

	return multiplier


func reset_combo():
	if combo_count > 1:
		# REFACTORED: Use EventBus for alerts
		EventBus.show_alert("Combo Broken!", false, 1.5)
	combo_count = 0
	combo_timer = 0.0


func award_points(base_points: int):
	var multiplier = add_to_combo()
	var total_points = base_points * multiplier
	# REFACTORED: Use EventBus for score addition
	EventBus.request_score_add(total_points, "gameplay_action", {
		"base_points": base_points,
		"multiplier": multiplier,
		"combo_count": combo_count
	})
	return total_points


func end_shift(success: bool = true):
	# Guard to prevent end_shift from running twice (can happen when max strikes triggers both
	# direct call from process_decision and EventBus game_over_triggered signal)
	if is_shift_ending:
		LogManager.write_info("end_shift called but already ending, skipping duplicate call")
		return
	is_shift_ending = true

	# First check if we've hit the demo limit
	if Global.build_type == "Demo" and Global.shift >= 2 and success:
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

	# Hide the stamp bar with animation
	var stamp_bar_controller = $Gameplay/InteractiveElements/StampBarController
	if stamp_bar_controller:
		stamp_bar_controller.force_hide()

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
	shift_stats.hit_rate = (
		0.0
		if shift_stats.missiles_fired == 0
		else (float(shift_stats.missiles_hit) / shift_stats.missiles_fired * 100.0)
	)

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
		# REFACTORED: Use EventBus for alerts
		EventBus.show_alert(tr("alert_quota_met").format({"bonus": str(survival_bonus)}), true)
		# REFACTORED: Use EventBus for survival bonus
		EventBus.request_score_add(survival_bonus, "survival_bonus", {
			"shift": Global.shift,
			"quota_met": Global.quota_met
		})

		# Lower the shutter with animation when successful
		if not office_shutter_controller.shutter_opened_this_shift:
			office_shutter_controller.lower_shutter(1.0)

		# REFACTORED: Use GameStateManager
		var current_shift_val = GameStateManager.get_shift()
		var current_score = GameStateManager.get_score()
		Analytics.track_shift_completed(current_shift_val, success, current_score)

		# Increment total shifts completed for achievements
		Global.total_shifts_completed += 1
		print("Total shifts completed: ", Global.total_shifts_completed)

		# Check and update achievements
		Global.check_achievements()
		Global.update_steam_stats()

		# Setting high score for current level and difficulty
		print(
			"Setting high score of: ",
			Global.score,
			" for : ",
			current_shift,
			" and difficulty level",
			difficulty_level
		)
		# REFACTORED: Use GameStateManager
		var diff_level = GameStateManager.get_difficulty()
		var score_val = GameStateManager.get_score()
		GameState.set_high_score(current_shift, diff_level, score_val)

		# Increment total shifts completed for achievements
		Global.total_shifts_completed += 1

		# Check and update achievements
		Global.check_achievements()
		Global.update_steam_stats()

	GlobalState.save()

	# Update quota display one last time to ensure it's correct
	update_quota_display()

	# Update strike display
	update_strikes_display()

	# Update shift_stats with shift_number before ending shift
	# REFACTORED: Use GameStateManager
	shift_stats.shift_number = GameStateManager.get_shift()

	# calculate end of shift bonuses
	shift_stats.processing_speed_bonus = shift_stats.get_speed_bonus()
	shift_stats.accuracy_bonus = shift_stats.get_accuracy_bonus()
	shift_stats.perfect_hit_bonus = shift_stats.get_missile_bonus()

	# Add bonuses to Score
	# REFACTORED: Use GameStateManager
	var current_score = GameStateManager.get_score()
	shift_stats.final_score = current_score + shift_stats.get_total_bonus()

	# Store game stats
	# REFACTORED: Moved to after stats_dict creation and using GameStateManager
	# Global.store_game_stats(shift_stats)

	# Convert ShiftStats to a dictionary
	var stats_dict = {
		"shift": GameStateManager.get_shift(),
		"time_taken": shift_stats.time_taken,
		"processing_time_left": shift_stats.processing_time_left,
		"score": GameStateManager.get_score(),
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
		"quota_met": GameStateManager.get_quota_met(),
		"quota_target": GameStateManager.get_quota_target(),
		"strikes": GameStateManager.get_strikes(),
		"max_strikes": GameStateManager.get_max_strikes(),
		"success": success
	}

	# REFACTORED: Store stats in GameStateManager
	if GameStateManager:
		GameStateManager.set_last_game_stats(stats_dict)

	# After updating all stats but before showing the summary screen
	GlobalState.save()

	# Before starting end dialogue, ensure we're in a state that allows dialogue to run
	get_tree().paused = false  # Temporarily unpause
	is_game_paused = false  # Clear the game pause flag
	# Add to end_shift function:
	print("Ending shift ", current_shift, " with success: ", success)
	print("Tree paused state: ", get_tree().paused)
	print("Game paused state: ", is_game_paused)
	# Check if there's an end dialogue for this shift - only show on successful completion
	# When the player fails (strikes out), skip the post-shift cutscene and go directly to summary
	if success and narrative_manager and narrative_manager.LEVEL_END_DIALOGUES.has(current_shift):
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
	elif not success:
		print("Shift failed - skipping end dialogue and going to summary screen")

	# Show the summary screen (always shown, whether success or failure)
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

	tween.tween_callback(
		func():
			# Play the motion sound for the shift summary screen descending
			if $SystemManagers/AudioManager/SFXPool:
				var motion_sound = load("res://assets/audio/ui_feedback/motion_straight_air.wav")
				if motion_sound:
					$SystemManagers/AudioManager/SFXPool.stream = motion_sound
					$SystemManagers/AudioManager/SFXPool.play()
				else:
					push_warning("Failed to load motion_straight_air.wav sound")
	)

	tween.tween_callback(
		func():
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
	if Global.build_type == "Demo" and completed_shift >= 2:
		# Show demo limit message
		show_demo_limit_dialog()
		return

	# IMPORTANT: Check if this is the final shift - go to credits instead of continuing
	# Shift 10 is the final day, there is no shift 11+
	const FINAL_SHIFT: int = 10
	if completed_shift >= FINAL_SHIFT:
		print("Completed final shift %d - going to credits" % completed_shift)
		get_tree().change_scene_to_file("res://scenes/end_credits/end_credits.tscn")
		return

	# Save high score for the current level
	# REFACTORED: Use GameStateManager
	var diff_level = GameStateManager.get_difficulty() if GameStateManager else Global.difficulty_level
	var score_val = GameStateManager.get_score() if GameStateManager else Global.score
	GameState.set_high_score(completed_shift, diff_level, score_val)

	# Check if a new minigame will be unlocked in the next shift
	# Store it in GameStateManager so it can be shown after the next shift starts
	var next_shift = completed_shift + 1
	var newly_unlocked = _get_newly_unlocked_minigame(next_shift)
	if newly_unlocked != "" and GameStateManager:
		# Store the unlock notification to show after next shift starts
		GameStateManager.set_pending_minigame_unlock(newly_unlocked)

	# Advance the shift and story state
	# REFACTORED: Use EventBus requests instead of direct calls
	EventBus.shift_advance_requested.emit()
	EventBus.story_state_advance_requested.emit()

	# Get the new shift value after advancement
	var new_shift = GameStateManager.get_shift() if GameStateManager else Global.shift
	print("Shift advanced from %d to %d" % [completed_shift, new_shift])

	# Make sure GameState is updated with our progress
	GameState.level_reached(new_shift)

	# Force save to persist the advanced shift
	GlobalState.save()

	# Show day transition with correct shift numbers and wait for it to complete
	narrative_manager.show_day_transition(completed_shift, new_shift)

	# Wait for the transition animation to complete
	await narrative_manager.dialogue_finished

	# Reload the game scene for the next shift
	if SceneLoader:
		print("Using SceneLoader to reload for shift %d" % new_shift)
		SceneLoader.reload_current_scene()
	else:
		push_error("SceneLoader not found, falling back to change_scene_to_file")
		get_tree().change_scene_to_file("res://scenes/game_scene/mainGame.tscn")


## Get the minigame that unlocks at a specific shift (if any)
func _get_newly_unlocked_minigame(shift: int) -> String:
	if not minigame_launcher:
		return ""

	for minigame_type in MinigameLauncher.MINIGAME_UNLOCK_SHIFTS.keys():
		if MinigameLauncher.MINIGAME_UNLOCK_SHIFTS[minigame_type] == shift:
			return minigame_type
	return ""


func _on_shift_summary_restart():
	# Keep the same shift but reset the stats
	# Keep the same shift but reset the stats
	# REFACTORED: Use EventBus requests
	EventBus.reset_shift_requested.emit()
	EventBus.reset_game_requested.emit()
	GlobalState.save()
	if SceneLoader:
		SceneLoader.reload_current_scene()
	else:
		push_error("SceneLoader not found, falling back to change_scene_to_file")
		get_tree().change_scene_to_file("res://scenes/game_scene/mainGame.tscn")


func _on_shift_summary_main_menu():
	# Save state before transitioning to main menu
	GlobalState.save()

	# FIXED: End Dialogic timeline cleanly before scene change
	# This prevents Dialogic's _on_dialogic_timeline_ended from clearing all audio
	# when the scene is destroyed
	if Dialogic.current_timeline:
		# Stop only dialogue sounds, preserve background music
		Dialogic.Audio.stop_all_one_shot_sounds()
		# End the timeline cleanly - this triggers cleanup in a controlled way
		Dialogic.end_timeline()

	fade_transition()
	# Access SceneLoader directly
	push_warning("Using direct change_scene_to_file, SceneLoader not working as expected.")
	get_tree().change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")


func set_difficulty(level):
	difficulty_level = level

	# REFACTORED: Use GameStateManager for difficulty logic
	if GameStateManager:
		GameStateManager.set_difficulty(level)
	else:
		# Fallback logic
		match difficulty_level:
			"Easy":
				Global.max_strikes = 6
			"Normal":
				Global.max_strikes = 4
			"Expert":
				Global.max_strikes = 3

	# Set local variables based on difficulty
	match difficulty_level:
		"Easy":
			regular_potato_speed = 0.4
		"Normal":
			regular_potato_speed = 0.5
		"Expert":
			regular_potato_speed = 0.6

	update_quota_display()
	update_strikes_display()


func generate_rules():
	var all_rules = LawValidator.LAW_CHECKS.keys()
	var num_rules = _calculate_rules_for_shift()

	# Progressive complexity based on shift number
	var available_rules = []
	var current_shift_val = GameStateManager.get_shift() if GameStateManager else Global.shift
	match current_shift_val:
		0:  # Tutorial - only the simplest rule
			available_rules = ["law_fresh_potatoes"]
		1:  # First shift - simple visual rules only
			available_rules = all_rules.filter(
				func(rule): return LawValidator.get_rule_difficulty(rule) == 1
			)
		2, 3:  # Early shifts - simple and medium rules
			available_rules = all_rules.filter(
				func(rule): return LawValidator.get_rule_difficulty(rule) <= 2
			)
		_:  # Later shifts - all rules available
			available_rules = all_rules

	# Shuffle and select appropriate number of rules
	available_rules.shuffle()
	current_rules = available_rules.slice(0, num_rules)

	# Ensure no conflicting rules
	current_rules = LawValidator.remove_conflicting_rules(current_rules)

	# If we removed rules due to conflicts, try to fill back up to target number
	if current_rules.size() < num_rules:
		var remaining_rules = available_rules.filter(func(rule): return not rule in current_rules)
		remaining_rules.shuffle()
		var needed = num_rules - current_rules.size()
		current_rules.append_array(remaining_rules.slice(0, needed))

	update_rules_display()

	# Log rules for debugging
	LogManager.write_info(
		"Generated rules for shift " + str(current_shift_val) + ": " + str(current_rules)
	)


func _calculate_rules_for_shift() -> int:
	# Progressive rule complexity
	var current_shift_val = GameStateManager.get_shift() if GameStateManager else Global.shift
	match current_shift_val:
		0:
			return 1  # Tutorial
		1:
			return 1  # First real shift
		2:
			return 2  # Start complexity
		3, 4:
			return 2  # Build understanding
		5, 6, 7:
			return 3  # Mid-game complexity
		_:
			return min(4, 2 + (current_shift_val - 6))  # Late game, max 4


func update_rules_display():
	# Create more professional-looking rules display
	var laws_text = "[center][b][u]" + tr("LAWS") + "[/u][/b][/center]\n\n"

	# Add each rule with bullet points for clarity
	for i in range(current_rules.size()):
		var rule_key = current_rules[i]
		var rule_text = tr(rule_key)  # Use translation system
		laws_text += str(i + 1) + ". " + rule_text + "\n\n"

	# Add footer explaining enforcement
	laws_text += "[center][i]" + tr("rule_footer_text") + "[/i][/center]\n"
	laws_text += "[center][i]" + tr("rule_expired_note") + "[/i][/center]"

	# Update the law receipt display
	if $Gameplay/InteractiveElements/LawReceipt/OpenReceipt/ReceiptNote:
		$Gameplay/InteractiveElements/LawReceipt/OpenReceipt/ReceiptNote.text = laws_text

	# Emit the signal with the formatted laws text
	emit_signal("rules_updated", laws_text)


# Enhanced rule explanation system for tutorial
func show_rule_explanation(rule_key: String):
	"""Show explanation for specific rules during tutorial phases"""
	var current_shift_val = GameStateManager.get_shift() if GameStateManager else Global.shift
	if current_shift_val > 2:  # Only show explanations for first few shifts
		return

	var explanation_key = "rule_explanation_" + rule_key.replace("law_", "")
	var explanation_text = tr(explanation_key)

	# Fallback explanations if translation keys don't exist
	if explanation_text == explanation_key:  # Translation key not found
		match rule_key:
			"law_fresh_potatoes":
				explanation_text = (
					tr("tutorial_check_condition") + "\nIf condition is not 'Fresh' - REJECT"
				)
			"law_sweet_potatoes":
				explanation_text = (
					tr("tutorial_check_type") + "\nIf type is 'Sweet Potato' - REJECT"
				)
			"law_country_chip_hill":
				explanation_text = (
					tr("tutorial_check_country") + "\nIf country is 'Chip Hill' - REJECT"
				)
			"law_males_only", "law_females_only":
				explanation_text = (
					tr("tutorial_check_gender") + "\nCheck gender against current rule"
				)
			_:
				explanation_text = "Check passport details against this rule"

	# Display explanation
	# Display explanation
	# REFACTORED: Use EventBus
	EventBus.show_alert(tr("rule_explanation_header") + "\n" + explanation_text, true)


func is_potato_valid(potato_info: Dictionary) -> bool:
	# Use the LawValidator to check violations
	var validation = LawValidator.check_violations(potato_info, current_rules)
	return validation.is_valid


func update_date_display():
	# Use in-game fictional date based on shift number
	# Game takes place January 10-20, 2024
	var formatted_date = GameStateManager.get_formatted_in_game_date()
	$UI/Labels/DateLabel.text = formatted_date
	$UI/Labels/DateLabel.visible = true


func megaphone_clicked():
	# Check if there's already a potato in the Customs Office
	Analytics.track_ui_interaction("megaphone", "clicked")

	# Trigger tutorial action for megaphone click
	if TutorialManager:
		TutorialManager.trigger_tutorial_action("megaphone_clicked")

	if is_potato_in_office:
		#print("A potato is already in the customs office!")
		megaphone_dialogue_box.set_random_message_from_category("spud_in_office")
		return

	var potato = queue_manager.remove_front_potato()
	if potato:
		if (
			office_shutter_controller.active_shutter_state
			== office_shutter_controller.ShutterState.CLOSED
		):
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
	else:  # No potatoes
		megaphone_dialogue_box.set_random_message_from_category("misc")


func move_potato_to_office(potato_person: PotatoPerson):
	print("Moving potato to customs office")
	print(
		"Potato info: Race: ",
		potato_person.potato_info.race,
		" Sex: ",
		potato_person.potato_info.sex,
		" Character Data: ",
		(
			potato_person.potato_info.character_data
			if potato_person.potato_info.has("character_data")
			else "MISSING"
		)
	)

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
	tween.tween_callback(
		func():
			# Before cleanup, make sure we've fully captured the potato data including character data
			if (
				!current_potato_info.has("character_data")
				and potato_person.potato_info.has("character_data")
			):
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
	if (
		office_shutter_controller.active_shutter_state
		== office_shutter_controller.ShutterState.CLOSED
	):
		office_shutter_controller.raise_shutter()

	print(
		"Starting animate_mugshot_and_passport with potato info:",
		current_potato_info.race,
		current_potato_info.sex
	)

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
	mugshot_generator.position.x = (
		suspect_panel_spawn_node.position.x + suspect_panel_front.texture.get_width()
	)
	passport.visible = false
	passport.z_index = 7
	passport.position = Vector2(
		passport_spawn_point_begin.position.x, passport_spawn_point_begin.position.y
	)

	var tween = create_tween()
	tween.set_parallel(true)

	# Animate potato mugshot
	tween.tween_property(mugshot_generator, "position:x", suspect_panel_spawn_node.position.x, 1)
	tween.tween_property(mugshot_generator, "modulate:a", 1, 1)

	# Animate passport
	tween.tween_property(passport, "modulate:a", 1, 1)
	tween.tween_property(passport, "visible", true, 0).set_delay(1)
	(
		tween
		. tween_property(passport, "position:y", passport_spawn_point_end.position.y, 0.4)
		. set_delay(1)
	)

	# IMPORTANT: After animation finishes, restore the original potato info
	# to prevent it from being overwritten
	tween.chain().tween_callback(
		func():
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


# Called when player hovers over megaphone
func _on_megaphone_hover() -> void:
	var hover_sound = preload("res://assets/audio/ui_feedback/ui_hover_megaphone.mp3")
	var hover_player = AudioStreamPlayer.new()
	hover_player.stream = hover_sound
	hover_player.bus = "SFX"
	hover_player.volume_db = -6.0
	hover_player.pitch_scale = randf_range(0.95, 1.05)
	add_child(hover_player)
	hover_player.play()
	hover_player.finished.connect(hover_player.queue_free)


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

	# Skip UIHint processing while tutorial is active to avoid conflicting highlights
	if TutorialManager and TutorialManager.is_tutorial_active():
		# Reset all hint timers so they don't immediately fire when tutorial ends
		ui_hint_system.reset_timer("passport")
		ui_hint_system.reset_timer("megaphone")
		ui_hint_system.reset_timer("stamp_bar")
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

	if (
		suspect.get_rect().has_point(suspect.to_local(mouse_pos))
		and drag_and_drop_manager.is_document_open("passport") == false
		and drag_and_drop_manager.drag_system.get_dragged_item() == passport
	):
		if (
			office_shutter_controller.active_shutter_state
			== office_shutter_controller.ShutterState.OPEN
		):
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
		expiration_date = get_future_date(0, 3)

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
		$Gameplay/InteractiveElements/Passport/OpenPassport/PotatoHeader.text = """{name}""".format(
			current_potato_info
		)

		# Create translated versions
		var translated_sex = tr("sex_" + current_potato_info.sex.to_lower())
		var translated_condition = tr(
			"condition_" + current_potato_info.condition.to_lower().replace(" ", "_")
		)

		# Translate race using translation key (e.g., "Sweet Potato" -> "race_sweet_potato")
		var race_key = "race_" + current_potato_info.race.to_lower().replace(" ", "_")
		var translated_race = tr(race_key)

		# Translate country using translation key (e.g., "Mash Meadows" -> "country_mash_meadows")
		var country_key = "country_" + current_potato_info.country_of_issue.to_lower().replace(" ", "_")
		var translated_country = tr(country_key)

		# Format dates like desk display (Month Day, Year)
		var formatted_dob = _format_passport_date(current_potato_info.date_of_birth)
		var formatted_expiration = _format_passport_date(current_potato_info.expiration_date)

		var display_info = current_potato_info.duplicate()
		display_info.sex = translated_sex
		display_info.condition = translated_condition
		display_info.race = translated_race
		display_info.country_of_issue = translated_country
		display_info.date_of_birth = formatted_dob
		display_info.expiration_date = formatted_expiration

		# Dynamic font scaling for long text fields to prevent overflow
		var max_field_length: int = 0
		max_field_length = max(max_field_length, current_potato_info.name.length())
		max_field_length = max(max_field_length, translated_country.length())
		max_field_length = max(max_field_length, translated_condition.length())

		# Scale font size based on longest field (adjusted for smaller base font)
		var potato_info_label = $Gameplay/InteractiveElements/Passport/OpenPassport/PotatoInfo
		if max_field_length > 15:
			potato_info_label.add_theme_font_size_override("font_size", 11)
		elif max_field_length > 12:
			potato_info_label.add_theme_font_size_override("font_size", 12)
		else:
			potato_info_label.add_theme_font_size_override("font_size", 13)

		# FIXED: Include race/type information clearly
		# Use translation keys for labels, values come from display_info
		potato_info_label.text = (
			tr("passport_label_type") + " {race}\n" +
			tr("passport_label_born") + " {date_of_birth}\n" +
			tr("passport_label_gender") + " {sex}\n" +
			tr("passport_label_country") + " {country_of_issue}\n" +
			tr("passport_label_expires") + " {expiration_date}\n" +
			tr("passport_label_condition") + " {condition}"
		).format(display_info)
	else:
		print("No current_potato_info found.")

	# Update mugshot and passport visuals
	update_potato_texture()


## Format a date string from YYYY.MM.DD to localized "Month Day, Year" format
func _format_passport_date(date_string: String) -> String:
	var parts = date_string.split(".")
	if parts.size() != 3:
		return date_string  # Return original if format is unexpected

	var year = int(parts[0])
	var month = int(parts[1])
	var day = int(parts[2])

	# Get translated month name using same keys as desk date display
	var month_key = "month_%d" % month
	var month_name = tr(month_key)

	# Fallback to English if translation not found
	if month_name == month_key:
		var months_en = ["January", "February", "March", "April", "May", "June",
						 "July", "August", "September", "October", "November", "December"]
		if month >= 1 and month <= 12:
			month_name = months_en[month - 1]
		else:
			month_name = "Unknown"

	return "%s %d, %d" % [month_name, day, year]


func get_random_name():
	var first_names = [
		"Spud",
		"Tater",
		"Mash",
		"Spudnik",
		"Tater Tot",
		"Potato",
		"Chip",
		"Murph",
		"Yam",
		"Tato",
		"Spuddy",
		"Tuber",
		"Russet",
		"Fry",
		"Hash",
		"Wedge",
		"Rosti",
		"Gnocchi",
		"Gratin",
		"Duchess",
		"Rösti",
		"Hasselback",
		"Dauphinoise",
		"Fondant",
		"Croquette",
		"Scallop",
		"Pomme",
		"Aloo",
		"Batata",
		"Patata",
		"Kartoffel",
		"Jicama",
		"Sunchoke",
		"Yuca",
		"Oca",
		"Taro",
		"Cassava",
		"Mandioca",
		"Malanga",
		"Rutabaga",
		"Parmentier",
		"Poutine",
		"Latke",
		"Ratte",
		"Fingerling",
		"Bintje"
	]
	var last_names = [
		"Ouwiw",
		"Sehi",
		"Sig",
		"Heechou",
		"Oufug",
		"Azej",
		"Holly",
		"Ekepa",
		"Nuz",
		"Chegee",
		"Kusee",
		"Houf",
		"Fito",
		"Mog",
		"Urife",
		"Quib",
		"Zog",
		"Yux",
		"Wug",
		"Vij",
		"Thog",
		"Spaz",
		"Rix",
		"Quog",
		"Pud",
		"Nax",
		"Mub",
		"Loz",
		"Kiv",
		"Juf",
		"Hix",
		"Gub",
		"Faz",
		"Duv",
		"Coz",
		"Bix",
		"Anj",
		"Zin",
		"Yad",
		"Woz",
		"Vix",
		"Tuj",
		"Sab",
		"Riv",
		"Poz"
	]
	return (
		"%s %s"
		% [first_names[randi() % first_names.size()], last_names[randi() % last_names.size()]]
	)


func get_random_condition():
	var conditions = ["Fresh", "Extra Eyes", "Rotten", "Sprouted", "Dehydrated", "Frozen"]
	return conditions[randi() % conditions.size()]


func get_random_sex():
	return ["Male", "Female"][randi() % 2]


func get_random_country():
	var countries = [
		"Spudland",
		"Potatopia",
		"Tuberstan",
		"North Yamnea",
		"Spuddington",
		"Tatcross",
		"Mash Meadows",
		"Tuberville",
		"Chip Hill",
		"Murphyland",
		"Colcannon",
		"Pratie Point"
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
	var year = (
		current_date.year + years_ahead_start + randi() % (years_ahead_end - years_ahead_start + 1)
	)
	var month = randi() % 12 + 1
	var day = randi() % 28 + 1  # Simplified to avoid month-specific day calculations
	return "%04d.%02d.%02d" % [year, month, day]


func calculate_age(date_of_birth: String) -> int:
	var current_date = Time.get_date_dict_from_system()
	var birth_parts = date_of_birth.split(".")

	if birth_parts.size() != 3:
		print("Invalid date format: ", date_of_birth)
		return 0

	var birth_year = birth_parts[0].to_int()
	var birth_month = birth_parts[1].to_int()
	var birth_day = birth_parts[2].to_int()

	var age = current_date.year - birth_year

	# Adjust age if birthday hasn't occurred this year
	if (
		current_date.month < birth_month
		or (current_date.month == birth_month and current_date.day < birth_day)
	):
		age -= 1

	return age


# REFACTORED: Update score display when EventBus.score_changed fires
func _on_score_changed(new_score: int, delta: int, source: String):
	#$UI/Labels/ScoreLabel.text = "Score: " + str(new_score)
	$UI/Labels/ScoreLabel.text = tr("ui_score").format({"score": str(new_score)})
	
	# NEW: Play score popup sound for positive score changes
	if delta > 0:
		var score_sound = preload("res://assets/audio/gameplay/score_popup.mp3")
		var player = AudioStreamPlayer.new()
		player.stream = score_sound
		player.bus = "SFX"
		player.volume_db = -8.0
		player.pitch_scale = randf_range(0.95, 1.05)
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)


# REFACTORED: Handle strike changes via EventBus
func _on_strike_changed(current_strikes: int, max_strikes: int, delta: int):
	update_strikes_display()
	
	# NEW: Play citation sound when strike is added
	if delta > 0:
		var citation_sound = preload("res://assets/audio/gameplay/citation_added.mp3")
		var player = AudioStreamPlayer.new()
		player.stream = citation_sound
		player.bus = "SFX"
		player.volume_db = -5.0
		player.pitch_scale = randf_range(0.95, 1.05)
		add_child(player)
		player.play()
		player.finished.connect(player.queue_free)


# REFACTORED: Handle quota changes via EventBus
func _on_quota_updated(new_target: int, current_met: int):
	update_quota_display()


# NEW: Handle strike removed with sound
func _on_strike_removed(current_strikes: int, max_strikes: int):
	update_strikes_display()
	
	# Play strike removed sound
	var strike_removed_sound = preload("res://assets/audio/gameplay/strike_removed.mp3")
	var player = AudioStreamPlayer.new()
	player.stream = strike_removed_sound
	player.bus = "SFX"
	player.volume_db = -5.0
	player.pitch_scale = randf_range(0.95, 1.05)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


# NEW: Handle runner escaped with sound
func _on_runner_escaped(runner_data: Dictionary):
	# Play runner escaped sound
	var runner_escaped_sound = preload("res://assets/audio/gameplay/runner_escaped.mp3")
	var player = AudioStreamPlayer.new()
	player.stream = runner_escaped_sound
	player.bus = "SFX"
	player.volume_db = -3.0
	player.pitch_scale = randf_range(0.95, 1.05)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


# Handle minigame bonus requests
func _on_minigame_bonus_requested(bonus: int, source: String):
	if bonus > 0:
		EventBus.request_score_add(bonus, source, {"minigame_bonus": true})
		EventBus.show_alert(tr("alert_minigame_bonus").format({"bonus": str(bonus)}), true, 2.0)


## Launch a random minigame based on current progression
## Call this from appropriate places (e.g., after certain events, bonus rounds)
func trigger_random_minigame():
	if minigame_launcher and not minigame_launcher.is_minigame_active():
		minigame_launcher.launch_random()


# NEW: Handle achievement unlocked with sound
func _on_achievement_unlocked(achievement_id: String):
	# Play achievement sound
	var achievement_sound = preload("res://assets/audio/ui_feedback/achievement_unlocked.mp3")
	var player = AudioStreamPlayer.new()
	player.stream = achievement_sound
	player.bus = "SFX"
	player.volume_db = 0.0  # Prominent
	player.pitch_scale = randf_range(0.98, 1.02)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


# NEW: Handle high score achieved with sound
func _on_high_score_achieved(difficulty: String, score: int, shift: int):
	# Play high score sound
	var high_score_sound = preload("res://assets/audio/ui_feedback/high_score_achieved.mp3")
	var player = AudioStreamPlayer.new()
	player.stream = high_score_sound
	player.bus = "SFX"
	player.volume_db = 0.0  # Prominent
	player.pitch_scale = randf_range(0.98, 1.02)
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


## Launch a specific minigame if unlocked
func trigger_minigame(minigame_type: String, config: Dictionary = {}):
	if minigame_launcher and not minigame_launcher.is_minigame_active():
		if minigame_launcher.is_minigame_unlocked(minigame_type):
			minigame_launcher.launch(minigame_type, config)
		else:
			print("[MainGame] Minigame '%s' is not yet unlocked" % minigame_type)


## Try to trigger a minigame when reaching streak milestone
func _try_trigger_streak_minigame():
	# Check if we've hit the minigame limit for this shift
	if not _can_trigger_minigame():
		return

	# Only trigger at exact milestone to avoid repeated triggers
	if correct_decision_streak != STREAK_MINIGAME_THRESHOLD:
		return

	# Random chance to trigger
	if randf() > STREAK_MINIGAME_CHANCE:
		return

	# Check if minigames are available for this shift
	if not minigame_launcher or minigame_launcher.get_unlocked_minigames().is_empty():
		return

	_minigames_triggered_this_shift += 1

	# Play attention-grabbing sound and visual effect to prepare player
	_play_minigame_warning_effect()
	EventBus.show_alert(tr("alert_streak_bonus_minigame"), true, 3.0)

	# Longer delay to give player time to notice and prepare
	await get_tree().create_timer(2.5).timeout
	trigger_random_minigame()


## Try to trigger a minigame when achieving consecutive perfect stamps
func _try_trigger_perfect_stamp_minigame():
	# Check if we've hit the minigame limit for this shift
	if not _can_trigger_minigame():
		return

	# Only trigger at exact threshold
	if _consecutive_perfect_stamps != PERFECT_STAMP_MINIGAME_THRESHOLD:
		return

	# Random chance to trigger
	if randf() > PERFECT_STAMP_MINIGAME_CHANCE:
		return

	# Check if minigames are available for this shift
	if not minigame_launcher or minigame_launcher.get_unlocked_minigames().is_empty():
		return

	_minigames_triggered_this_shift += 1

	# Play attention-grabbing sound and visual effect to prepare player
	_play_minigame_warning_effect()
	EventBus.show_alert(tr("alert_perfect_stamps_bonus_minigame"), true, 3.0)

	# Longer delay to give player time to notice and prepare
	await get_tree().create_timer(2.5).timeout
	trigger_random_minigame()


## Play visual and audio warning effect before minigame launches
func _play_minigame_warning_effect():
	# Play a distinctive warning sound
	if $SystemManagers/AudioManager/SFXPool:
		var warning_sound = load("res://assets/audio/ui_feedback/Task Complete Ensemble 001.wav")
		if warning_sound:
			$SystemManagers/AudioManager/SFXPool.stream = warning_sound
			$SystemManagers/AudioManager/SFXPool.volume_db = -3.0
			$SystemManagers/AudioManager/SFXPool.play()

	# Create a screen pulse effect to draw attention
	var pulse_overlay = ColorRect.new()
	pulse_overlay.color = Color(0.5, 0.3, 0.8, 0.0)  # Purple tint
	pulse_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	pulse_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pulse_overlay.z_index = 50
	$UI.add_child(pulse_overlay)

	# Animate the pulse - fade in and out twice
	var tween = create_tween()
	tween.tween_property(pulse_overlay, "color:a", 0.25, 0.3)
	tween.tween_property(pulse_overlay, "color:a", 0.0, 0.3)
	tween.tween_property(pulse_overlay, "color:a", 0.2, 0.25)
	tween.tween_property(pulse_overlay, "color:a", 0.0, 0.25)
	tween.tween_callback(pulse_overlay.queue_free)


## Handle minigame trigger request from border runner system
## This is called when a minigame should trigger instead of a border runner
func _on_minigame_from_runner_requested(minigame_type: String):
	# Check if we've hit the minigame limit for this shift
	if not _can_trigger_minigame():
		print("Minigame from runner skipped - hit limit for this shift (%d/%d)" % [_minigames_triggered_this_shift, _get_max_minigames_for_shift()])
		return

	# Check if minigames are available
	if not minigame_launcher or minigame_launcher.is_minigame_active():
		return

	_minigames_triggered_this_shift += 1

	# Play warning effect and show alert
	_play_minigame_warning_effect()
	EventBus.show_alert(tr("alert_runner_bonus_minigame"), true, 3.0)

	# Delay to give player time to notice and prepare
	await get_tree().create_timer(2.5).timeout

	# Launch the specific minigame type that was selected
	if minigame_launcher:
		minigame_launcher.launch(minigame_type)


func process_decision(allowed):
	print("Evaluating immigration decision in process_decision()...")
	if !current_potato_info or current_potato_info.is_empty():
		print("No potato to process.")
		return

	shift_stats.total_stamps += 1
	if allowed:
		shift_stats.potatoes_approved += 1
		# Emit EventBus signal for potato approved
		EventBus.potato_approved.emit(current_potato_info.duplicate() if current_potato_info else {})
	else:
		shift_stats.potatoes_rejected += 1
		# Emit EventBus signal for potato rejected
		EventBus.potato_rejected.emit(current_potato_info.duplicate() if current_potato_info else {})

	# Get validation result
	var validation = LawValidator.check_violations(current_potato_info, current_rules)
	var correct_decision = validation.is_valid

	# Update stats based on correctness of decision
	# Update stats based on correctness of decision
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		# REFACTORED: Use EventBus for quota update
		EventBus.request_quota_update(1)
		correct_decision_streak += 1

		# Check if quota met
		# REFACTORED: Use GameStateManager
		var current_quota = GameStateManager.get_quota_met() if GameStateManager else Global.quota_met
		var target_quota = GameStateManager.get_quota_target() if GameStateManager else Global.quota_target
		
		# The EventBus quota update is synchronous, so current_quota is already updated
		if current_quota >= target_quota:
			# IMMEDIATELY disable border runner system to prevent runners during shift end
			# This prevents race condition where runners spawn during summary screen transition
			if border_runner_system:
				border_runner_system.disable()
				border_runner_system.is_enabled = false
			office_shutter_controller.lower_shutter(0.7)
			print("Quota complete!")
			end_shift(true)  # end shift with success condition
			return  # Cease processing

		# Increase multiplier for streaks
		if correct_decision_streak >= 3:
			point_multiplier = 1.5
		if correct_decision_streak >= 5:
			point_multiplier = 2.0
			# Trigger bonus minigame at streak milestone (once per shift)
			_try_trigger_streak_minigame()

		# Award points for correct decisions
		var decision_points = 250 * point_multiplier
		var alert_text = tr("alert_correct_decision").format({"points": str(decision_points)})

		if !allowed and validation.violation_reason:
			alert_text += "\n" + validation.violation_reason

		var decision_string: String = "approved" if allowed else "rejected"
		Analytics.track_potato_processed(decision_string, correct_decision, current_potato_info)

		# REFACTORED: Use EventBus
		EventBus.show_alert(alert_text, true)
		EventBus.request_score_add(decision_points, "correct_decision", {"streak": correct_decision_streak})

		# ENHANCEMENT: Flash screen green for correct decision
		_flash_screen_color(Color.GREEN, 0.2)

		# ENHANCEMENT: Show rule explanation for tutorial
		var current_shift_val = GameStateManager.get_shift() if GameStateManager else Global.shift
		if current_shift_val <= 1 and !allowed:
			for rule_key in current_rules:
				var check_func = LawValidator.LAW_CHECKS[rule_key]["check"]
				if check_func.call(current_potato_info):
					show_rule_explanation(rule_key)
					break

	else:
		# Decision was incorrect
		var alert_text = tr("alert_wrong_decision")

		if allowed and !correct_decision:
			# Player approved an invalid potato
			if validation.violation_reason:
				alert_text += "\n" + validation.violation_reason
		else:
			# Player rejected a valid potato
			alert_text += "\n" + tr("alert_potato_should_be_approved")

		var violated_rules_array: Array = []
		if validation.violation_reason:
			violated_rules_array.append(validation.violation_reason)
		Analytics.track_incorrect_decision(current_potato_info, violated_rules_array)

		# REFACTORED: Use EventBus
		EventBus.show_alert(alert_text, false)
		correct_decision_streak = 0
		point_multiplier = 1.0

		# Build detailed citation reason (same detail as alert)
		var citation_reason: String = ""
		if allowed and !correct_decision:
			# Player approved an invalid potato - show the violation
			citation_reason = validation.violation_reason if validation.violation_reason else tr("incorrect_decision")
		else:
			# Player rejected a valid potato
			citation_reason = tr("alert_potato_should_be_approved").strip_edges()
		EventBus.request_strike_add(citation_reason, {"potato_info": current_potato_info})

		# ENHANCEMENT: Flash screen red for wrong decision
		_flash_screen_color(Color.RED, 0.3)

		# ENHANCEMENT: Show explanation for tutorial mistakes
		var current_shift_val = GameStateManager.get_shift() if GameStateManager else Global.shift
		if current_shift_val <= 1:
			show_rule_explanation(current_rules[0] if current_rules.size() > 0 else "")

		var current_strikes = GameStateManager.get_strikes() if GameStateManager else Global.strikes
		var max_strikes = GameStateManager.get_max_strikes() if GameStateManager else Global.max_strikes

		# The EventBus strike update is synchronous, so current_strikes is already updated
		if current_strikes >= max_strikes:
			alert_text = tr("alert_strike_out")
			EventBus.show_alert(alert_text, false)
			# Lower the shutter when max strikes reached
			office_shutter_controller.lower_shutter(0.7)
			# REFACTORED: Use GameStateManager
			Analytics.track_shift_failed(current_shift_val, alert_text)
			end_shift(false)  # end shift with failure condition
			return  # Cease processing

	# CRITICAL: Keep all your existing UI updates and spawn timer logic
	update_score_display()
	update_quota_display()
	update_strikes_display()
	if queue_manager.can_add_potato() and spawn_timer.is_stopped():
		spawn_timer.start()


func update_score_display():
	# REFACTORED: Use GameStateManager with Global fallback
	var current_score = GameStateManager.get_score() if GameStateManager else Global.score
	#$UI/Labels/ScoreLabel.text = "Score: " + str(current_score)
	$UI/Labels/ScoreLabel.text = tr("ui_score").format({"score": str(current_score)})
	if point_multiplier > 1.0:
		$UI/Labels/ScoreLabel.text += " (x" + str(point_multiplier) + ")"


func update_quota_display():
	# REFACTORED: Use GameStateManager with Global fallback
	var current_quota = GameStateManager.get_quota_met() if GameStateManager else Global.quota_met
	var quota_target = GameStateManager.get_quota_target() if GameStateManager else Global.quota_target
	var quota_label = $UI/Labels/QuotaLabel

	# Ensure shift is at least 1 for calculation purposes, such as in shift 0 for tutorial
	# Update the text
	# quota_label.text = "Quota: " + str(current_quota) + " / " + str(quota_target)

	# Update the text with translation
	quota_label.text = tr("ui_quota").format(
		{"current": str(current_quota), "target": str(quota_target)}
	)

	# Check if there's a change OR if this is the first update (previous_quota is -1)
	if previous_quota != current_quota && previous_quota != -1:
		var tween = create_tween()

		if current_quota > previous_quota:
			# Positive change - bounce up animation
			tween.tween_property(quota_label, "scale", Vector2(1.2, 1.2), 0.1)
			(
				tween
				. tween_property(quota_label, "scale", Vector2(1.0, 1.0), 0.2)
				. set_trans(Tween.TRANS_BOUNCE)
				. set_ease(Tween.EASE_OUT)
			)

			# Optional: Change color briefly to green
			tween.parallel().tween_property(quota_label, "modulate", Color(0.5, 1.0, 0.5, 1.0), 0.1)
			tween.tween_property(quota_label, "modulate", Color(1.0, 0.782051, 0.655081, 1.0), 0.3)
		else:
			# Negative change - shake animation
			var original_pos = quota_label.position
			var shake_strength = 5.0

			# Series of position offsets to create shake effect
			tween.tween_property(
				quota_label, "position", original_pos + Vector2(-shake_strength, 0), 0.05
			)
			tween.tween_property(
				quota_label, "position", original_pos + Vector2(shake_strength, 0), 0.05
			)
			tween.tween_property(
				quota_label, "position", original_pos + Vector2(0, -shake_strength), 0.05
			)
			tween.tween_property(
				quota_label, "position", original_pos + Vector2(0, shake_strength), 0.05
			)
			tween.tween_property(quota_label, "position", original_pos, 0.05)

			# Change color briefly to red
			tween.parallel().tween_property(quota_label, "modulate", Color(1.0, 0.4, 0.4, 1.0), 0.1)
			tween.tween_property(quota_label, "modulate", Color(1.0, 0.782051, 0.655081, 1.0), 0.3)

	# Update previous quota for next comparison
	previous_quota = current_quota


func update_strikes_display():
	# REFACTORED: Use GameStateManager with Global fallback
	var current_strikes = GameStateManager.get_strikes() if GameStateManager else Global.strikes
	var max_strikes = GameStateManager.get_max_strikes() if GameStateManager else Global.max_strikes
	var strikes_label = $UI/Labels/StrikesLabel

	# Update the text
	# strikes_label.text = "Strikes: " + str(current_strikes) + " / " + str(max_strikes)

	# Update the text with translation
	strikes_label.text = tr("ui_strikes").format(
		{"current": current_strikes, "max": max_strikes}
	)
	# Check if there's a change OR if this is the first update (previous_strikes is -1)
	if previous_strikes != current_strikes && previous_strikes != -1:
		var tween = create_tween()

		if current_strikes > previous_strikes:
			# Strikes increased - negative shake animation
			var original_pos = strikes_label.position
			var shake_strength = 5.0

			# More intense shake for strikes
			tween.tween_property(
				strikes_label,
				"position",
				original_pos + Vector2(-shake_strength, -shake_strength),
				0.05
			)
			tween.tween_property(
				strikes_label,
				"position",
				original_pos + Vector2(shake_strength, shake_strength),
				0.05
			)
			tween.tween_property(
				strikes_label,
				"position",
				original_pos + Vector2(-shake_strength, shake_strength),
				0.05
			)
			tween.tween_property(
				strikes_label,
				"position",
				original_pos + Vector2(shake_strength, -shake_strength),
				0.05
			)
			tween.tween_property(strikes_label, "position", original_pos, 0.05)

			# Change color briefly to bright red then settle to base reddish
			tween.parallel().tween_property(
				strikes_label, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.1
			)
			tween.tween_property(
				strikes_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3
			)
		else:
			# Strikes decreased - positive bounce animation
			tween.tween_property(strikes_label, "scale", Vector2(1.2, 1.2), 0.1)
			(
				tween
				. tween_property(strikes_label, "scale", Vector2(1.0, 1.0), 0.2)
				. set_trans(Tween.TRANS_BOUNCE)
				. set_ease(Tween.EASE_OUT)
			)

			# Change color briefly to green (positive) then settle to base
			tween.parallel().tween_property(
				strikes_label, "modulate", Color(0.5, 1.0, 0.5, 1.0), 0.1
			)
			tween.tween_property(
				strikes_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3
			)

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
	if decision == "approved":
		# The left side if they are approved by the User
		tween.tween_property(
			mugshot_generator,
			"position:x",
			suspect_panel_spawn_node.position.x - suspect_panel_front.texture.get_width(),
			0.7
		)
	else:
		# The right side if they are rejected by the User
		tween.tween_property(
			mugshot_generator,
			"position:x",
			suspect_panel_spawn_node.position.x + suspect_panel_front.texture.get_width(),
			0.7
		)

	tween.tween_property(mugshot_generator, "modulate:a", 0, 0.7)
	tween.tween_property(passport, "modulate:a", 0, 0.7)
	# OPTIONAL: Lower the gate as the potato leaves
	#office_gate_controller.lower_gate(1.0)
	tween.chain().tween_callback(
		func():
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
		potato.path_completed.connect(
			func():
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
			tween.tween_callback(
				func():
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
			tween.tween_callback(
				func():
					if is_instance_valid(footprint):
						footprint.queue_free()
			)


func _exit_tree():
	# Clean up tutorial UI when leaving the scene
	if TutorialManager:
		TutorialManager.cleanup_tutorial_ui()

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
	# Reset quota and strikes in both Global and GameStateManager
	Global.quota_met = 0
	Global.strikes = 0
	if GameStateManager:
		GameStateManager.set_quota_met(0)
		GameStateManager.set_strikes(0)
	# Completely unpause all game systems
	# get_tree().paused = false
	is_game_paused = false
	# Tell the border runner system dialogic mode is done
	if border_runner_system:
		border_runner_system.set_dialogic_mode(false)
		# Disable border runners only on tutorial shift (0) to let players learn core mechanics
		# Border runners are introduced in shift 1 with the runner tutorial
		var is_tutorial = GameStateManager.is_tutorial_mode() if GameStateManager else false
		if current_shift == 0 or is_tutorial:
			border_runner_system.is_enabled = false
			border_runner_system.runner_chance = 0.0
		else:
			border_runner_system.is_enabled = true
			border_runner_system.runner_chance = original_runner_chance
	enable_controls()

	var skip_buttons = get_tree().get_nodes_in_group("DialogueSkipButtons")
	for button_layer in skip_buttons:
		if is_instance_valid(button_layer):
			button_layer.queue_free()

	# Start interactive tutorials for the current shift
	if TutorialManager:
		TutorialManager.check_shift_tutorials(current_shift)

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
	# Check if this is a narrative-only shift (skip gameplay, go directly to end dialogue)
	var current_shift: int = GameStateManager.get_shift() if GameStateManager else Global.shift
	if current_shift in NARRATIVE_ONLY_SHIFTS:
		print("[MainGame] Shift %d is narrative-only, skipping gameplay" % current_shift)
		# Go directly to end dialogue without any gameplay
		_start_narrative_only_end_dialogue()
		return

	# Enable all game systems
	enable_controls()
	is_game_paused = false

	# Make sure quota and strikes are reset in both Global and GameStateManager
	Global.quota_met = 0
	Global.strikes = 0
	if GameStateManager:
		GameStateManager.set_quota_met(0)
		GameStateManager.set_strikes(0)

	# Start the actual gameplay
	spawn_timer.start()

	# Play shift start fanfare sound
	_play_shift_start_sound()

	# Update UI
	update_quota_display()
	update_strikes_display()

	# Show any pending unlock notifications after a short delay
	_show_pending_unlock_notifications()


## Handle narrative-only shifts by going directly to end dialogue
## These are climactic story moments (shifts 9, 10) that skip regular gameplay
func _start_narrative_only_end_dialogue() -> void:
	var current_shift_id: int = GameStateManager.get_shift() if GameStateManager else Global.shift

	# For shift 10 (final confrontation), use the special handler
	if current_shift_id == 10:
		narrative_manager.start_final_confrontation()
		await narrative_manager.dialogue_finished
		# Final confrontation handles its own ending via signals
		return

	# For other narrative-only shifts (like shift 9), start end dialogue
	narrative_manager.start_level_end_dialogue(current_shift_id)
	await narrative_manager.end_dialogue_finished

	# Create minimal stats for the summary screen (no gameplay occurred)
	var stats_dict: Dictionary = {
		"base_score": 0,
		"time_bonus": 0,
		"accuracy_bonus": 0,
		"perfect_hit_bonus": 0,
		"final_score": GameStateManager.get_score() if GameStateManager else Global.score,
		"quota_met": 0,
		"quota_target": 0,
		"strikes": 0,
		"max_strikes": GameStateManager.get_max_strikes() if GameStateManager else Global.max_strikes,
		"success": true,
		"narrative_only": true  # Flag to indicate this was a narrative-only shift
	}

	# Show the summary screen
	_show_shift_summary_screen(stats_dict)


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


# EventBus game over handler - triggered when GameStateManager emits game_over_triggered
func _on_eventbus_game_over(reason: String) -> void:
	LogManager.write_info("Game over triggered via EventBus: " + reason)
	_on_game_over()


# EventBus max strikes handler - triggered when max strikes reached
func _on_max_strikes_reached() -> void:
	LogManager.write_info("Max strikes reached - triggering game over")
	# The game_over_triggered signal will also be emitted, so this is mainly for logging
	# and any additional max-strikes-specific behavior


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

	# Play a dramatic failure sound
	_play_game_over_sound()

	# Small delay for dramatic effect
	await get_tree().create_timer(0.5).timeout

	# Lower shutter if not already lowered
	office_shutter_controller.lower_shutter(0.8)

	# Small delay for shutter animation
	await get_tree().create_timer(0.8).timeout

	# After updating all stats but before showing the summary screen
	GlobalState.save()

	# This will handle storing stats and showing the summary screen
	end_shift(false)  # false = not a success scenario


# Screen shake with configurable intensity and duration
# Mild: intensity 3-5, duration 0.2
# Medium: intensity 10-15, duration 0.3
# Strong: intensity 20-25, duration 0.4
func shake_screen(intensity: float = 10.0, duration: float = 0.3):
	Global.shake_screen(intensity, duration)


# EventBus signal handlers for UI feedback
func _on_screen_shake_requested(intensity: float, duration: float) -> void:
	Global.shake_screen(intensity, duration)


func _on_alert_green_requested(message: String, _duration: float) -> void:
	if alert_label and alert_timer:
		Global.display_green_alert(alert_label, alert_timer, message)


func _on_alert_red_requested(message: String, _duration: float) -> void:
	if alert_label and alert_timer:
		Global.display_red_alert(alert_label, alert_timer, message)


func parse_date(date_string: String) -> Dictionary:
	var parts = date_string.split(".")
	if parts.size() != 3:
		push_error("Invalid date format: " + date_string)
		return {}

	return {"year": parts[0].to_int(), "month": parts[1].to_int(), "day": parts[2].to_int()}


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
		"res://assets/music/opening_wonderlust_intensity.wav",
		"res://assets/music/background_music_1.mp3",
		"res://assets/music/background_music_2.mp3",
		"res://assets/music/background_music_3.mp3",
		"res://assets/music/background_music_4.mp3"
	]


# Ambient audio players
var ambient_office_player: AudioStreamPlayer
var ambient_clock_player: AudioStreamPlayer


func _setup_ambient_audio():
	# Setup office ambient loop
	ambient_office_player = AudioStreamPlayer.new()
	ambient_office_player.name = "AmbientOfficePlayer"
	ambient_office_player.stream = preload("res://assets/audio/ambient/ambient_office_loop.mp3")
	ambient_office_player.bus = "SFX"
	ambient_office_player.volume_db = -18.0  # Subtle background
	ambient_office_player.autoplay = false
	add_child(ambient_office_player)

	# Setup clock tick loop
	ambient_clock_player = AudioStreamPlayer.new()
	ambient_clock_player.name = "AmbientClockPlayer"
	ambient_clock_player.stream = preload("res://assets/audio/ambient/ambient_clock_tick_loop.mp3")
	ambient_clock_player.bus = "SFX"
	ambient_clock_player.volume_db = -24.0  # Very subtle
	ambient_clock_player.autoplay = false
	add_child(ambient_clock_player)

	# Start ambient sounds with a fade-in
	_start_ambient_audio()


func _start_ambient_audio():
	# Fade in ambient office sound
	if ambient_office_player:
		ambient_office_player.volume_db = -40.0
		ambient_office_player.play()
		var office_tween = create_tween()
		office_tween.tween_property(ambient_office_player, "volume_db", -18.0, 3.0)

	# Fade in clock ticking after a short delay
	if ambient_clock_player:
		ambient_clock_player.volume_db = -40.0
		var clock_tween = create_tween()
		clock_tween.tween_callback(ambient_clock_player.play).set_delay(1.5)
		clock_tween.tween_property(ambient_clock_player, "volume_db", -24.0, 2.0)


func stop_ambient_audio():
	# Fade out ambient sounds
	if ambient_office_player and ambient_office_player.playing:
		var tween = create_tween()
		tween.tween_property(ambient_office_player, "volume_db", -40.0, 1.0)
		tween.tween_callback(ambient_office_player.stop)

	if ambient_clock_player and ambient_clock_player.playing:
		var tween = create_tween()
		tween.tween_property(ambient_clock_player, "volume_db", -40.0, 1.0)
		tween.tween_callback(ambient_clock_player.stop)


# Visual feedback system for decisions
func _flash_screen_color(color: Color, duration: float):
	var overlay = ColorRect.new()
	overlay.color = Color(color.r, color.g, color.b, 0.3)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input
	overlay.z_index = 50  # Ensure it's visible but not blocking UI
	add_child(overlay)

	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, duration)
	tween.tween_callback(overlay.queue_free)


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
	if Global.build_type == "Demo" and Global.shift >= 3:
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
	button.pressed.connect(
		func():
			# Return to main menu
			get_tree().change_scene_to_file(
				"res://scenes/menus/main_menu/main_menu_with_animations.tscn"
			)
			# Remove the panel
			demo_panel.queue_free()
	)

	# Add a nice animation
	demo_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(demo_panel, "modulate:a", 1.0, 0.5)


## Plays a fanfare sound when the shift starts
func _play_shift_start_sound() -> void:
	if not $SystemManagers/AudioManager/SFXPool:
		return

	# Use a subtle discovery/ready sound - not too loud or intrusive
	var start_sounds = [
		preload("res://assets/audio/ui_feedback/glockenspiel magic 1.wav"),
		preload("res://assets/audio/ui_feedback/glockenspiel magic 2.wav"),
		preload("res://assets/audio/ui_feedback/glockenspiel magic 3.wav"),
	]

	var sfx_player = $SystemManagers/AudioManager/SFXPool
	sfx_player.stream = start_sounds[randi() % start_sounds.size()]
	sfx_player.volume_db = -8.0  # Subtle but noticeable
	sfx_player.pitch_scale = randf_range(0.95, 1.05)
	sfx_player.play()


## Shows any pending unlock notifications after shift starts
## Delayed to give player time to see them before gameplay gets busy
func _show_pending_unlock_notifications() -> void:
	if not GameStateManager:
		return

	var pending_minigame = GameStateManager.get_and_clear_pending_minigame_unlock()
	if pending_minigame == "":
		return

	# Wait a few seconds after shift starts so player has time to read
	await get_tree().create_timer(2.5).timeout

	# Make sure scene is still valid after the wait
	if not is_instance_valid(self) or is_shift_ending:
		return

	# Show the unlock notification
	var display_name = pending_minigame.replace("_", " ").capitalize()
	EventBus.show_alert(
		tr("alert_new_minigame_unlocked").format({"name": display_name}),
		true, 4.0
	)


## Plays a dramatic failure sound when game over occurs
func _play_game_over_sound() -> void:
	if not $SystemManagers/AudioManager/SFXPool:
		return

	# Use a dramatic fail ensemble for impact
	var fail_sounds = [
		preload("res://assets/audio/ui_feedback/Task Fail Ensemble 001.wav"),
		preload("res://assets/audio/ui_feedback/Task Fail Ensemble 002.wav"),
		preload("res://assets/audio/ui_feedback/Task Fail Ensemble 003.wav"),
		preload("res://assets/audio/ui_feedback/Task Fail Ensemble 004.wav"),
	]

	var sfx_player = $SystemManagers/AudioManager/SFXPool
	sfx_player.stream = fail_sounds[randi() % fail_sounds.size()]
	sfx_player.volume_db = -4.0  # More prominent for dramatic effect
	sfx_player.pitch_scale = randf_range(0.9, 1.0)  # Slightly lower pitch for drama
	sfx_player.play()
