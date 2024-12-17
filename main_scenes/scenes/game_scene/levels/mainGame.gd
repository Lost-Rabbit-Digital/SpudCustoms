extends Node2D

# Add border runner system
var border_runner_system

# Track game states
var close_sound_played = false
var open_sound_played = false
var holding_stamp = false
var is_potato_in_office = false
var game_start_time: float = 0.0

# track the current potato's info
var current_potato_info
var current_potato

# Track win and lose parameters
var difficulty_level

# Track multipliers and streaks
var point_multiplier = 1.0
var correct_decision_streak = 0

# timer for limiting shift processing times
var processing_time = 60  # seconds
var current_timer = 0 # seconds
var original_runner_chance = 0.15  # Match your current chance value


# storing and sending rule assignments
signal rules_updated(new_rules)
var current_rules = []

var queue_manager: Node2D
var megaphone_flash_timer: Timer
const MEGAPHONE_FLASH_INTERVAL = 1.0 # flash every 1 seconds

# Potato spawn manager
var potato_count = 0
var max_potatoes = 20
@onready var spawn_timer = $SystemManagers/Timers/SpawnTimer

#Narrative manager
@onready var narrative_manager = $SystemManagers/NarrativeManager

# Dragging system
var draggable_sprites = []
var dragged_sprite = null
var drag_offset = Vector2()
const PHYSICAL_STAMP_Z_INDEX = 100
const APPLIED_STAMP_Z_INDEX = 50
const PASSPORT_Z_INDEX = 0
var selected_stamp: Node = null  # Tracks which stamp is currently selected
@onready var approval_stamp = $Gameplay/InteractiveElements/ApprovalStamp
@onready var rejection_stamp = $Gameplay/InteractiveElements/RejectionStamp

# Passport dragging system
var passport: Sprite2D
var passport_spawn_point_begin: Node2D
var passport_spawn_point_end: Node2D
var inspection_table: Sprite2D
var suspect_panel: Sprite2D
var suspect_panel_front: Sprite2D
var suspect: Sprite2D
var is_passport_open = false

@onready var time_label = $UI/Labels/TimeLabel
var label_tween: Tween

# Guide dragging system
var guide: Sprite2D
var is_guide_open = false

# Stamp system
const STAMP_ANIMATION_DURATION = 0.3  # Duration of the stamp animation in seconds
const STAMP_MOVE_DISTANCE = 36  # How far the stamp moves down
var is_stamping = false  # Tracks if a stamp animation is in progress
var stamp_cooldown = 1.0  # Cooldown time in seconds after stamp animation
var default_cursor = Input.CURSOR_ARROW

# Guide system
var guide_tutorial_timer: Timer
const GUIDE_TUTORIAL_FLASH_INTERVAL = 1.0 # flash every 1 seconds
var is_in_guide_tutorial = true

# Character Generation
@onready var mugshot_generator = $Gameplay/MugshotPhotoGenerator
@onready var passport_generator = $Gameplay/InteractiveElements/Passport/OpenPassport/PassportPhotoGenerator

@onready var megaphone = $Gameplay/Megaphone
@onready var enter_office_path = $Gameplay/Paths/EnterOfficePath
@onready var stats_manager = $SystemManagers/StatsManager
var shift_stats: ShiftStats
@onready var shift_summary = preload("res://ShiftSummaryScreen.tscn")

## Label used to display alerts and notifications to the player
@onready var alert_label = $UI/Labels/MarginContainer/AlertLabel
@onready var alert_timer = $SystemManagers/Timers/AlertTimer

func _ready():
	$BorderRunnerSystem.game_over_triggered.connect(_on_game_over)
	game_start_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
	update_cursor("default")
	# Make sure to add QueueManager as a child of Main
	queue_manager = $SystemManagers/QueueManager  
	setup_spawn_timer()
	
	shift_stats = stats_manager.get_new_stats()
	Global.score_updated.connect(_on_score_updated)
	difficulty_level = Global.difficulty_level
	set_difficulty(difficulty_level)
	# Store the default cursor shape
	
	update_score_display()
	update_quota_display()
	update_date_display()
	time_label = $UI/Labels/TimeLabel
	
	generate_rules()
	draggable_sprites = [
		$Gameplay/InteractiveElements/Passport,
		$Gameplay/InteractiveElements/Guide,
		$Gameplay/InteractiveElements/ApprovalStamp,
		$Gameplay/InteractiveElements/RejectionStamp
	]
	# Ensure sprites are in the scene tree and set initial z-index
	for sprite in draggable_sprites:
		if not is_instance_valid(sprite):
			push_warning("Sprite not found: " + sprite.name)
		else:
			if "Stamp" in sprite.name:
				sprite.z_index = PHYSICAL_STAMP_Z_INDEX
			else:
				sprite.z_index = PASSPORT_Z_INDEX
				
	if Global.final_score > 0:
		Global.score = Global.final_score
		update_score_display()

	if Global.quota_met > 0:
		update_quota_display()
	# Get references to the new nodes
	passport = $Gameplay/InteractiveElements/Passport
	passport_spawn_point_begin = $Gameplay/InteractiveElements/PassportSpawnPoints/BeginPoint
	passport_spawn_point_end = $Gameplay/InteractiveElements/PassportSpawnPoints/EndPoint
	guide = $Gameplay/InteractiveElements/Guide
	inspection_table = $Gameplay/InspectionTable
	suspect_panel = $Gameplay/SuspectPanel
	suspect_panel_front = $Gameplay/SuspectPanel/SuspectPanelFront
	suspect = $Gameplay/MugshotPhotoGenerator/SizingSprite
	
	$UI/Labels/StrikesLabel.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)

	# Add closed passport to draggable sprites
	draggable_sprites.append(passport)
	draggable_sprites.append(guide)
	
	# add border runner system
	border_runner_system = $BorderRunnerSystem
	
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_finished)
		
	if Global.StoryState.NOT_STARTED:
		# Disable controls during intro
		disable_controls()

