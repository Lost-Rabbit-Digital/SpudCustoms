# Main.gd (Main scene script)
extends Node2D

var close_sound_played = false
var open_sound_played = false

var is_paused = false

# track the current potato's info
var current_potato_info

var current_potato
var score = 25
var strikes = 0
var current_rules = []
var queue_manager: Node2D
var is_potato_in_office = false
var megaphone_flash_timer: Timer
const MEGAPHONE_FLASH_INTERVAL = 1.0 # flash every 1 seconds

# Potato spawn manager
var potato_count = 0
var max_potatoes = 20
@onready var spawn_timer = $SpawnTimer

# Dragging system
var draggable_sprites = []
var dragged_sprite = null
var drag_offset = Vector2()
const PHYSICAL_STAMP_Z_INDEX = 100
const APPLIED_STAMP_Z_INDEX = 50
const PASSPORT_Z_INDEX = 0

# Passport dragging system
var passport: Sprite2D
var interaction_table: Sprite2D
var suspect_panel: Sprite2D
var suspect_panel_front: Sprite2D
var suspect: Sprite2D
var is_passport_open = false

# Bulletin dragging system
var bulletin: Sprite2D
var is_bulletin_open = false

# Stamp system
const STAMP_ANIMATION_DURATION = 0.3  # Duration of the stamp animation in seconds
const STAMP_MOVE_DISTANCE = 36  # How far the stamp moves down

func generate_rules():
	current_rules = [
		# Type-based rules
		"Purple Majesty not welcome.",
		"No Russet Burbanks allowed!",
		"Yukon Gold potatoes must be thoroughly checked.",
		"Sweet Potatoes require special authorization.",
		"Red Bliss potatoes are currently restricted.",

		# Condition-based rules
		"All potatoes must be Fresh!",
		"Extra Eyes are suspicious, inspect carefully.",
		"Rotten potatoes are strictly forbidden.",
		"Sprouted potatoes need additional verification.",
		"Dehydrated potatoes are not allowed today.",
		"Frozen potatoes require a special permit.",

		# Age-based rules
		"No potatoes over 5 years old.",
		"Only mature potatoes (3+ years) allowed.",
		"Young potatoes (under 2 years) need guardian.",

		# Gender-based rules
		"Only male potatoes allowed today.",
		"Female potatoes get priority processing.",

		# Country-based rules
		"Potatoes from Spudland must be denied.",
		"Potatopia citizens need additional screening.",
		"Tuberstan potatoes suspected of concealing arms.",
		"North Yamnea is currently under embargo.",
		"Spuddington potatoes require visa check.",
		"Tatcross citizens get no entry processing.",
		"Mash Meadows potatoes need health certificate.",
		"Tuberville potatoes subject to random checks.",
		"Chip Hill exports are currently restricted.",
		"Murphyland potatoes need work permit verification.",
		"Colcannon citizens must declare any seasonings.",
		"Pratie Point potatoes require agricultural inspection.",

		# Expiration-based rules
		"Expired potatoes are not allowed.",
		"Potatoes expiring within 30 days need approval.",
		"Long-life potatoes (5+ years until expiry) get priority.",
		"Potatoes must have at least 1 year until expiration.",
		"Potatoes with less than 6 months to expiry require special handling.",
	]
	# Randomly select 2-3 rules
	current_rules.shuffle()
	current_rules = current_rules.slice(0, randi() % 2 + 2)
	update_rules_display()


func days_until_expiry(expiration_date: String) -> int:
	var current_date = Time.get_date_dict_from_system()
	var expiry_date = Time.get_datetime_dict_from_datetime_string(expiration_date, false)
	var current_days = current_date.year * 365 + current_date.month * 30 + current_date.day
	var expiry_days = expiry_date.year * 365 + expiry_date.month * 30 + expiry_date.day
	return expiry_days - current_days

func years_until_expiry(expiration_date: String) -> int:
	return days_until_expiry(expiration_date) / 365

func update_rules_display():
	$"Label (RulesLabel)".text = "LAWS\n" + "\n".join(current_rules)
	
