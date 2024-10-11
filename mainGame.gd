# Main.gd (Main scene script)
extends Node2D

# Track game states
var close_sound_played = false
var open_sound_played = false
var holding_stamp = false
var is_potato_in_office = false
var is_paused = false

# track the current potato's info
var current_potato_info
var current_potato

# track win and lose data
var score = 0
var max_score = 10
var strikes = 0
var max_strikes = 3

# storing and sending rule assignments
signal rules_updated(new_rules)
var current_rules = []

var queue_manager: Node2D
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

var difficulty_level = "Easy"  # Can be "Easy", "Normal", or "Hard"

# Stamp system
const STAMP_ANIMATION_DURATION = 0.3  # Duration of the stamp animation in seconds
const STAMP_MOVE_DISTANCE = 36  # How far the stamp moves down

var bulletin_tutorial_timer: Timer
const BULLETIN_TUTORIAL_FLASH_INTERVAL = 1.0 # flash every 1 seconds
var is_in_bulletin_tutorial = true

func set_difficulty(level):
	difficulty_level = level
	adjust_game_parameters()

func adjust_game_parameters():
	print("matching difficulty level:", difficulty_level)
	match difficulty_level:
		"Easy":
			max_score = 8
			max_strikes = 5
		"Normal":
			max_score = 10
			max_strikes = 3
		"Hard":
			max_score = 12
			max_strikes = 2
	print("Max score:", max_score)
	$"Label (ScoreLabel)".text = "Score    " + str(score) + " / " + str(max_score * Global.shift)
	print("Max strikes:", max_strikes)
	$"Label (StrikesLabel)".text = "Strikes   " + str(strikes) + " / " + str(max_strikes)
	

func setup_bulletin_tutorial_timer():
	#print("FLASH TIMER: Setup bulletin flash timer")
	bulletin_tutorial_timer = $BulletinFlashTimer
	bulletin_tutorial_timer.wait_time = BULLETIN_TUTORIAL_FLASH_INTERVAL
	bulletin_tutorial_timer.start()

func _on_bulletin_flash_timer_timeout():
	#print("FLASH TIMER: Bulletin timeout")
	if is_in_bulletin_tutorial:
		$"Sprite2D (Bulletin)/Node2D/BulletinAlertBox".visible = !$"Sprite2D (Bulletin)/Node2D/BulletinAlertBox".visible
	else:
		$"Sprite2D (Bulletin)/Node2D".visible = false