func end_shift():
	if Global.quota_met >= Global.quota_target:
		narrative_manager.start_shift_dialogue()
		disable_controls()
	else:
		# Calculate final time taken 
		var elapsed_time = (Time.get_ticks_msec() / 1000.0) - game_start_time
		shift_stats.time_taken = elapsed_time
		shift_stats.processing_time_left = current_timer
		var runner_stats = $BorderRunnerSystem.shift_stats
		var stats = {
			"shift": Global.shift,
			"time_taken": int(shift_stats.time_taken),
			"score": Global.score,
			"missiles_fired": runner_stats.missiles_fired,
			"missiles_hit": runner_stats.missiles_hit,
			"perfect_hits": runner_stats.perfect_hits,
			"total_stamps": shift_stats.total_stamps,
			"potatoes_approved": shift_stats.potatoes_approved,
			"potatoes_rejected": shift_stats.potatoes_rejected,
			"perfect_stamps": shift_stats.perfect_stamps,
			"speed_bonus": shift_stats.get_speed_bonus(),
			"accuracy_bonus": shift_stats.get_accuracy_bonus(),
			"perfect_bonus": shift_stats.get_missile_bonus(),
			"final_score": (Global.score + shift_stats.get_speed_bonus() + shift_stats.get_accuracy_bonus() + shift_stats.get_missile_bonus())
		}
		print("Printing runner stats")
		print(runner_stats)
		print("Printing shift stats")
		print(shift_stats)
		print("Printing stats")
		print(stats)
		Global.store_game_stats(stats)
		var summary = shift_summary.instantiate()
		add_child(summary)
		summary.show_summary(stats)


func setup_megaphone_flash_timer():
	#print("FLASH TIMER: Setup megaphone flash timer")
	megaphone_flash_timer = $SystemManagers/Timers/MegaphoneFlashTimer
	megaphone_flash_timer.wait_time = MEGAPHONE_FLASH_INTERVAL
	megaphone_flash_timer.start()
	
func set_difficulty(level):
	difficulty_level = level
	match difficulty_level:
		"Easy":
			Global.max_strikes = 6
			processing_time = 60
		"Normal":
			Global.max_strikes = 4
			processing_time = 45
		"Expert":
			Global.max_strikes = 3
			processing_time = 30
			
	update_quota_display()
	$UI/Labels/StrikesLabel.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)

func generate_rules():
	current_rules = [
		# Condition-based rules
		"All potatoes must be Fresh!",
		"Extra Eyes are suspicious, inspect carefully and reject.",
		"Rotten potatoes are strictly forbidden.",
		"Sprouted potatoes need additional verification and must be denied.",
		"Dehydrated potatoes are not allowed today.",
		"Frozen potatoes require a special permit.",

		# Age-based rules
		"No potatoes over 5 years old.",
		"Reject potatoes younger than 3 years old.",
		"Young potatoes (under 2 years) need guardian.",

		# Gender-based rules
		"Only male potatoes allowed today.",
		"Female potatoes get exclusive processing, no males.",

		# Country-based rules
		"Potatoes from Spudland must be denied.",
		"Potatopia citizens cannot enter under any circumstances.",
		"Tuberstan potatoes suspected of concealing arms.",
		"North Yamnea is currently under embargo.",
		"Reject Spuddington potatoes because of visa counterfeiting activity.",
		"Tatcross citizens get no entry processing.",
		"Mash Meadows potatoes are subject to quarantine, reject!",
		"Tuberville potatoes subject to absolute rejection.",
		"Chip Hill exports are currently restricted.",
		"Murphyland potatoes need work permit verification. Reject!",
		"Colcannon citizens must be rejected due to seasonings.",
		"Pratie Point potatoes require rejection on agricultural grounds."
	]
	# Randomly select 2-3 rules
	current_rules.shuffle()
	current_rules = current_rules.slice(0, randi() % 2 + 2)
	update_rules_display()

func days_until_expiry(expiration_date: String) -> int:
	var current_date = Time.get_date_dict_from_system()
	var expiry_parts = expiration_date.split('.')
	
	if expiry_parts.size() != 3:
		print("Invalid date format: ", expiration_date)
		return 0
	
	var expiry_year = expiry_parts[0].to_int()
	var expiry_month = expiry_parts[1].to_int()
	var expiry_day = expiry_parts[2].to_int()
	
	var current_unix = Time.get_unix_time_from_datetime_dict(current_date)
	var expiry_unix = Time.get_unix_time_from_datetime_dict({
		"year": expiry_year,
		"month": expiry_month,
		"day": expiry_day,
		"hour": 0,
		"minute": 0,
		"second": 0
	})
	
	var difference_seconds = expiry_unix - current_unix
	return int(difference_seconds / 86400)  # Convert seconds to days

func years_until_expiry(expiration_date: String) -> int:
	return int(days_until_expiry(expiration_date) / 365.25)  # Using 365.25 to account for leap years

func is_expired(expiration_date: String) -> bool:
	return days_until_expiry(expiration_date) < 0

func update_rules_display():
	if $Gameplay/InteractiveElements/Guide/OpenGuide/GuideNote and Guide.current_page == 2:
		$Gameplay/InteractiveElements/Guide/OpenGuide/GuideNote.text = "[center]LAWS\n" + "\n".join(current_rules) + "[/center]"
	# Emit the signal with the new rules
	emit_signal("rules_updated", "[center]LAWS\n" + "\n".join(current_rules) + "[/center]")
	