func is_potato_valid(potato_info: Dictionary) -> bool:
	for rule in current_rules:
		match rule:
			# Type-based rules
			"Purple Majesty not welcome.":
				if potato_info.type == "Purple Majesty":
					return false
			"No Russet Burbanks allowed!":
				if potato_info.type == "Russet Burbank":
					return false
			"Yukon Gold potatoes must be thoroughly checked.":
				if potato_info.type == "Yukon Gold":
					return false
			"Sweet Potatoes require special authorization.":
				if potato_info.type == "Sweet Potato":
					return false
			"Red Bliss potatoes are currently restricted.":
				if potato_info.type == "Red Bliss":
					return false
			# Condition-based rules
			"All potatoes must be Fresh!":
				if potato_info.condition != "Fresh":
					return false
			"Extra Eyes are suspicious, inspect carefully.":
				if potato_info.condition == "Extra Eyes":
					return false
			"Rotten potatoes are strictly forbidden.":
				if potato_info.condition == "Rotten":
					return false
			"Sprouted potatoes need additional verification.":
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
				if age > 5:
					return false
			"Only mature potatoes (3+ years) allowed.":
				var age = calculate_age(potato_info.date_of_birth)
				if age < 3:
					return false
			"Young potatoes (under 2 years) need guardian.":
				var age = calculate_age(potato_info.date_of_birth)
				if age < 2:
					return false
			# Sex-based rules
			"Only male potatoes allowed today.":
				if potato_info.sex == "Female":
					return false
			"Female potatoes get priority processing.":
				if potato_info.sex == "Male":
					return false
			# Country-based rules
			"Potatoes from Spudland must be denied.":
				if potato_info.country_of_issue == "Spudland":
					return false
			"Potatopia citizens need additional screening.":
				if potato_info.country_of_issue == "Potatopia":
					return false			
			"Tuberstan potatoes welcome with open arms.":
				if potato_info.country_of_issue == "Tuberstan":
					return false			
			"North Yamnea is currently under embargo.":
				if potato_info.country_of_issue == "North Yamnea":
					return false			
			"Spuddington potatoes require visa check.":
				if potato_info.country_of_issue == "Spuddington":
					return false
			"Tatcross citizens get expedited processing.":
				if potato_info.country_of_issue == "Tatcross":
					return false			
			"Mash Meadows potatoes need health certificate.":
				if potato_info.country_of_issue == "Mash Meadows":
					return false
			"Tuberville potatoes subject to random checks.":
				if potato_info.country_of_issue == "Tuberville":
					return false
			"Chip Hill exports are currently restricted.":
				if potato_info.country_of_issue == "Chip Hill":
					return false
			"Murphyland potatoes need work permit verification.":
				if potato_info.country_of_issue == "Murphyland":
					return false
			"Colcannon citizens must declare any seasonings.":
				if potato_info.country_of_issue == "Colcannon":
					return false
			"Pratie Point potatoes require agricultural inspection.":
				if potato_info.country_of_issue == "Pratie Point":
					return false
			# Expiration-based rules
			"Expired potatoes are not allowed.":
				if is_expired(potato_info.expiration_date):
					return false
			"Potatoes expiring within 30 days need approval.":
				var days_to_expiry = days_until_expiry(potato_info.expiration_date)
				if days_to_expiry >= 0 and days_to_expiry <= 30:
					return false
			"Long-life potatoes (5+ years until expiry) get priority.":
				var years_to_expiry = years_until_expiry(potato_info.expiration_date)
				if years_to_expiry <= 5:
					return false
			"Potatoes must have at least 1 year until expiration.":
				var years_to_expiry = years_until_expiry(potato_info.expiration_date)
				if years_to_expiry < 1:
					return false
			"Potatoes with less than 6 months to expiry require special handling.":
				var days_to_expiry = days_until_expiry(potato_info.expiration_date)
				if days_to_expiry >= 0 and days_to_expiry < 180:
					return false
	return true

@onready var megaphone = $"Sprite2D (Megaphone)"
@onready var potato_mugshot = $"Sprite2D (PotatoMugshot)"
@onready var enter_office_path = $"Path2D (EnterOfficePath)"