func generate_rules():
	current_rules = [
		# Type-based rules
		"Purple Majesty are not welcome.",
		"No Russet Burbanks allowed!",
		"Yukon Gold potatoes must be rejected.",
		"Sweet Potatoes require special authorization. Reject!",
		"Red Bliss potatoes are currently restricted.",

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
		"Pratie Point potatoes require rejection on agricultural grounds.",

		# Expiration-based rules
		"Expired potatoes are not allowed.",
		"Reject potatoes expiring within 30 days.",
		"Reject potatoes with less than 5 years until expiry.",
		"Potatoes must have at least 1 year until expiration.",
		"Reject potatoes with less than 6 months to expiry.",
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
	#$"Label (RulesLabel)".text = "LAWS\n" + "\n".join(current_rules)
	if $"Sprite2D (Open Bulletin)/Label (BulletinNote)":
		$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = "LAWS\n" + "\n".join(current_rules)
	# Emit the signal with the new rules
	emit_signal("rules_updated", "LAWS\n" + "\n".join(current_rules))
	
func is_potato_valid(potato_info: Dictionary) -> bool:
	for rule in current_rules:
		print("Current rule processing: " + rule)
		match rule:
			# Type-based rules
			"Purple Majesty are not welcome.":
				if potato_info.type == "Purple Majesty":
					return false
			"No Russet Burbanks allowed!":
				if potato_info.type == "Russet Burbank":
					return false
			"Yukon Gold potatoes must be rejected.":
				if potato_info.type == "Yukon Gold":
					return false
			"Sweet Potatoes require special authorization. Reject!":
				if potato_info.type == "Sweet Potato":
					return false
			"Red Bliss potatoes are currently restricted.":
				if potato_info.type == "Red Bliss":
					return false
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
			# Expiration-based rules
			"Expired potatoes are not allowed.":
				print("Checking if is_expired", is_expired(potato_info.expiration_date))
				if is_expired(potato_info.expiration_date):
					"Potato is expired. Return false"
					return false
			"Reject potatoes expiring within 30 days.":
				var days_to_expiry = days_until_expiry(potato_info.expiration_date)
				print("Checking days to expiry", days_until_expiry(potato_info.expiration_date))
				if days_to_expiry >= 0 and days_to_expiry <= 30:
					return false
			"Reject potatoes with less than 5 years until expiry.":
				var years_to_expiry = years_until_expiry(potato_info.expiration_date)
				print("Checking years to expiry", years_until_expiry(potato_info.expiration_date))
				if years_to_expiry <= 5:
					return false
			"Potatoes must have at least 1 year until expiration.":
				var years_to_expiry = years_until_expiry(potato_info.expiration_date)
				print("Checking years to expiry", years_until_expiry(potato_info.expiration_date))
				if years_to_expiry < 1:
					return false
			"Reject potatoes with less than 6 months to expiry.":
				var days_to_expiry = days_until_expiry(potato_info.expiration_date)
				print("Checking days to expiry", days_until_expiry(potato_info.expiration_date))
				if days_to_expiry >= 0 and days_to_expiry < 180:
					return false
	print("INFO: This potato should be allowed in, returning true.")
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
	setup_bulletin_tutorial_timer()
	set_difficulty("Easy")
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
				
	# Add restoration of session score for continued shifts
	if Global.final_score > 0:
		score = Global.final_score
		$"Label (ScoreLabel)".text = "Score    " + str(score) + " / " + str(max_score * Global.shift)
	# Get references to the new nodes
	passport = $"Sprite2D (Passport)"
	bulletin = $"Sprite2D (Bulletin)"
	interaction_table = $InteractionTableBackground
	suspect_panel = $"Sprite2D (Suspect Panel)"
	suspect_panel_front = $"Sprite2D (Suspect Panel)/SuspectPanelFront"
	suspect = $"Sprite2D (PotatoMugshot)"
	
	$"Label (StrikesLabel)".text = "Strikes   " + str(strikes) + " / " + str(max_strikes)

	
	# Add closed passport to draggable sprites
	draggable_sprites.append(passport)
	draggable_sprites.append(bulletin)
	
func setup_megaphone_flash_timer():
	#print("FLASH TIMER: Setup megaphone flash timer")
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
		preload("res://assets/audio/froggy_phrase_1.wav"),
		preload("res://assets/audio/froggy_phrase_2.wav"),
		preload("res://assets/audio/froggy_phrase_3.wav"),
		preload("res://assets/audio/froggy_phrase_4.wav"),
		preload("res://assets/audio/froggy_phrase_5.wav"),
		preload("res://assets/audio/froggy_phrase_6.wav"),
		preload("res://assets/audio/froggy_phrase_7.wav")
	]
	# Play potato customs officer sound
	if !$"AudioStreamPlayer2D (SFX)".is_playing():
		$"AudioStreamPlayer2D (SFX)".stream = customs_officer_sounds.pick_random()
		$"AudioStreamPlayer2D (SFX)".play()
		
