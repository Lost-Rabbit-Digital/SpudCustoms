extends Node2D

# Add border runner system
var border_runner_system

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

# Track multipliers and streaks
var point_multiplier: float = 1.0
var correct_decision_streak: int = 0
var original_runner_chance: float = 0.15  # Match your current chance value

# storing and sending rule assignments
signal rules_updated(new_rules)
var current_rules = []

var queue_manager: Node2D

# Potato spawn manager
var potato_count: int = 0
var max_potatoes: int = 20
@onready var spawn_timer = $SystemManagers/Timers/SpawnTimer

#Narrative manager
@onready var narrative_manager = $SystemManagers/NarrativeManager

# Passport
var passport: Sprite2D
var passport_spawn_point_begin: Node2D
var passport_spawn_point_end: Node2D
var inspection_table: Sprite2D
var suspect_panel: Sprite2D
var suspect_panel_front: Sprite2D
var suspect: Sprite2D

# Stamp system
const STAMP_ANIMATION_DURATION: float = 0.3  # Duration of the stamp animation in seconds
const STAMP_MOVE_DISTANCE: int = 36  # How far the stamp moves down
var default_cursor = Input.CURSOR_ARROW

# Character Generation
@onready var mugshot_generator = $Gameplay/MugshotPhotoGenerator
@onready var passport_generator = $Gameplay/InteractiveElements/Passport/OpenPassport/PassportPhotoGenerator

@onready var megaphone = $Gameplay/Megaphone
@onready var megaphone_dialogue_box = %MegaphoneDialogueBox
@onready var enter_office_path = $Gameplay/Paths/EnterOfficePath
@onready var stats_manager = $SystemManagers/StatsManager
var shift_stats: ShiftStats
@onready var shift_summary = preload("res://scripts/systems/ShiftSummaryScreen.tscn")

## Label used to display alerts and notifications to the player
@onready var alert_label = $UI/Labels/MarginContainer/AlertLabel
@onready var alert_timer = $SystemManagers/Timers/AlertTimer


var current_shift: int = 1

# Combo system variables
var combo_count = 0
var combo_timer = 0.0
var combo_timeout = 15.0  # Seconds before combo resets
var max_combo_multiplier = 3.0

# Drag and drop manager 
@onready var drag_and_drop_manager = $SystemManagers/DragAndDropManager

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
	# Initialize the drag and drop manager
	if not drag_and_drop_manager:
		# If the node doesn't exist yet, create it
		var manager = DragAndDropManager.new()
		manager.name = "DragAndDropManager"
		$SystemManagers.add_child(manager)
		drag_and_drop_manager = manager
	
	# Initialize after all other nodes are ready
	drag_and_drop_manager.initialize(self)
	
	# Connect signal
	drag_and_drop_manager.drag_system.passport_returned.connect(_on_passport_returned)
	
	# Get the current level ID from the level list manager if it exists
	var level_manager = get_level_manager()
	if level_manager:
		current_shift = level_manager.get_current_level_id()
		print(current_shift)
	
	narrative_manager.current_shift = current_shift
	
	var stamp_bar = $Gameplay/InteractiveElements/StampBarController
	var stamp_system = $Gameplay/InteractiveElements/StampCrossbarSystem
	
	# Connect the stamp bar to the stamp system
	stamp_bar.stamp_requested.connect(stamp_system.on_stamp_requested)
	
	game_start_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
	
	queue_manager = %QueueManager
	setup_spawn_timer()
	
	shift_stats = stats_manager.get_new_stats()
	Global.score_updated.connect(_on_score_updated)
	difficulty_level = Global.difficulty_level
	set_difficulty(difficulty_level)
	# Store the default cursor shape
	
	update_score_display()
	update_quota_display()
	update_date_display()
	generate_rules()

	if Global.final_score > 0:
		Global.score = Global.final_score
		update_score_display()

	if Global.quota_met > 0:
		update_quota_display()
	# Get references to the new nodes
	passport = $Gameplay/InteractiveElements/Passport
	passport_spawn_point_begin = $Gameplay/InteractiveElements/PassportSpawnPoints/BeginPoint
	passport_spawn_point_end = $Gameplay/InteractiveElements/PassportSpawnPoints/EndPoint
	inspection_table = $Gameplay/InspectionTable
	suspect_panel = $Gameplay/SuspectPanel
	suspect_panel_front = $Gameplay/SuspectPanel/SuspectPanelFront
	suspect = $Gameplay/MugshotPhotoGenerator/SizingSprite
	
	$UI/Labels/StrikesLabel.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)

	# Add closed passport to draggable sprites
	#draggable_sprites.append(passport)
	
	border_runner_system = %BorderRunnerSystem
	border_runner_system.game_over_triggered.connect(_on_game_over)
	border_runner_system.is_enabled = true
	
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_finished)
	#disable_controls()

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