func update_date_display():
	var current_date = Time.get_date_dict_from_system()
	var formatted_date = "%04d.%02d.%02d" % [current_date.year, current_date.month, current_date.day]
	$"Label (DateLabel)".text = formatted_date

func _ready():
	setup_megaphone_flash_timer()

	$"Label (ScoreLabel)".text = "Score   " + str(score)
	update_date_display()
	queue_manager = $"Node2D (QueueManager)"  # Make sure to add QueueManager as a child of Main
	generate_rules()
	setup_spawn_timer()
	draggable_sprites = [
		$"Sprite2D (Passport)",
		$"Sprite2D (Approval Stamp)",
		$"Sprite2D (Rejection Stamp)"
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
	
	# Get references to the new nodes
	passport = $"Sprite2D (Passport)"
	bulletin = $"Sprite2D (Bulletin)"
	interaction_table = $InteractionTableBackground
	suspect_panel = $"Sprite2D (Suspect Panel)"
	suspect_panel_front = $"Sprite2D (Suspect Panel)/SuspectPanelFront"
	suspect = $"Sprite2D (PotatoMugshot)"
	
	# Add closed passport to draggable sprites
	draggable_sprites.append(passport)
	draggable_sprites.append(bulletin)
	
func setup_megaphone_flash_timer():
	megaphone_flash_timer = $MegaphoneFlashTimer
	megaphone_flash_timer.wait_time = MEGAPHONE_FLASH_INTERVAL
	megaphone_flash_timer.start()


func _on_megaphone_flash_timer_timeout():
	if not is_potato_in_office:
		$"Sprite2D (Megaphone)/Sprite2D (Flash Alert)".visible = !$"Sprite2D (Megaphone)/Sprite2D (Flash Alert)".visible
	else:
		$"Sprite2D (Megaphone)/Sprite2D (Flash Alert)".visible = false

func play_random_customs_officer_sound():
	var customs_officer_sounds = [
		preload("res://audio/froggy_phrase_1.wav"),
		preload("res://audio/froggy_phrase_2.wav"),
		preload("res://audio/froggy_phrase_3.wav"),
		preload("res://audio/froggy_phrase_4.wav"),
		preload("res://audio/froggy_phrase_5.wav"),
		preload("res://audio/froggy_phrase_6.wav"),
		preload("res://audio/froggy_phrase_7.wav")
	]
	# Play potato customs officer sound
	if !$"AudioStreamPlayer2D (SFX)".is_playing():
		$"AudioStreamPlayer2D (SFX)".stream = customs_officer_sounds.pick_random()
		$"AudioStreamPlayer2D (SFX)".play()
		
func say_random_customs_officer_dialogue():
	var customs_officer_dialogue = [
		preload("res://textures/megaphone/megaphone_dialogue_box_2.png"),
		preload("res://textures/megaphone/megaphone_dialogue_box_3.png"),
		preload("res://textures/megaphone/megaphone_dialogue_box_4.png"),
		preload("res://textures/megaphone/megaphone_dialogue_box_5.png"),
		preload("res://textures/megaphone/megaphone_dialogue_box_6.png")
	]
	$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".visible = true
	$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".texture = customs_officer_dialogue.pick_random()
		
		
func megaphone_clicked():
	if is_potato_in_office:
		play_random_customs_officer_sound()
		say_random_customs_officer_dialogue()
		print("Warning: A potato is already in the customs office!")
		return
		
	queue_manager = $"Node2D (QueueManager)"
	play_random_customs_officer_sound()
	print("Megaphone clicked")
	var potato_person = queue_manager.remove_front_potato()
	if potato_person != null:
		$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".visible = true
		$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".texture = preload("res://textures/megaphone/megaphone_dialogue_box_1.png")
		is_potato_in_office = true
		megaphone.visible = true
		passport.visible = false
		current_potato_info = potato_person.potato_info
		move_potato_to_office(potato_person)
	else:
		$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".visible = true
		$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".texture = preload("res://textures/megaphone/megaphone_dialogue_box_7.png")
		print("No potato to process. :(")
		

		
func move_potato_to_office(potato_person):
	print("Moving our spuddy to the customs office")
	
	if potato_person.get_parent():
		potato_person.get_parent().remove_child(potato_person)
		print("removed potato from original parent")
		
		
	var path_follow = PathFollow2D.new()
	enter_office_path.add_child(path_follow)
	path_follow.add_child(potato_person)
	print("Added potato_person to new PathFollow2D")
	
	potato_person.position = Vector2.ZERO
	path_follow.progress_ratio = 0.0
	print("Reset potato position and path progress") 
		
	var tween = create_tween()
	tween.tween_property(path_follow, "progress_ratio", 1.0, 2.0)
	tween.tween_callback(func():
		print("Potato reached end of path, clean up")
		potato_person.queue_free()
		path_follow.queue_free()
		animate_mugshot_and_passport()
		)
	
	print("Started animate mugshot and passport tween animation")
	
func animate_mugshot_and_passport():
	
	passport = $"Sprite2D (Passport)"
	print("Animating mugshot and passport")
	update_potato_info_display()

	# Reset positions and visibility
	potato_mugshot.position.x = suspect_panel.position.x + suspect_panel.texture.get_width()
	passport.visible = false
	passport.position = Vector2(suspect_panel.position.x, suspect_panel.position.y)
	close_passport_action()

	var tween = create_tween()
	tween.set_parallel(true)

	# Animate potato mugshot
	tween.tween_property(potato_mugshot, "position:x", suspect_panel.position.x, 2)
	tween.tween_property(potato_mugshot, "modulate:a", 1, 2)
	tween.tween_property(passport, "modulate:a", 1, 2)
	# Animate passport
	tween.tween_property(passport, "visible", true, 0).set_delay(2)
	tween.tween_property(passport, "position:y", suspect_panel.position.y + suspect_panel.texture.get_height() / 5, 1).set_delay(2)
	tween.tween_property(passport, "z_index", 3, 0).set_delay(3)

	tween.chain().tween_callback(func(): print("Finished animating mugshot and passport"))
	
func setup_spawn_timer():
	spawn_timer = Timer.new()
	spawn_timer.set_wait_time(3.0)
	spawn_timer.set_one_shot(false)
	spawn_timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))
	add_child(spawn_timer)
	spawn_timer.start()