func is_potato_valid(potato_info: Dictionary) -> bool:
	for rule in current_rules:
		print("Current rule processing: " + rule)
		match rule:
			# Condition-based rules
			"All potatoes must be Fresh!":
				if potato_info.condition != "Fresh":
					return false
			"Extra Eyes are suspicious, inspect carefully and reject.":
				if potato_info.condition == "Extra Eyes":
					return false
			"Rotten potatoes are strictly forbidden.":
				if potato_info.condition == "Rotten":
					return false
			"Sprouted potatoes need additional verification and must be denied":
				if potato_info.condition == "Sprouted":
					return false
			"Dehydrated potatoes are not allowed today.":
				if potato_info.condition == "Dehydrated":
					return false
			"Frozen potatoes require a special permit.":
				if potato_info.condition == "Frozen":
					return false
			# Age-based rules
			"No potatoes over 5 years old.":
				var age = calculate_age(potato_info.date_of_birth)
				print("Age is ", str(age))
				if age >= 5:
					return false
			"Reject potatoes younger than 3 years old.":
				var age = calculate_age(potato_info.date_of_birth)
				print("Age is ", str(age))
				if age <= 3:
					return false
			"Young potatoes (under 2 years) need guardian.":
				var age = calculate_age(potato_info.date_of_birth)
				print("Age is ", str(age))
				if age <= 2:
					return false
			# Sex-based rules
			"Only male potatoes allowed today.":
				if potato_info.sex == "Female":
					return false
			"Female potatoes get exclusive processing, no males.":
				print("Your potato is: ", potato_info.sex)
				if potato_info.sex == "Male":
					return false
			# Country-based rules
			"Potatoes from Spudland must be denied.":
				if potato_info.country_of_issue == "Spudland":
					return false
			"Potatopia citizens need additional screening.":
				if potato_info.country_of_issue == "Potatopia":
					return false			
			"Tuberstan potatoes suspected of concealing arms.":
				if potato_info.country_of_issue == "Tuberstan":
					return false			
			"North Yamnea is currently under embargo.":
				if potato_info.country_of_issue == "North Yamnea":
					return false			
			"Reject Spuddington potatoes because of visa counterfeiting activity.":
				if potato_info.country_of_issue == "Spuddington":
					return false
			"Tatcross citizens get no entry processing.":
				if potato_info.country_of_issue == "Tatcross":
					return false			
			"Mash Meadows potatoes are subject to quarantine, reject!":
				if potato_info.country_of_issue == "Mash Meadows":
					return false
			"Tuberville potatoes subject to absolute rejection.":
				if potato_info.country_of_issue == "Tuberville":
					return false
			"Chip Hill exports are currently restricted.":
				if potato_info.country_of_issue == "Chip Hill":
					return false
			"Murphyland potatoes need work permit verification. Reject!":
				if potato_info.country_of_issue == "Murphyland":
					return false
			"Colcannon citizens must be rejected due to seasonings.":
				if potato_info.country_of_issue == "Colcannon":
					return false
			"Pratie Point potatoes require rejection on agricultural grounds.":
				if potato_info.country_of_issue == "Pratie Point":
					return false
	print("INFO: This potato should be allowed in, returning true.")
	return true

func update_date_display():
	var current_date = Time.get_date_dict_from_system()
	var formatted_date = "%04d.%02d.%02d" % [current_date.year, current_date.month, current_date.day]
	$UI/Labels/DateLabel.text = formatted_date

func play_random_customs_officer_sound():
	var customs_officer_sounds = [
		preload("res://assets/audio/froggy_phrase_1.wav"),
		preload("res://assets/audio/froggy_phrase_2.wav"),
		preload("res://assets/audio/froggy_phrase_3.wav"),
		preload("res://assets/audio/froggy_phrase_4.wav"),
		preload("res://assets/audio/froggy_phrase_5.wav"),
		preload("res://assets/audio/froggy_phrase_6.wav"),
		preload("res://assets/audio/froggy_phrase_7.wav")
	]
	# Play potato customs officer sound
	if !$SystemManagers/AudioManager/SFXPool.is_playing():
		$SystemManagers/AudioManager/SFXPool.stream = customs_officer_sounds.pick_random()
		$SystemManagers/AudioManager/SFXPool.play()
		
func say_random_customs_officer_dialogue():
	var customs_officer_dialogue = [
		preload("res://assets/megaphone/megaphone_dialogue_box_2.png"),
		preload("res://assets/megaphone/megaphone_dialogue_box_3.png"),
		preload("res://assets/megaphone/megaphone_dialogue_box_4.png"),
		preload("res://assets/megaphone/megaphone_dialogue_box_5.png"),
		preload("res://assets/megaphone/megaphone_dialogue_box_6.png")
	]
	$Gameplay/Megaphone/MegaphoneDialogueBoxBlank.visible = true
	$Gameplay/Megaphone/MegaphoneDialogueBoxBlank.texture = customs_officer_dialogue.pick_random()
		
		
func megaphone_clicked():
	if is_potato_in_office:
		play_random_customs_officer_sound()
		say_random_customs_officer_dialogue()
		print("Warning: A potato is already in the customs office!")
		return
		
	queue_manager = $SystemManagers/QueueManager
	play_random_customs_officer_sound()
	print("Megaphone clicked")
	var potato_person = queue_manager.remove_front_potato()
	if potato_person != null:
		$Gameplay/Megaphone/MegaphoneDialogueBoxBlank.visible = true
		$Gameplay/Megaphone/MegaphoneDialogueBoxBlank.texture = preload("res://assets/megaphone/megaphone_dialogue_box_1.png")
		is_potato_in_office = true
		megaphone.visible = true
		passport.visible = false
		current_potato_info = generate_potato_info()
		
		# Now randomize the character when they actually enter the office
		if mugshot_generator:
			mugshot_generator.randomise_character()
			current_potato_info.character_data = mugshot_generator.get_character_data()
			
			# Update passport generator with the same data
			if passport_generator:
				passport_generator.set_character_data(current_potato_info.character_data)
		
		move_potato_to_office(potato_person)
	else:
		$Gameplay/Megaphone/MegaphoneDialogueBoxBlank.visible = true
		$Gameplay/Megaphone/MegaphoneDialogueBoxBlank.texture = preload("res://assets/megaphone/megaphone_dialogue_box_7.png")
		print("No potato to process. :(")

func move_potato_to_office(potato_person):
	print("Moving our spuddy to the customs office")
	if potato_person.get_parent():
		potato_person.get_parent().remove_child(potato_person)
		print("removed potato from original parent")
		
	var path_follow = PathFollow2D.new()
	path_follow.rotates = false 
	enter_office_path.add_child(path_follow)
	path_follow.add_child(potato_person)
	print("Added potato_person to new PathFollow2D")
	
	potato_person.position = Vector2.ZERO
	path_follow.progress_ratio = 0.0
	print("Reset potato position and path progress") 
		
	var tween = create_tween()
	tween.tween_property(path_follow, "progress_ratio", 1.0, 1.0)
	tween.tween_callback(func():
		print("Potato reached end of path, clean up")
		potato_person.queue_free()
		path_follow.queue_free()
		animate_mugshot_and_passport()
		)
	print("Started animate mugshot and passport tween animation")
	