# Apply to points calculation:
func award_points(base_points: int):
	var multiplier = add_to_combo()
	var total_points = base_points * multiplier
	Global.add_score(total_points)
	return total_points



func end_shift():
	if Global.quota_met >= Global.quota_target:
		# Add survival bonus
		var survival_bonus = 500
		Global.add_score(survival_bonus)
		Global.display_green_alert(alert_label, alert_timer, "Shift survived! Bonus: " + str(survival_bonus) + " points!")
		# Reset strikes and quota
		Global.strikes = 0
		Global.quota_met = 0
		# Update displays
		update_quota_display()
		# Add 2 second delay before starting dialogue
		await get_tree().create_timer(2.0).timeout
		narrative_manager.start_shift_dialogue()
		disable_controls()
	else:
		# Capture time taken
		var elapsed_time = (Time.get_ticks_msec() / 1000.0) - game_start_time
		
		# Get border runner statistics
		var runner_stats = $BorderRunnerSystem.shift_stats
		
		# Populate the ShiftStats object with the necessary data
		shift_stats.time_taken = elapsed_time
		shift_stats.missiles_fired = runner_stats.missiles_fired
		shift_stats.missiles_hit = runner_stats.missiles_hit
		shift_stats.perfect_hits = runner_stats.perfect_hits
		shift_stats.total_stamps = shift_stats.total_stamps
		shift_stats.potatoes_approved = shift_stats.potatoes_approved
		shift_stats.potatoes_rejected = shift_stats.potatoes_rejected
		
		# Calculate the hit rate manually
		shift_stats.hit_rate = 0.0 if shift_stats.missiles_fired == 0 else (float(shift_stats.missiles_hit) / shift_stats.missiles_fired * 100.0)
		
		# Call the store_game_stats() function with the populated ShiftStats object
		Global.store_game_stats(shift_stats)
		var summary = shift_summary.instantiate()
		add_child(summary)
		summary.show_summary(shift_stats)
	
func set_difficulty(level):
	difficulty_level = level
	match difficulty_level:
		"Easy":
			Global.max_strikes = 6
		"Normal":
			Global.max_strikes = 4
		"Expert":
			Global.max_strikes = 3
			
	update_quota_display()
	$UI/Labels/StrikesLabel.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)

func generate_rules():
	# Get the full list of rules from LawValidator
	var all_rules = LawValidator.LAW_CHECKS.keys()
	
	# Randomly select 2-3 rules
	all_rules.shuffle()
	current_rules = all_rules.slice(0, randi() % 2 + 2)
	
	update_rules_display()

func update_rules_display():
	var laws_text = "[center][u]LAWS[/u]\n\n" + "\n".join(current_rules) + "[/center]"
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
	if is_potato_in_office:
		megaphone_dialogue_box.next_message()
		megaphone_dialogue_box.play_random_officer_sound()
		megaphone_dialogue_box.visible = true
		print("Warning: A potato is already in the customs office!")
		return
		
	var potato = queue_manager.remove_front_potato()
	if potato:
		megaphone_dialogue_box.next_message()
		megaphone_dialogue_box.play_random_officer_sound()
		megaphone_dialogue_box.visible = true
		is_potato_in_office = true
		megaphone.visible = true
		current_potato_info = potato.get_potato_info()
		
		# Move potato to the office
		potato.set_state(potato.TaterState.IN_OFFICE)
		move_potato_to_office(potato)
	else:
		megaphone_dialogue_box.next_message()
		megaphone_dialogue_box.play_random_officer_sound()
		megaphone_dialogue_box.visible = true
		print("No potato to process. :(")
		