func _on_SpawnTimer_timeout():
	if queue_manager.can_add_potato():
		queue_manager.spawn_new_potato()
	else:
		print("No mah potatoes bruv")
		#spawn_timer.stop()

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	if suspect.get_rect().has_point(suspect.to_local(mouse_pos)) and dragged_sprite == passport and is_passport_open == false:
		$"Sprite2D (Passport)/Sprite2D (Close Passport)/GivePromptDialogue".visible = true
	else:
		$"Sprite2D (Passport)/Sprite2D (Close Passport)/GivePromptDialogue".visible = false
		
	if !$"AudioStreamPlayer2D (SFX)".is_playing():
		$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".visible = false
	
	if is_paused == true:
		$Container/pause_menu.visible = true
		$"Sprite2D (Approval Stamp)".visible = false
		$"Sprite2D (Rejection Stamp)".visible = false
	else:
		$Container/pause_menu.visible = false
		$"Sprite2D (Approval Stamp)".visible = true
		$"Sprite2D (Rejection Stamp)".visible = true
		
	# Check for closing passport
	if (suspect_panel.get_rect().has_point(suspect_panel.to_local(mouse_pos)) or 
		suspect.get_rect().has_point(suspect.to_local(mouse_pos))) and (dragged_sprite == bulletin or dragged_sprite == passport):
		if not close_sound_played:
			if dragged_sprite == passport:
				close_passport_action()
			elif dragged_sprite == bulletin:
				close_bulletin_action()
			$"AudioStreamPlayer2D (SFX)".stream = preload("res://audio/passport_sfx/close_passport_audio.mp3")
			$"AudioStreamPlayer2D (SFX)".play()
			close_sound_played = true
			open_sound_played = false  # Reset open sound flag
	
	# Check for opening passport
	if interaction_table.get_rect().has_point(interaction_table.to_local(mouse_pos)) and (dragged_sprite == bulletin or dragged_sprite == passport):
		if not open_sound_played:
			if dragged_sprite == passport and is_passport_open == false:
				open_passport_action()
			elif dragged_sprite == bulletin:
				open_bulletin_action()
			$"AudioStreamPlayer2D (SFX)".stream = preload("res://audio/passport_sfx/open_passport_audio.mp3")
			$"AudioStreamPlayer2D (SFX)".play()
			open_sound_played = true
			close_sound_played = false  # Reset close sound flag