func animate_mugshot_and_passport():
	print("Animating mugshot and passport")
	update_potato_info_display()

	# Reset positions and visibility
	mugshot_generator.position.x = suspect_panel.position.x + suspect_panel_front.texture.get_width()
	passport.visible = false
	passport.z_index = 1
	passport.position = Vector2(passport_spawn_point_begin.position.x, passport_spawn_point_begin.position.y)

	var tween = create_tween()
	tween.set_parallel(true)

	# Animate potato mugshot
	tween.tween_property(mugshot_generator, "position:x", suspect_panel.position.x, 1)
	tween.tween_property(mugshot_generator, "modulate:a", 1, 1)
	
	# Animate passport
	tween.tween_property(passport, "modulate:a", 1, 2)
	tween.tween_property(passport, "visible", true, 0).set_delay(1)
	tween.tween_property(passport, "position:y", passport_spawn_point_end.position.y, 1).set_delay(2)
	tween.tween_property(passport, "z_index", 5, 0).set_delay(3)

	tween.chain().tween_callback(func(): print("Finished animating mugshot and passport"))
	
func setup_spawn_timer():
	spawn_timer = Timer.new()
	spawn_timer.set_wait_time(1.0)
	spawn_timer.set_one_shot(false)
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if queue_manager.can_add_potato():
		queue_manager.spawn_new_potato()
	else:
		print("Potato queue limit reached, skip spawning.")
		#spawn_timer.stop()