func move_potato_to_office(potato: PotatoPerson):
	print("Moving our spuddy to the customs office")
	potato.set_state(potato.TaterState.IN_OFFICE)
	
	# Attach potato to entry path
	if enter_office_path:
		potato.attach_to_path(enter_office_path)
		
		# Connect to path completion
		if !potato.is_connected("path_completed", Callable(self, "_on_potato_path_completed")):
			potato.path_completed.connect(_on_potato_path_completed.bind(potato))
	else:
		push_error("Enter office path not found!")

# Add this new function to handle path completion
func _on_potato_path_completed(potato: PotatoPerson):
	# Clean up potato and show mugshot
	potato.queue_free()
	animate_mugshot_and_passport()
	
func animate_mugshot_and_passport():
	print("Animating mugshot and passport")
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
	passport.z_index = 1
	passport.position = Vector2(passport_spawn_point_begin.position.x, passport_spawn_point_begin.position.y)

	var tween = create_tween()
	tween.set_parallel(true)

	# Animate potato mugshot
	tween.tween_property(mugshot_generator, "position:x", suspect_panel_spawn_node.position.x, 0.7)
	tween.tween_property(mugshot_generator, "modulate:a", 1, 0.7)
	
	# Animate passport
	tween.tween_property(passport, "modulate:a", 1, 1)
	tween.tween_property(passport, "visible", true, 0).set_delay(1)
	tween.tween_property(passport, "position:y", passport_spawn_point_end.position.y, 0.7).set_delay(1)
	tween.tween_property(passport, "z_index", 5, 0).set_delay(3)

	tween.chain().tween_callback(func(): print("Finished animating mugshot and passport"))

func setup_spawn_timer():
	spawn_timer = $SystemManagers/Timers/SpawnTimer
	spawn_timer.set_wait_time(1.0)
	spawn_timer.set_one_shot(false)
	if spawn_timer.is_connected("timeout", Callable(self, "_on_spawn_timer_timeout")):
		print("NOTE: spawn_timer signal is already connected!")
	else:
		spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	# add_child(spawn_timer)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if queue_manager.can_add_potato():
		queue_manager.spawn_new_potato()
	else:
		print("Potato queue limit reached, skip spawning.")
		spawn_timer.stop()