func generate_potato_info():
	var expiration_date: String
	if randf() < 0.2:
		expiration_date = get_past_date(0, 3)
	else:
		expiration_date = get_future_date(0,3)
		
	return {
		"name": get_random_name(),
		"type": get_random_type(),
		"condition": get_random_condition(),
		"sex": get_random_sex(), 
		"country_of_issue": get_random_country(),
		"date_of_birth": get_past_date(1, 10),
		"expiration_date": expiration_date
	}

func update_potato_info_display():
	print("Printing current potato info")
	print(current_potato_info)
	if current_potato_info:
		$"Sprite2D (Passport)/Sprite2D (Open Passport)/Label (PotatoHeader)".text = """{name}""".format(current_potato_info)
		$"Sprite2D (Passport)/Sprite2D (Open Passport)/Label (PotatoInfo)".text = """{date_of_birth}
		{sex} 
		{country_of_issue}
		{expiration_date} 
		{type}
		{condition}
		""".format(current_potato_info)
	else:
		print("Potato textures fucking up")
		# Clear the display if there is no current potato
		#$"Sprite2D (Passport)/Sprite2D (Open Passport)/Label (PotatoHeader)".text = ""
		#$"Sprite2D (Passport)/Sprite2D (Open Passport)/Label (PotatoInfo)".text = ""
		# You might want to clear the texture here as well
		#potato_mugshot.texture = null
		#$"Sprite2D (Passport)/Sprite2D (Open Passport)/Sprite2D (PassportPhoto)".texture = null
	print("Potato info update complete")
	update_potato_texture()

func generate_potato():
	# Generate random potato characteristics
	var potato = {
		"name": get_random_name(),
		"type": get_random_type(),
		"condition": get_random_condition(),
	}
	potato.description = "Name: %s\nType: %s\nCondition: %s" % [potato.name, potato.type, potato.condition]
	return potato

func get_random_name():
	var first_names = [
		"Spud", "Tater", "Mash", "Spudnik", "Tater Tot", "Mr. Potato", "Chip", 
		"Murph", "Yam", "Tato", "Spuddy", "Tuber"
		]
	var last_names = [
		"Ouwiw", "Sehi", "Sig", "Heechou", "Oufug", "Azej", "Holly",
		"Ekepa", "Nuz", "Chegee", "Kusee", "Houf", "Fito", "Mog", "Urife"
		]
	return "%s %s" % [first_names[randi() % first_names.size()], last_names[randi() % last_names.size()]]

func get_random_type():
	var types = ["Russet Burbank", "Yukon Gold", "Sweet Potato", "Purple Majesty", "Red Bliss"]
	return types[randi() % types.size()]

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
	var birth_date = Time.get_datetime_dict_from_datetime_string(date_of_birth, false)
	var age = current_date.year - birth_date.year
	if current_date.month < birth_date.month or (current_date.month == birth_date.month and current_date.day < birth_date.day):
		age -= 1
	return age	
	
func is_expired(expiration_date: String) -> bool:
	var current_date = Time.get_date_dict_from_system()
	var expiry_date = Time.get_datetime_dict_from_datetime_string(expiration_date, false)
	if current_date.year > expiry_date.year:
		return true
	elif current_date.year == expiry_date.year:
		if current_date.month > expiry_date.month: 
			return true
		elif current_date.month == expiry_date.month:
			return current_date.day > expiry_date.day
	return false
	
func _on_button_welcome_button_pressed() -> void:
	process_decision(true)

func _on_button_no_entry_button_pressed() -> void:
	process_decision(false)