func start_label_tween():
	stop_label_tween()
	
	label_tween = create_tween().set_loops()
	
	if not label_tween or not time_label:
		print("Error: Failed to create tween or time_label not found")
		return
	
	label_tween.tween_property(time_label, "theme_override_font_sizes/font_size", 32, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	label_tween.tween_property(time_label, "theme_override_font_sizes/font_size", 24, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	label_tween.parallel().tween_property(time_label, "theme_override_colors/font_color", Color.RED, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	label_tween.tween_property(time_label, "theme_override_colors/font_color", Color("#ffc7a7"), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

var font = load("res://assets/fonts/Modern_DOS_Font_Variation.tres")
func reset_time_label():
	# Set font size
	time_label.add_theme_font_size_override("font_size", 32)
	# Set font
	time_label.add_theme_font_override("font", font)
	# Set color
	time_label.add_theme_color_override("font_color", Color("#ffc7a7"))
	
	if time_label:
		time_label.visible = false

# Add this new function to stop the label tween
func stop_label_tween():
	if label_tween:
		label_tween.kill()
		label_tween = null
	reset_time_label()

			# Implicit rejection of potatos via the process_decision(false) function 
			# carries the risk of accidentally passing a potato and improving player score
			# This should be its' own force_decision(), maybe where the Supervisor says 
			# what the right answer was too before punishing the player.
			# Time's up, force a decision or penalize the player
			# move_potato_along_path(approval_status) controls moving the player based on approval status
			# We can add a new approval status (timed_out), and have the potato take a different route. 
			# we can put that logic as well as the logic for adding a strike into the force_decision() function

func update_cursor(type):
	match type:
		"default":
			Input.set_custom_mouse_cursor(load("res://assets/cursor/cursor_default.png"), Input.CURSOR_ARROW, Vector2(0, 0))
		"hover":
			Input.set_custom_mouse_cursor(load("res://assets/cursor/cursor_hover.png"), Input.CURSOR_POINTING_HAND, Vector2(0, 0))
		"grab":
			Input.set_custom_mouse_cursor(load("res://assets/cursor/cursor_grab.png"), Input.CURSOR_DRAG, Vector2(0, 0))
		"click":
			Input.set_custom_mouse_cursor(load("res://assets/cursor/cursor_click.png"), Input.CURSOR_POINTING_HAND, Vector2(0, 0))
		"target":
			Input.set_custom_mouse_cursor(load("res://assets/cursor/cursor_target.png"), Input.CURSOR_CROSS, Vector2(0, 0))

func get_area2d_size(area2d):
	var collision_shape = area2d.get_node("CollisionShape2D")
	if collision_shape:
		var shape = collision_shape.get_shape()
		if shape is RectangleShape2D:
			var extents = shape.extents
			var size = extents * 2
			return size
	return Vector2.ZERO

func check_cursor_status(mouse_pos):
	if passport.get_rect().has_point(passport.to_local(mouse_pos)):
		update_cursor("hover")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			update_cursor("grab")
	elif guide.get_rect().has_point(guide.to_local(mouse_pos)):
		update_cursor("hover")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			update_cursor("grab")
	elif approval_stamp.get_rect().has_point(approval_stamp.to_local(mouse_pos)):
		update_cursor("hover")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			update_cursor("grab")
	elif rejection_stamp.get_rect().has_point(rejection_stamp.to_local(mouse_pos)):
		update_cursor("hover")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			update_cursor("grab")
	elif holding_stamp or dragged_sprite == passport or dragged_sprite == guide:
		update_cursor("grab")
	elif megaphone.get_rect().has_point(megaphone.to_local(mouse_pos)):
		update_cursor("click")
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			update_cursor("grab")
	else:
		if border_runner_system and border_runner_system.is_enabled:
			var missile_zone = border_runner_system.get_missile_zone()
			if missile_zone and missile_zone.has_point(mouse_pos):
				update_cursor("target")
				return
		update_cursor("default")
			
	
func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	check_cursor_status(mouse_pos)
	
	# Processing timer implementation
	if is_potato_in_office:
		# Show label if potato in customs office
		if not time_label.visible:
			reset_time_label()
			time_label.visible = true
		
		current_timer += _delta
		var remaining_time = int(processing_time) - int(current_timer)
		time_label.text = "Time Left: %s" % str(remaining_time)
		
		# Only start the tween effect when less than 5 seconds remain
		if remaining_time < 5 and not label_tween:
			start_label_tween()
		elif remaining_time >= 5 and label_tween:
			# Stop the tween if it's running and we're back above 5 seconds
			stop_label_tween()
		
		if int(current_timer) >= int(processing_time):
			move_potato_along_path("timed_out")
			is_potato_in_office = false
	else:
		# Hide label if potato is not in/has left customs office
		if time_label.visible:
			stop_label_tween()
			reset_time_label()
		current_timer = 0

	if suspect.get_rect().has_point(suspect.to_local(mouse_pos)) and dragged_sprite == passport and is_passport_open == false:
		$Gameplay/InteractiveElements/Passport/ClosedPassport/GivePromptDialogue.visible = true
	else:
		$Gameplay/InteractiveElements/Passport/ClosedPassport/GivePromptDialogue.visible = false
		
	if !$SystemManagers/AudioManager/SFXPool.is_playing():
		$Gameplay/Megaphone/MegaphoneDialogueBoxBlank.visible = false
	
	# Check for closing passport
	if (suspect.get_rect().has_point(suspect.to_local(mouse_pos)) or suspect_panel_front.get_rect().has_point(suspect_panel_front.to_local(mouse_pos)))and (dragged_sprite == passport or dragged_sprite == guide):
		if not close_sound_played:
			if dragged_sprite == passport:
				close_passport_action()
			elif dragged_sprite == guide:
				close_guide_action()
			$SystemManagers/AudioManager/SFXPool.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
			$SystemManagers/AudioManager/SFXPool.play()
			close_sound_played = true
			open_sound_played = false  # Reset open sound flag
	
	# Check for opening passport
	if inspection_table.get_rect().has_point(inspection_table.to_local(mouse_pos)) and (dragged_sprite == passport or dragged_sprite == guide):
		if not open_sound_played:
			if dragged_sprite == passport and is_passport_open == false:
				open_passport_action()
			elif dragged_sprite == guide:
				open_guide_action()
			$SystemManagers/AudioManager/SFXPool.stream = preload("res://assets/audio/passport_sfx/open_passport_audio.mp3")
			$SystemManagers/AudioManager/SFXPool.play()
			open_sound_played = true
			close_sound_played = false  # Reset close sound flag
			

func generate_potato_info():
	var expiration_date: String
	if randf() < 0.2:
		expiration_date = get_past_date(0, 3)
	else:
		expiration_date = get_future_date(0,3)
		
	# Generate gender first since it affects character generation
	var gender = get_random_sex()
	
	# Generate character appearance only when creating new potato info
	var character_data = {}
	if mugshot_generator:
		mugshot_generator.set_gender("F" if gender == "Female" else "M")
		# This will now only happen when a new potato is called in
		character_data = mugshot_generator.get_character_data()
		
		# Also update passport generator
		if passport_generator:
			passport_generator.set_character_data(character_data)
	
	return {
		"name": get_random_name(),
		"condition": get_random_condition(),
		"sex": gender,
		"country_of_issue": get_random_country(),
		"date_of_birth": get_past_date(1, 10),
		"expiration_date": expiration_date,
		"character_data": character_data
	}
func update_potato_info_display():
	print("Printing current potato info")
	print(current_potato_info)
	if current_potato_info:
		$Gameplay/InteractiveElements/Passport/OpenPassport/PotatoHeader.text = """{name}""".format(current_potato_info)
		$Gameplay/InteractiveElements/Passport/OpenPassport/PotatoInfo.text = """{date_of_birth}
		{sex} 
		{country_of_issue}
		{expiration_date} 
		{condition}
		""".format(current_potato_info)
	else:
		print("No current_potato_info found.")
	print("Potato info update complete")
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
	$UI/Labels/ScoreLabel.text = "Score: " + str(new_score)

func _on_button_welcome_button_pressed() -> void:
	process_decision(true)

func _on_button_no_entry_button_pressed() -> void:
	process_decision(false)

	
func go_to_game_win():
	print("Transitioning to game win scene with score:", Global.score)
	#$Gameplay/InteractiveElements/ApprovalStamp.visible = false
	#$Gameplay/InteractiveElements/RejectionStamp.visible = false
	Global.final_score = Global.score
	Global.shift += 1
	print("ALERT: go_to_game_win() has been disabled")
	# Use change_scene_to_packed to pass parameters
	#var success_scene = preload("res://menus/success_scene.tscn")
	#get_tree().change_scene_to_packed(success_scene)
	# Store the score in a global script or autoload

func timed_out():
	# Alert the player
	Global.display_red_alert(alert_label, alert_timer, "You took too long and they left, officer... \n+1 Strike!")
	
	# Reset stats and add strike
	correct_decision_streak = 0
	point_multiplier = 1.0
	Global.strikes += 1
	if Global.strikes >= Global.max_strikes:
		# Calculate final time taken 
		var elapsed_time = (Time.get_ticks_msec() / 1000.0) - game_start_time
		shift_stats.time_taken = elapsed_time
		shift_stats.processing_time_left = current_timer
		var runner_stats = $BorderRunnerSystem.shift_stats
		var stats = {
			"shift": Global.shift,
			"time_taken": int(shift_stats.time_taken),
			"score": Global.score,
			"missiles_fired": runner_stats.missiles_fired,
			"missiles_hit": runner_stats.missiles_hit,
			"perfect_hits": runner_stats.perfect_hits,
			"total_stamps": shift_stats.total_stamps,
			"potatoes_approved": shift_stats.potatoes_approved,
			"potatoes_rejected": shift_stats.potatoes_rejected,
			"perfect_stamps": shift_stats.perfect_stamps,
			"speed_bonus": shift_stats.get_speed_bonus(),
			"accuracy_bonus": shift_stats.get_accuracy_bonus(),
			"perfect_bonus": shift_stats.get_missile_bonus(),
			"final_score": (Global.score + shift_stats.get_speed_bonus() + shift_stats.get_accuracy_bonus() + shift_stats.get_missile_bonus())
		}
		print("Printing runner stats")
		print(runner_stats)
		print("Printing shift stats")
		print(shift_stats)
		print("Printing stats")
		print(stats)
		Global.store_game_stats(stats)
		var summary = shift_summary.instantiate()
		add_child(summary)
		summary.show_summary(stats)
			
	# Update displays
	update_score_display()
	$UI/Labels/StrikesLabel.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)
	
	# Add another potato
	if queue_manager.can_add_potato() and spawn_timer.is_stopped():
		spawn_timer.start()
	
	# Animate the exit
	var passport_book = $Gameplay/InteractiveElements/Passport
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(mugshot_generator, "position:x", suspect_panel.position.x - suspect.get_rect().size.x, 1)
	tween.tween_property(mugshot_generator, "modulate:a", 0, 1)
	tween.tween_property(passport_book, "modulate:a", 0, 1)
	
	# Clear the stamps
	close_passport_action()
	remove_stamp()

func process_decision(allowed):
	print("Evaluating immigration decision in process_decision()...")
	if !current_potato_info or current_potato_info.is_empty():
		print("No potato to process.")
		return
		
	var correct_decision = is_potato_valid(current_potato_info)
	
	# Update stats
	if allowed:
		shift_stats.potatoes_approved += 1
	else:
		shift_stats.potatoes_rejected += 1
	
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		Global.quota_met += 1
		correct_decision_streak += 1
		
		# Check if quota met
		if Global.quota_met >= Global.quota_target:
			print("Quota complete!")
			end_shift()
			#go_to_game_win() # TODO: ENABLE FOR FULL RELEASE
		
		# Increase multiplier for streaks
		if correct_decision_streak >= 3:
			point_multiplier = 1.5
		if correct_decision_streak >= 5:
			point_multiplier = 2.0
			
		# Award points for correct decisions, with bonus points for consecutive
		# correct decisions
		# UV scanning will award 250 points per finding
		var decision_points = 250 * point_multiplier
		Global.display_green_alert(alert_label, alert_timer, "You made the right choice, officer.\n+" + str(decision_points) + " points!")
		Global.add_score(decision_points)
	else:
		Global.display_red_alert(alert_label, alert_timer, "You have caused unnecessary suffering, officer...\n+1 Strike!")
		correct_decision_streak = 0
		point_multiplier = 1.0
		Global.strikes += 1
		if Global.strikes >= Global.max_strikes:
			# Calculate final time taken
			shift_stats.time_taken = processing_time - current_timer
			shift_stats.processing_time_left = current_timer
			# Store stats before transitioning
			Global.store_game_stats(shift_stats)
			Global.go_to_game_over()
			
			
	update_score_display()
	update_quota_display()
	$UI/Labels/StrikesLabel.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)

	if queue_manager.can_add_potato() and spawn_timer.is_stopped():
		spawn_timer.start()

func update_score_display():
	$UI/Labels/ScoreLabel.text = "Score: " + str(Global.score)
	if point_multiplier > 1.0:
		$UI/Labels/ScoreLabel.text += " (x" + str(point_multiplier) + ")"

func update_quota_display():
	$UI/Labels/QuotaLabel.text = "Quota: " + str(Global.quota_met) + " / " + str(Global.quota_target * Global.shift)

func update_potato_texture():
	print("Updating potato textures with character generator")
	
	if current_potato_info == null or current_potato_info.is_empty():
		print("No valid potato info available")
		clear_potato_textures()
		return
	
	if !mugshot_generator or !passport_generator:
		print("ERROR: Character generators not found!")
		return
	
	# Use the stored character data from potato_info
	if current_potato_info.has("character_data"):
		mugshot_generator.set_character_data(current_potato_info.character_data)
		passport_generator.set_character_data(current_potato_info.character_data)
	else:
		print("ERROR: No character data found in potato_info!")
		
	print("Character display updated")

func clear_potato_textures():
	if mugshot_generator:
		# Reset to default state or hide
		mugshot_generator.set_gender("M")  # Reset to default gender
		
	if passport_generator:
		# Reset to default state or hide
		passport_generator.set_gender("M")  # Reset to default gender
	
func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = get_global_mouse_position()
		
		# Handle left click press
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if megaphone.get_rect().has_point(megaphone.to_local(mouse_pos)):
				megaphone_clicked()
				return
			
			# Try to pick up an object (stamp or document)
			if not holding_stamp and dragged_sprite == null:
				dragged_sprite = find_topmost_sprite_at(mouse_pos)
				if dragged_sprite:
					drag_offset = mouse_pos - dragged_sprite.global_position
					if "Stamp" in dragged_sprite.name:
						holding_stamp = true
		
		# Handle right click - stamps if over passport
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if holding_stamp and not is_stamping:
				var stamped_object = find_stampable_object_at(mouse_pos)
				if stamped_object:
					apply_stamp(dragged_sprite)
		
		# Handle left click release
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if holding_stamp:
				# Drop the stamp
				holding_stamp = false
			elif dragged_sprite == passport:
				handle_passport_drop(mouse_pos)
			elif dragged_sprite == guide:
				handle_guide_drop(mouse_pos)
			
			dragged_sprite = null
	
	# Handle mouse motion for dragging any object
	elif event is InputEventMouseMotion and dragged_sprite:
		dragged_sprite.global_position = get_global_mouse_position() - drag_offset
		if holding_stamp:
			var stamp_shadow = dragged_sprite.get_node_or_null("StampShadow")
			if stamp_shadow:
				stamp_shadow.visible = true

func handle_passport_drop(mouse_pos: Vector2):
	$Gameplay/InteractiveElements/Passport/ClosedPassport/GivePromptDialogue.visible = false
	if inspection_table.get_rect().has_point(inspection_table.to_local(mouse_pos)):
		open_passport_action()
	elif suspect_panel.get_rect().has_point(suspect_panel.to_local(mouse_pos)):
		close_passport_action()
	elif suspect.get_rect().has_point(suspect.to_local(mouse_pos)):
		close_passport_action()
		remove_stamp()

func handle_guide_drop(mouse_pos: Vector2):
	if inspection_table.get_rect().has_point(inspection_table.to_local(mouse_pos)):
		open_guide_action()
	elif suspect_panel.get_rect().has_point(suspect_panel.to_local(mouse_pos)):
		close_guide_action()
	elif suspect.get_rect().has_point(suspect.to_local(mouse_pos)):
		close_guide_action()

func open_passport_action():
	$Gameplay/InteractiveElements/Passport.texture = preload("res://assets/documents/passport-old.png")
	$Gameplay/InteractiveElements/Passport/ClosedPassport.visible = false
	$Gameplay/InteractiveElements/Passport/OpenPassport.visible = true
	
func close_passport_action():
	$Gameplay/InteractiveElements/Passport.texture = preload("res://assets/documents/closed_passport_small/closed_passport_small.png")
	$Gameplay/InteractiveElements/Passport/ClosedPassport.visible = true
	$Gameplay/InteractiveElements/Passport/OpenPassport.visible = false
	
	# Center the passport on the cursor
	var mouse_pos = get_global_mouse_position()
	var passport_rect = $Gameplay/InteractiveElements/Passport.get_rect()
	var offset = passport_rect.size / 2
	$Gameplay/InteractiveElements/Passport.global_position = mouse_pos - offset
	
func open_guide_action():
	$Gameplay/InteractiveElements/Guide.texture = preload("res://assets/documents/customs_guide/customs_guide_open_2.png")
	$Gameplay/InteractiveElements/Guide/ClosedGuide.visible = false
	$Gameplay/InteractiveElements/Guide/OpenGuide.visible = true
	
func close_guide_action():
	$Gameplay/InteractiveElements/Guide.texture = preload("res://assets/documents/customs_guide/customs_guide_closed_small.png")
	$Gameplay/InteractiveElements/Guide/ClosedGuide.visible = true
	$Gameplay/InteractiveElements/Guide/OpenGuide.visible = false
	
func find_topmost_sprite_at(pos: Vector2) -> Node2D:
	var topmost_sprite = null
	var highest_z = -1
	
	for sprite in draggable_sprites:
		if sprite.visible and sprite.get_rect().has_point(sprite.to_local(pos)):
			if sprite.z_index > highest_z:
				highest_z = sprite.z_index
				topmost_sprite = sprite
	
	return topmost_sprite

func play_random_stamp_sound():
	var stamp_sounds = [
		preload("res://assets/audio/stamp_sound_1.mp3"),
		preload("res://assets/audio/stamp_sound_2.mp3"),
		preload("res://assets/audio/stamp_sound_3.mp3"),
		preload("res://assets/audio/stamp_sound_4.mp3"),
		preload("res://assets/audio/stamp_sound_5.mp3")
	]
	if !$SystemManagers/AudioManager/SFXPool.is_playing():
		$SystemManagers/AudioManager/SFXPool.stream = stamp_sounds.pick_random()
		$SystemManagers/AudioManager/SFXPool.play()

func apply_stamp(stamp):
	if is_stamping:
		return
	if not stamp or not is_instance_valid(stamp):
		print("ERROR: Invalid stamp object")
		return
		
	var mouse_pos = get_global_mouse_position()
	var stamped_object = find_stampable_object_at(mouse_pos)
	
	if not stamped_object:
		return
		
	# Proceed with stamping
	is_stamping = true
	
	# Don't reset holding states since we want to keep holding the stamp
	# holding_stamp remains true
	# dragged_sprite remains set
	
	var open_passport = $Gameplay/InteractiveElements/Passport/OpenPassport
	if not open_passport:
		print("ERROR: Cannot find OpenPassport node")
		is_stamping = false
		return
	
	# Create a temporary visual stamp for the animation
	var temp_stamp = Sprite2D.new()
	if stamp.texture:
		temp_stamp.texture = stamp.texture
		temp_stamp.position = mouse_pos
		temp_stamp.z_index = PHYSICAL_STAMP_Z_INDEX
		add_child(temp_stamp)
	else:
		print("ERROR: Stamp has no texture")
		is_stamping = false
		return
	
	# Create the final stamp that will be left on the passport
	var final_stamp = Sprite2D.new()
	var stamp_texture_path = "res://assets/stamps/approved_stamp.png" if "Approval" in stamp.name else "res://assets/stamps/denied_stamp.png"
	var stamp_texture = load(stamp_texture_path)
	
	if not stamp_texture:
		print("ERROR: Could not load stamp texture: ", stamp_texture_path)
		temp_stamp.queue_free()
		is_stamping = false
		return
		
	final_stamp.texture = stamp_texture
	final_stamp.position = stamped_object.to_local(mouse_pos)
	final_stamp.z_index = APPLIED_STAMP_Z_INDEX
	final_stamp.modulate.a = 0  # Start invisible
	open_passport.add_child(final_stamp)
	
	# Store original stamp position to return to after animation
	var original_stamp_pos = stamp.global_position
	
	# Temporarily hide the held stamp during animation
	stamp.visible = false
	
	# Create and start the animation
	var tween = create_tween()
	tween.set_parallel(true)
	play_random_stamp_sound()
	
	# Move down
	tween.tween_property(temp_stamp, "position:y", 
		temp_stamp.position.y + STAMP_MOVE_DISTANCE, 
		STAMP_ANIMATION_DURATION / 2)
	
	# Fade in the final stamp when we hit the paper
	tween.tween_property(final_stamp, "modulate:a", 
		1.0, 0.1).set_delay(STAMP_ANIMATION_DURATION / 2)
	
	# Move back up
	tween.chain().tween_property(temp_stamp, "position:y", 
		temp_stamp.position.y, 
		STAMP_ANIMATION_DURATION / 2)
	shift_stats.total_stamps += 1
	
	# Check accuracy
	var is_perfect = stats_manager.check_stamp_accuracy(
		final_stamp.global_position,
		open_passport
	)
	
	if is_perfect:
		shift_stats.perfect_stamps += 1
		Global.add_score(100)  # Bonus for perfect stamp
		# Maybe add visual/audio feedback for perfect placement
	
	# Remove the temporary stamp and restore the held stamp
	tween.chain().tween_callback(func():
		# Cleanup temp stamp
		if is_instance_valid(temp_stamp):
			temp_stamp.queue_free()
		
		# Restore the held stamp
		if stamp and is_instance_valid(stamp):
			stamp.visible = true
			stamp.global_position = get_global_mouse_position() - drag_offset
			
		# Set up cooldown
		var cooldown_timer = get_tree().create_timer(stamp_cooldown)
		cooldown_timer.timeout.connect(func(): 
			is_stamping = false
		)
	)
		
func remove_stamp():
	print("Processing passport...")
	# Get the parent node
	var open_passport = $Gameplay/InteractiveElements/Passport/OpenPassport
	var stamp_count = 0
	var approval_status = null
	
	# Check for stamps and determine approval status
	for child in open_passport.get_children():
		if "@Sprite2D@" in child.name:
			stamp_count += 1
			if "approved" in child.texture.resource_path:
				approval_status = "approved"
			else:
				approval_status = "rejected"
			open_passport.remove_child(child)
			child.queue_free()

	if stamp_count == 0:
		print("There are no stamps, foolish potato.")
		return

	print("This passport has been processed as %s" % approval_status)
	
	var passport_book = $Gameplay/InteractiveElements/Passport
	# Animate the potato mugshot and passport exit
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(mugshot_generator, "position:x", suspect_panel.position.x - suspect.get_rect().size.x, 1)
	tween.tween_property(mugshot_generator, "modulate:a", 0, 1)
	tween.tween_property(passport_book, "modulate:a", 0, 1)
	tween.chain().tween_callback(func(): 
		move_potato_along_path(approval_status)
		is_potato_in_office = false
	)
	
func move_potato_along_path(approval_status):
	if current_potato_info == null:
		print("Error: No potato info available")
		return
		
	var path: Path2D
	
	# Set texture
	var PotatoScene = load("res://PotatoPerson.tscn")
	var potato_person = PotatoScene.instantiate()
	
	# Get all available paths
	var approve_paths_node = $Gameplay/Paths/ApprovePaths
	var reject_paths_node = $Gameplay/Paths/RejectionPaths
	var available_approve_paths = []
	var available_reject_paths = []
	
	# Collect all valid approve paths
	for child in approve_paths_node.get_children():
		if child.name.begins_with("ApprovePath"):
			available_approve_paths.append(child)
			
	# Collect all valid reject paths
	for child in reject_paths_node.get_children():
		if child.name.begins_with("RejectPath"):
			available_reject_paths.append(child)
	
	# set path based on approval status
	if approval_status == "approved":
		if available_approve_paths.is_empty():
			push_error("No approve paths found!")
			return
		# Randomly select an approve path
		path = available_approve_paths[randi() % available_approve_paths.size()]
		print("Selected approve path: ", path.name)
		process_decision(true)
	elif approval_status == "timed_out":
		path = available_reject_paths[randi() % available_reject_paths.size()]
		timed_out()
	else:
		# Increase chance of runner when rejected
		if randf() < 0.15:  # 15% chance to go runner mode
			# Instead of using the runner path directly,
			# trigger the border runner system
			if border_runner_system:
				# Pass the potato person to the border runner system
				border_runner_system.force_start_runner(potato_person)
				return  # Exit early as border runner system handles the potato
			else:
				print("ERROR: Border runner system not found!")
				if !available_reject_paths.is_empty():
					path = available_reject_paths[randi() % available_reject_paths.size()]
				else:
					push_error("No reject paths found!")
					return
		else:
			if available_reject_paths.is_empty():
				push_error("No reject paths found!")
				return
			# Randomly select a reject path
			path = available_reject_paths[randi() % available_reject_paths.size()]
			print("Selected reject path: ", path.name)
			process_decision(false)
			
	# Calculate score change
	var path_follow = PathFollow2D.new()
	path_follow.rotates = false
	path.add_child(path_follow)
	path_follow.add_child(potato_person)
	
	path_follow.progress_ratio = 0.0
	
	passport = $Gameplay/InteractiveElements/Passport
	passport.modulate.a = 0
	
	var runner_time = randi_range(7, 11)
	
	var exit_tween = create_tween()
	if "Approve" in path.name:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 8.0)
	elif "Reject" in path.name:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 8.0)
	elif "TimedOut" in path.name:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 8.0)
	else:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, runner_time)
		
	exit_tween.tween_callback(func():
		potato_person.queue_free()
		path_follow.queue_free()
		reset_scene()
	)