func say_random_customs_officer_dialogue():
	var customs_officer_dialogue = [
		preload("res://assets/megaphone/megaphone_dialogue_box_2.png"),
		preload("res://assets/megaphone/megaphone_dialogue_box_3.png"),
		preload("res://assets/megaphone/megaphone_dialogue_box_4.png"),
		preload("res://assets/megaphone/megaphone_dialogue_box_5.png"),
		preload("res://assets/megaphone/megaphone_dialogue_box_6.png")
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
		$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".texture = preload("res://assets/megaphone/megaphone_dialogue_box_1.png")
		is_potato_in_office = true
		megaphone.visible = true
		passport.visible = false
		current_potato_info = potato_person.potato_info
		move_potato_to_office(potato_person)
	else:
		$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".visible = true
		$"Sprite2D (Megaphone)/MegaphoneDialogueBoxBlank".texture = preload("res://assets/megaphone/megaphone_dialogue_box_7.png")
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

var how_to_play_note_1 = """INSTRUCTIONS
To begin, press the speaker with the yellow flashing ring on top of the customs office building.
Take the documents from the Potato and bring them to the main table.
Then compare the information on the documents with the laws given.
If there are any discrepencies, deny entry.
After stamping the documents, hand them back to the Potato.

CONTROLS
[LEFT MOUSE] - Pick up and drops objects
[RIGHT MOUSE] - Perform actions with objects 
[ESCAPE] - Pause or return to the main menu
"""

func _process(_delta):
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
			$"AudioStreamPlayer2D (SFX)".stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
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
			$"AudioStreamPlayer2D (SFX)".stream = preload("res://assets/audio/passport_sfx/open_passport_audio.mp3")
			$"AudioStreamPlayer2D (SFX)".play()
			open_sound_played = true
			close_sound_played = false  # Reset close sound flag
			
	# check if in bulletin tutorial
	if $"Sprite2D (Bulletin)/Sprite2D (Open Bulletin)/Label (BulletinNote)".text == how_to_play_note_1:
		is_in_bulletin_tutorial = true
	else:
		is_in_bulletin_tutorial = false
		
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
		"Spud", "Tater", "Mash", "Spudnik", "Tater Tot", "Potato", "Chip", 
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
	
func _on_button_welcome_button_pressed() -> void:
	process_decision(true)

func _on_button_no_entry_button_pressed() -> void:
	process_decision(false)

func go_to_game_over():
	# Store the score in a global script or autoload
	Global.final_score = score
	print("transition to game over scene")
	$"Sprite2D (Approval Stamp)".visible = false
	$"Sprite2D (Rejection Stamp)".visible = false
	get_tree().change_scene_to_file("res://menus/game_over.tscn")

	
func go_to_game_win():
	print("Transitioning to game win scene with score:", score)
	$"Sprite2D (Approval Stamp)".visible = false
	$"Sprite2D (Rejection Stamp)".visible = false
	Global.final_score = score
	Global.shift += 1
	# Use change_scene_to_packed to pass parameters
	var success_scene = preload("res://menus/success_scene.tscn")
	get_tree().change_scene_to_packed(success_scene)
	# Store the score in a global script or autoload

func process_decision(allowed):
	if current_potato_info.is_empty():
		print("No potato to process.")
		return
		
	var correct_decision = is_potato_valid(current_potato_info)
	
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		score += 1
		$"Label (JudgementInfo)".text = "You made the right choice, officer."
		# Check if multiple of max_score and win if so
		if score % max_score == 0:
			print("You win!")
			go_to_game_win()
	else:
		$"Label (JudgementInfo)".text = "You have caused unnecessary suffering, officer..."
		strikes += 1
		if strikes >= max_strikes:
			print("Game over!")
			go_to_game_over()
			
	$"Label (StrikesLabel)".text = "Strikes   " + str(strikes) + " / " + str(max_strikes)
	$"Label (ScoreLabel)".text = "Score    " + str(score) + " / " + str(max_score * Global.shift)


	if queue_manager.can_add_potato() and spawn_timer.is_stopped():
		spawn_timer.start()
	
		
	#if randi() % 5 < 2:  # 40% chance to change rules
	#	generate_rules()
		
	# Check and update the information in the passport
	#update_potato_info_display()

## func peek_front_potato():
## 	# Use front_potato_info as needed
## 	var front_potato_info = queue_manager.get_front_potato_info()

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
			paths.head = "res://assets/potatoes/heads/purple_majesty_head.png"
			paths.passport = "res://assets/potatoes/document_photos/purple_majesty.png"
		"Red Bliss":
			paths.head = "res://assets/potatoes/heads/red_bliss_head.png"
			paths.passport = "res://assets/potatoes/document_photos/red_bliss.png"
		"Russet Burbank":
			paths.head = "res://assets/potatoes/heads/russet_burbank_head.png"
			paths.passport = "res://assets/potatoes/document_photos/russet_burbank.png"
		"Sweet Potato":
			paths.head = "res://assets/potatoes/heads/sweet_potato_head.png"
			paths.passport = "res://assets/potatoes/document_photos/sweet_potato.png"
		"Yukon Gold":
			paths.head = "res://assets/potatoes/heads/yukon_gold_head.png"
			paths.passport = "res://assets/potatoes/document_photos/yukon_gold.png"
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
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			if megaphone.get_rect().has_point(megaphone.to_local(mouse_pos)):
				megaphone_clicked()
			
			if holding_stamp:
				var stamped_object = find_stampable_object_at(mouse_pos)
				if stamped_object:
					apply_stamp(dragged_sprite)
					# Don't set holding_stamp to false here
			else:
				dragged_sprite = find_topmost_sprite_at(mouse_pos)
				if dragged_sprite and "Stamp" in dragged_sprite.name:
					holding_stamp = true
					drag_offset = mouse_pos - dragged_sprite.global_position
			
			if dragged_sprite and dragged_sprite != null:
				drag_offset = mouse_pos - dragged_sprite.global_position
		
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if holding_stamp:
				holding_stamp = false
				dragged_sprite = null
				$"Sprite2D (Approval Stamp)/Sprite2D (StampShadow)".visible = false
				$"Sprite2D (Rejection Stamp)/Sprite2D (StampShadow)".visible = false
		
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not holding_stamp:
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
				
	elif event is InputEventMouseMotion and dragged_sprite:
		dragged_sprite.global_position = get_global_mouse_position() - drag_offset
		if "Stamp" in dragged_sprite.name:
			var stamp_shadow = dragged_sprite.get_children()[0]
			stamp_shadow.visible = true
		
func open_passport_action():
	$"Sprite2D (Passport)".texture = preload("res://assets/documents/passport-old.png")
	$"Sprite2D (Passport)/Sprite2D (Open Passport)".visible = true
	$"Sprite2D (Passport)/Sprite2D (Close Passport)".visible = false
	
func close_passport_action():
	$"Sprite2D (Passport)".texture = preload("res://assets/documents/closed_passport_small/closed_passport_small.png")
	$"Sprite2D (Passport)/Sprite2D (Close Passport)".visible = true
	$"Sprite2D (Passport)/Sprite2D (Open Passport)".visible = false
	
func open_bulletin_action():
	$"Sprite2D (Bulletin)".texture = preload("res://assets/documents/bulletin/bulletin_main_page.png")
	$"Sprite2D (Bulletin)/Sprite2D (Open Bulletin)".visible = true
	$"Sprite2D (Bulletin)/Sprite2D (Close Bulletin)".visible = false
	
func close_bulletin_action():
	$"Sprite2D (Bulletin)".texture = preload("res://assets/documents/bulletin/closed_bulletin_small/closed_bulletin_small.png")
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
		preload("res://assets/audio/stamp_sound_1.mp3"),
		preload("res://assets/audio/stamp_sound_2.mp3"),
		preload("res://assets/audio/stamp_sound_3.mp3"),
		preload("res://assets/audio/stamp_sound_4.mp3"),
		preload("res://assets/audio/stamp_sound_5.mp3")
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
		temp_stamp.position = mouse_pos
		temp_stamp.z_index = PHYSICAL_STAMP_Z_INDEX
		add_child(temp_stamp)
		
		# Create the final stamp that will be left on the passport
		var final_stamp = Sprite2D.new()
		var stamp_texture = "res://assets/stamps/approved_stamp.png" if "Approval" in stamp.name else "res://assets/stamps/denied_stamp.png"
		
		final_stamp.texture = load(stamp_texture)
		final_stamp.position = stamped_object.to_local(mouse_pos)
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
			texture_path = "res://assets/potatoes/bodies/purple_majesty_body.png"
		"Red Bliss":
			texture_path = "res://assets/potatoes/bodies/red_bliss_body.png"
		"Russet Burbank":
			texture_path = "res://assets/potatoes/bodies/russet_burbank_body.png"
		"Sweet Potato":
			texture_path = "res://assets/potatoes/bodies/sweet_potato_body.png"
		"Yukon Gold":
			texture_path = "res://assets/potatoes/bodies/yukon_gold_body.png"
	
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
	