func go_to_game_over():
	var game_over_scene = preload("res://game_over.tscn").instantiate()
	game_over_scene.score = score
	print("transition to scene")
	$"Sprite2D (Approval Stamp)".visible = false
	$"Sprite2D (Rejection Stamp)".visible = false
	get_tree().change_scene_to_file("res://game_over.tscn")

func process_decision(allowed):
	var potato_info = queue_manager.remove_potato()
	if potato_info.is_empty():
		print("No potato to process.")
		return
		
	var correct_decision = is_potato_valid(potato_info)
	
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		score += 1
		$"Label (JudgementInfo)".text = "You made the right choice, officer."
	else:
		$"Label (JudgementInfo)".text = "You have caused unnecessary suffering, officer..."
		strikes += 0
		if strikes == 3:
			go_to_game_over()
			print("Game over!")
			
			
	$"Label (StrikesLabel)".text = "Strikes   " + str(strikes) + "/3"
	$"Label (ScoreLabel)".text = "Score   " + str(score)

	if queue_manager.can_add_potato() and spawn_timer.is_stopped():
		spawn_timer.start()
		
	if randi() % 5 < 2:  # 40% chance to change rules
		generate_rules()
		
	# Check and update the information in the passport
	#update_potato_info_display()

func peek_front_potato():
	var front_potato_info = queue_manager.get_front_potato_info()
	# Use front_potato_info as needed

func update_potato_texture():
	print("Updating potato texture")
	
	if current_potato_info == null or current_potato_info.is_empty():
		print("No valid potato info available")
		clear_potato_textures()
		return
	
	var texture_paths = get_texture_paths(current_potato_info.type)
	
	if texture_paths.head != "":
		potato_mugshot.texture = load(texture_paths.head)
	else:
		potato_mugshot.texture = null
	
	var passport_photo = $"Sprite2D (Passport)/Sprite2D (Open Passport)/Sprite2D (PassportPhoto)"
	if texture_paths.passport != "":
		passport_photo.texture = load(texture_paths.passport)
	else:
		passport_photo.texture = null
	
	print("Potato texture update complete for type: ", current_potato_info.type)

func get_texture_paths(potato_type: String) -> Dictionary:
	var paths = {
		"head": "",
		"passport": ""
	}
	
	match potato_type:
		"Purple Majesty":
			paths.head = "res://potatoes/heads/purple_majesty_head.png"
			paths.passport = "res://potatoes/document_photos/purple_majesty.png"
		"Red Bliss":
			paths.head = "res://potatoes/heads/red_bliss_head.png"
			paths.passport = "res://potatoes/document_photos/red_bliss.png"
		"Russet Burbank":
			paths.head = "res://potatoes/heads/russet_burbank_head.png"
			paths.passport = "res://potatoes/document_photos/russet_burbank.png"
		"Sweet Potato":
			paths.head = "res://potatoes/heads/sweet_potato_head.png"
			paths.passport = "res://potatoes/document_photos/sweet_potato.png"
		"Yukon Gold":
			paths.head = "res://potatoes/heads/yukon_gold_head.png"
			paths.passport = "res://potatoes/document_photos/yukon_gold.png"
		_:
			print("Unknown potato type: ", potato_type)
	
	return paths

func clear_potato_textures():
	potato_mugshot.texture = null
	$"Sprite2D (Passport)/Sprite2D (Open Passport)/Sprite2D (PassportPhoto)".texture = null
	