func reset_scene():
	mugshot_generator.position.x = suspect_panel.position.x
	$UI/Labels/JudgementLabel.text = ""
	
func find_stampable_object_at(pos: Vector2):
	for sprite in draggable_sprites:
		if "Passport" in sprite.name and sprite.get_rect().has_point(sprite.to_local(pos)):
			return sprite
	return null

func get_highest_z_index():
	var highest = 0
	for sprite in draggable_sprites:
		highest = max(highest, sprite.z_index)
	return highest

func _exit_tree():
	# Ensure cursor is restored when leaving the scene
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_dialogue_started():
	disable_controls()


func _on_dialogue_finished():
	Global.quota_met = 0
	Global.strikes = 0
	enable_controls()
	
	if Global.StoryState.COMPLETED:
		# Game complete, show credits or return to menu
		get_tree().change_scene_to_file("res://main_scenes/scenes/menus/credits/credits.tscn")
	
func disable_controls():
	# Disable player interaction during dialogue
	set_process_input(false)
	$Gameplay/Megaphone.visible = false
	$Gameplay/InteractiveElements/ApprovalStamp.visible = false  
	$Gameplay/InteractiveElements/RejectionStamp.visible = false
	$Gameplay/InteractiveElements/Guide.visible = false
	$Gameplay/InteractiveElements/Passport.visible = false
	# Disable border runner system and set spawn chance to 0
	if border_runner_system:
		border_runner_system.disable()
		border_runner_system.runner_chance = 0.0