func _process(_delta):
	# Update cursor through the drag and drop manager
	if drag_and_drop_manager:
		drag_and_drop_manager.process_cursor()
	
	# Handle prompt dialogue visibility
	var mouse_pos = get_global_mouse_position()
	var suspect = $Gameplay/MugshotPhotoGenerator/SizingSprite
	var passport = $Gameplay/InteractiveElements/Passport
	
	if suspect.get_rect().has_point(suspect.to_local(mouse_pos)) and drag_and_drop_manager.is_document_open("passport") == false and drag_and_drop_manager.drag_system.get_dragged_item() == passport:
		$Gameplay/InteractiveElements/Passport/ClosedPassport/GivePromptDialogue.visible = true
	else:
		$Gameplay/InteractiveElements/Passport/ClosedPassport/GivePromptDialogue.visible = false
	
	# Hide megaphone dialogue box when the officer sound stops playing
	if !%SFXPool.is_playing():
		megaphone_dialogue_box.visible = false
		
	# Update combo timer
	if combo_count > 0:
		combo_timer += _delta
		if combo_timer > combo_timeout:
			# Combo expired
			reset_combo()

	

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
	Global.final_score = Global.score
	Global.shift += 1
	print("ALERT: go_to_game_win() has been disabled")

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
   # Clear all existing stamps from the passport
	var open_passport = $Gameplay/InteractiveElements/Passport/OpenPassport
	for child in open_passport.get_children():
		if child is Sprite2D and ("approved" in child.texture.resource_path or "denied" in child.texture.resource_path):
			child.queue_free()
			
   # Get validation result
	var validation = LawValidator.check_violations(current_potato_info, current_rules)
	var correct_decision = validation.is_valid
   # Update stats based on correctness of decision
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		Global.quota_met += 1
		correct_decision_streak += 1
	   # Check if quota met
		if Global.quota_met >= Global.quota_target:
			print("Quota complete!")
			end_shift()
	   # Increase multiplier for streaks
		if correct_decision_streak >= 3:
			point_multiplier = 1.5
		if correct_decision_streak >= 5:
			point_multiplier = 2.0
	   # Award points for correct decisions
		var decision_points = 250 * point_multiplier
		var alert_text = "You made the right choice, officer."
		if !allowed and validation.violation_reason:
			alert_text += "\n" + validation.violation_reason
		alert_text += "\n+" + str(decision_points) + " points!"
		Global.display_green_alert(alert_label, alert_timer, alert_text)
		Global.add_score(decision_points)
	else:
	   # Decision was incorrect
		var alert_text = "You have caused unnecessary suffering, officer..."
		if validation.violation_reason:
			alert_text += "\n" + validation.violation_reason
		alert_text += "\n+1 Strike!"
		Global.display_red_alert(alert_label, alert_timer, alert_text)
		correct_decision_streak = 0
		point_multiplier = 1.0
		Global.strikes += 1
		if Global.strikes >= Global.max_strikes:
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
	
func _input(event: InputEvent):
	# If game is paused or dialogue is active, don't process input
	if is_game_paused:
		return
		
	# Let the drag and drop manager handle drag events first
	if drag_and_drop_manager.handle_input(event):
		return
		
	# Handle megaphone click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		print("Mouse Click Position: ", mouse_pos)
		if megaphone.get_rect().has_point(megaphone.to_local(mouse_pos)):
			megaphone_clicked()
			return

func check_node_for_stamps(node: Node):
	for child in node.get_children():
		print("DEBUG: Checking child:", child.name, " - Class:", child.get_class())
		if child is Sprite2D and child.texture:
			var texture_path = child.texture.resource_path
			print("DEBUG: Found sprite with texture path:", texture_path)
			if "approved" in texture_path or "approve" in texture_path:
				print("DEBUG: Found approval stamp")
				current_approval_status = "approved"
				current_stamp_count += 1
			elif "denied" in texture_path or "reject" in texture_path:
				print("DEBUG: Found denial stamp")
				current_approval_status = "rejected"
				current_stamp_count += 1

var current_stamp_count = 0
var current_approval_status = null