func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE and event.pressed:
			is_paused = !is_paused
				
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = get_global_mouse_position()
				if megaphone.get_rect().has_point(megaphone.to_local(mouse_pos)):
					megaphone_clicked()
				dragged_sprite = find_topmost_sprite_at(mouse_pos)
				if dragged_sprite:
					drag_offset = mouse_pos - dragged_sprite.global_position
			else:
				if dragged_sprite == passport:
					$"Sprite2D (Passport)/Sprite2D (Close Passport)/GivePromptDialogue".visible = false
					var drop_pos = get_global_mouse_position()
					if interaction_table.get_rect().has_point(interaction_table.to_local(drop_pos)):
						open_passport_action()
					if suspect_panel.get_rect().has_point(suspect_panel.to_local(drop_pos)):
						close_passport_action()
					if suspect.get_rect().has_point(suspect.to_local(drop_pos)):
						close_passport_action()
						remove_stamp()
				elif dragged_sprite == bulletin:
					var drop_pos = get_global_mouse_position()
					if interaction_table.get_rect().has_point(interaction_table.to_local(drop_pos)):
						open_bulletin_action()
					if suspect_panel.get_rect().has_point(suspect_panel.to_local(drop_pos)):
						close_bulletin_action()
					if suspect.get_rect().has_point(suspect.to_local(drop_pos)):
						close_bulletin_action()
				dragged_sprite = null
				$"Sprite2D (Approval Stamp)/Sprite2D (StampShadow)".visible = false
				$"Sprite2D (Rejection Stamp)/Sprite2D (StampShadow)".visible = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if dragged_sprite and "Stamp" in dragged_sprite.name:
				apply_stamp(dragged_sprite)
				
	elif event is InputEventMouseMotion and dragged_sprite:
		dragged_sprite.global_position = get_global_mouse_position() - drag_offset
		if "Stamp" in dragged_sprite.name:
			var stamp_shadow = dragged_sprite.get_children()[0]
			stamp_shadow.visible = true
		
func open_passport_action():
	$"Sprite2D (Passport)".texture = preload("res://documents/passport-old.png")
	$"Sprite2D (Passport)/Sprite2D (Open Passport)".visible = true
	$"Sprite2D (Passport)/Sprite2D (Close Passport)".visible = false
	
func close_passport_action():
	$"Sprite2D (Passport)".texture = preload("res://documents/closed_passport_small/closed_passport_small.png")
	$"Sprite2D (Passport)/Sprite2D (Close Passport)".visible = true
	$"Sprite2D (Passport)/Sprite2D (Open Passport)".visible = false
	
func open_bulletin_action():
	$"Sprite2D (Bulletin)".texture = preload("res://documents/bulletin/bulletin_main_page.png")
	$"Sprite2D (Bulletin)/Sprite2D (Open Bulletin)".visible = true
	$"Sprite2D (Bulletin)/Sprite2D (Close Bulletin)".visible = false
	
func close_bulletin_action():
	$"Sprite2D (Bulletin)".texture = preload("res://documents/bulletin/closed_bulletin_small/closed_bulletin_small.png")
	$"Sprite2D (Bulletin)/Sprite2D (Close Bulletin)".visible = true
	$"Sprite2D (Bulletin)/Sprite2D (Open Bulletin)".visible = false
	
func find_topmost_sprite_at(pos: Vector2):
	var topmost_sprite = null
	for sprite in draggable_sprites:
		if sprite.get_rect().has_point(sprite.to_local(pos)):
			if not topmost_sprite or sprite.z_index > topmost_sprite.z_index:
				topmost_sprite = sprite
	return topmost_sprite

func play_random_stamp_sound():
	var stamp_sounds = [
		preload("res://audio/stamp_sound_1.mp3"),
		preload("res://audio/stamp_sound_2.mp3"),
		preload("res://audio/stamp_sound_3.mp3"),
		preload("res://audio/stamp_sound_4.mp3"),
		preload("res://audio/stamp_sound_5.mp3")
	]
	if !$"AudioStreamPlayer2D (SFX)".is_playing():
		$"AudioStreamPlayer2D (SFX)".stream = stamp_sounds.pick_random()
		$"AudioStreamPlayer2D (SFX)".play()