func enable_controls():
	# Re-enable controls after dialogue
	set_process_input(true)
	$Gameplay/Megaphone.visible = true
	$Gameplay/InteractiveElements/ApprovalStamp.visible = true
	$Gameplay/InteractiveElements/RejectionStamp.visible = true 
	$Gameplay/InteractiveElements/Guide.visible = true
	# Re-enable border runner system and restore original spawn chance
	if border_runner_system:
		border_runner_system.enable()
		border_runner_system.runner_chance = original_runner_chance
		
func _on_game_over():
	var elapsed_time = (Time.get_ticks_msec() / 1000.0) - game_start_time
	var runner_stats = $BorderRunnerSystem.shift_stats
	var stats = {
		"shift": Global.shift,
		"time_taken": elapsed_time,
		"score": Global.score,
		"missiles_fired": runner_stats.missiles_fired,
		"missiles_hit": runner_stats.missiles_hit,
		"perfect_hits": runner_stats.perfect_hits,
		"total_stamps": shift_stats.total_stamps,
		"potatoes_approved": shift_stats.potatoes_approved,
		"potatoes_rejected": shift_stats.potatoes_rejected,
		"perfect_stamps": shift_stats.perfect_stamps,
		"speed_bonus": shift_stats.get_speed_bonus(),
		"accuracy_bonus": shift_stats.get_accuracy_bonus(),
		"perfect_bonus": shift_stats.get_missile_bonus(),
		"final_score": Global.score
	}
	Global.store_game_stats(stats)
	var summary = shift_summary.instantiate()
	add_child(summary)
	summary.show_summary(stats)