func remove_stamp():
	print("DEBUG: Starting remove_stamp process...")
	
	# Reset counters
	current_stamp_count = 0
	current_approval_status = null
	
	# Check both closed and open passport nodes
	var passport = $Gameplay/InteractiveElements/Passport
	var closed_passport = passport.get_node_or_null("ClosedPassport")
	var open_passport = passport.get_node_or_null("OpenPassport")
	
	print("DEBUG: Checking passport nodes:")
	print("- Base passport children:", passport.get_child_count())
	if closed_passport:
		print("- Closed passport children:", closed_passport.get_child_count())
	if open_passport:
		print("- Open passport children:", open_passport.get_child_count())
	
	# Check all nodes
	check_node_for_stamps(passport)
	if closed_passport:
		check_node_for_stamps(closed_passport)
	if open_passport:
		check_node_for_stamps(open_passport)
	
	print("DEBUG: Total stamps found:", current_stamp_count)
	print("DEBUG: Final approval status:", current_approval_status)

	if current_stamp_count == 0:
		print("DEBUG: No stamps found - aborting passport processing")
		return

	print("DEBUG: Processing passport with status:", current_approval_status)
	
	# Animate the potato mugshot and passport exit
	var mugshot_generator = $Gameplay/MugshotPhotoGenerator
	var suspect_panel = $Gameplay/SuspectPanel
	var suspect = $Gameplay/MugshotPhotoGenerator/SizingSprite
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(mugshot_generator, "position:x", suspect_panel.position.x - suspect.get_rect().size.x, 1)
	tween.tween_property(mugshot_generator, "modulate:a", 0, 1)
	tween.tween_property(passport, "modulate:a", 0, 1)
	tween.chain().tween_callback(func(): 
		process_decision(current_approval_status == "approved")
		move_potato_along_path(current_approval_status)
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
		else:
			potato.set_state(potato.TaterState.REJECTED)
			
			# Check for border runner chance
			if approval_status == "rejected" and randf() < 0.15:
				if border_runner_system:
					# Instead of using path, hand over to border runner system
					border_runner_system.start_runner(potato)
					return
		
		# Attach to the selected path
		potato.attach_to_path(path)
		
		# Connect to path_completed signal
		potato.path_completed.connect(func():
			# When path is complete, we'll fade out and clean up
			potato.fade_out()
			reset_scene()
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

func reset_scene():
	mugshot_generator.position.x = suspect_panel.position.x
	$UI/Labels/JudgementLabel.text = ""
	
func _exit_tree():
	# Ensure cursor is restored when leaving the scene
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_dialogue_started():
	# Completely pause all game systems
	is_game_paused = true
	# Tell the border runner system to pause with dialogic mode
	if border_runner_system:
		border_runner_system.set_dialogic_mode(true)
	disable_controls()
	border_runner_system.is_enabled = false
	
func _on_dialogue_finished():
	Global.quota_met = 0
	Global.strikes = 0
	# Completely unpause all game systems
	is_game_paused = false
	# Tell the border runner system dialogic mode is done
	if border_runner_system:
		border_runner_system.set_dialogic_mode(false)
	border_runner_system.is_enabled = true
	enable_controls()
	
	if Global.current_story_state >= 13:
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
		
func _on_game_over():
		# Capture time taken
		var elapsed_time = (Time.get_ticks_msec() / 1000.0) - game_start_time
		
		# Get border runner statistics
		var runner_stats = border_runner_system.shift_stats
		
		# Populate the ShiftStats object with the necessary data
		shift_stats.time_taken = elapsed_time
		shift_stats.missiles_fired = runner_stats.missiles_fired
		shift_stats.missiles_hit = runner_stats.missiles_hit
		shift_stats.perfect_hits = runner_stats.perfect_hits
		shift_stats.total_stamps = shift_stats.total_stamps
		shift_stats.potatoes_approved = shift_stats.potatoes_approved
		shift_stats.potatoes_rejected = shift_stats.potatoes_rejected
		
		# Calculate the hit rate manually
		shift_stats.hit_rate = 0.0 if shift_stats.missiles_fired == 0 else (float(shift_stats.missiles_hit) / shift_stats.missiles_fired * 100.0)
		
		# Call the store_game_stats() function with the populated ShiftStats object
		Global.store_game_stats(shift_stats)
		# Call go to game over to load shift summary screen
		Global.go_to_game_over()

# Screen shake for explosions like missiles
func shake_screen(intensity: float = 10.0, duration: float = 0.3):
	var camera = $Camera2D
	
	# Create a screen shake tween
	var tween = create_tween()
	
	# Initial random offset
	var random_shake = Vector2(
		randf_range(-intensity, intensity),
		randf_range(-intensity, intensity)
	)
	
	camera.offset = random_shake
	
	# Shake with diminishing intensity
	for i in range(10):
		var shake_intensity = intensity * (1.0 - (i / 10.0))
		random_shake = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		
		tween.tween_property(camera, "offset", random_shake, duration / 10)
	
	# Return to center
	tween.tween_property(camera, "offset", Vector2.ZERO, duration / 10)


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