func apply_stamp(stamp):
	var mouse_pos = get_global_mouse_position()
	var stamped_object = find_stampable_object_at(mouse_pos)
	if stamped_object:
		# Hide the original stamp and make it non-draggable
		stamp.visible = false
		draggable_sprites.erase(stamp)
		
		# Create a temporary visual stamp that moves down
		var temp_stamp = Sprite2D.new()
		temp_stamp.texture = stamp.texture
		temp_stamp.position = stamp.position
		temp_stamp.z_index = PHYSICAL_STAMP_Z_INDEX
		add_child(temp_stamp)
		
		# Create the final stamp that will be left on the passport
		var final_stamp = Sprite2D.new()
		var stamp_texture = "res://stamps/approved_stamp.png" if "Approval" in stamp.name else "res://stamps/denied_stamp.png"
		# Store final approval state for processing
		var approval_state = "Approved" if "Approval" in stamp.name else "Denied"
		
		
		final_stamp.texture = load(stamp_texture)
		var final_stamp_x = stamp.position.x
		var final_stamp_y = stamp.position.y + STAMP_MOVE_DISTANCE
		var final_stamp_position = Vector2(final_stamp_x, final_stamp_y)
		final_stamp.position = stamped_object.to_local(final_stamp_position)
		final_stamp.z_index = APPLIED_STAMP_Z_INDEX
		final_stamp.modulate.a = 0  # Start invisible
		$"Sprite2D (Passport)/Sprite2D (Open Passport)".add_child(final_stamp)
		
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
		
		# Remove the temporary stamp and restore the original stamp
		tween.chain().tween_callback(func():
			temp_stamp.queue_free()
			stamp.visible = true  # Make the original stamp visible again
			draggable_sprites.append(stamp)  # Re-add the original stamp to draggable_sprites
		)
		
func remove_stamp():
	print("Processing passport...")
	# Get the parent node
	var open_passport = $"Sprite2D (Passport)/Sprite2D (Open Passport)"
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
	
	var passport_book = $"Sprite2D (Passport)"
	# Animate the potato mugshot and passport exit
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(potato_mugshot, "position:x", suspect_panel.position.x - potato_mugshot.texture.get_width(), 2)
	tween.tween_property(potato_mugshot, "modulate:a", 0, 2)
	tween.tween_property(passport_book, "modulate:a", 0, 2)
	tween.chain().tween_callback(func(): 
		move_potato_along_path(approval_status)
		is_potato_in_office = false # set to false as soon as potato leaves customs office
	)
	
func move_potato_along_path(approval_status):
	if current_potato_info == null:
		print("Error: No potato info available")
		return
	var path: Path2D
	var potato_person = Sprite2D.new()
	
		# Set texture based on potato type
	var texture_path = ""
	match current_potato_info.type:
		"Purple Majesty":
			texture_path = "res://potatoes/bodies/purple_majesty_body.png"
		"Red Bliss":
			texture_path = "res://potatoes/bodies/red_bliss_body.png"
		"Russet Burbank":
			texture_path = "res://potatoes/bodies/russet_burbank_body.png"
		"Sweet Potato":
			texture_path = "res://potatoes/bodies/sweet_potato_body.png"
		"Yukon Gold":
			texture_path = "res://potatoes/bodies/yukon_gold_body.png"
	
	potato_person.texture = load(texture_path)
	potato_person.scale = Vector2(0.20, 0.20)
	
	# set path based on approval status
	if approval_status == "approved":
		path = $"Path2D (ApprovePath)"
		process_decision(true)
	else: 
		if randi() % 5 == 0:  # 20% chance to go sicko mode
			path =$"Path2D (RunnerPath)"
		else:
			path = $"Path2D (RejectPath)"
		process_decision(false)
			
	# Calculate score change
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	path_follow.add_child(potato_person)
	
	potato_person.position = Vector2.ZERO
	path_follow.progress_ratio = 0.0
	
	passport = $"Sprite2D (Passport)"
	passport.modulate.a = 0
	
	var exit_tween = create_tween()
	if "Approve" in path:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 10.0)
	if "Reject" in path:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 9.0)
	else:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 8.0)
	exit_tween.tween_callback(func():
		potato_person.queue_free()
		path_follow.queue_free()
		reset_scene()
		)
	
func reset_scene():
	# reset mugshot
	#potato_mugshot.modulate.a = 0
	potato_mugshot.position.x = suspect_panel.position.x
	
	# reset passport
	# close_passport_action()
	# passport.position = Vector2(suspect_panel.position.x, suspect_panel.position.y + suspect_panel.texture.get_height () / 5)
	#passport.modulate.a = 0
	
	$"Label (JudgementInfo)".text = ""
	
	# Clear the current potato info
	# current_potato_info = null
	
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
	
