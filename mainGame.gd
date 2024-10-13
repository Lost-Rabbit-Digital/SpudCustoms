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

# track win and lose parameters
var score = 0
var max_score = 10
var strikes = 0
var max_strikes = 3

# timer for limiting shift processing times
var processing_time = 60  # seconds
var current_timer = 0 # seconds

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

# Dragging system
var draggable_sprites = []
var dragged_sprite = null
var drag_offset = Vector2()
const PHYSICAL_STAMP_Z_INDEX = 100
const APPLIED_STAMP_Z_INDEX = 50
const PASSPORT_Z_INDEX = 0

# Passport dragging system
var passport: Sprite2D
var inspection_table: Sprite2D
var suspect_panel: Sprite2D
var suspect_panel_front: Sprite2D
var suspect: Sprite2D
var is_passport_open = false

@onready var time_label = $Gameplay/Labels/TimeLabel
var label_tween: Tween

# Bulletin dragging system
var bulletin: Sprite2D
var is_bulletin_open = false

# Rulebook dragging system
var rulebook: Sprite2D
var is_rulebook_open = false

var difficulty_level = "Hard"  # Can be "Easy", "Normal", or "Hard"

# Stamp system
const STAMP_ANIMATION_DURATION = 0.3  # Duration of the stamp animation in seconds
const STAMP_MOVE_DISTANCE = 36  # How far the stamp moves down

var bulletin_tutorial_timer: Timer
const BULLETIN_TUTORIAL_FLASH_INTERVAL = 1.0 # flash every 1 seconds
var is_in_bulletin_tutorial = true

@onready var megaphone = $Gameplay/CustomsOffice/Megaphone
@onready var potato_mugshot = $Gameplay/PotatoMugshot
@onready var enter_office_path = $Gameplay/Paths/EnterOfficePath

func _ready():
	setup_megaphone_flash_timer()
	setup_bulletin_tutorial_timer()
	set_difficulty(difficulty_level)
	update_date_display()
	queue_manager = $SystemManagers/QueueManager  # Make sure to add QueueManager as a child of Main
	generate_rules()
	setup_spawn_timer()
	draggable_sprites = [
		$Gameplay/InteractiveElements/Passport,
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
				
	# Add restoration of session score for continued shifts
	if Global.final_score > 0:
		score = Global.final_score
		$UI/Labels/ScoreLabel.text = "Score    " + str(score) + " / " + str(max_score * Global.shift)
	# Get references to the new nodes
	passport = $Gameplay/InteractiveElements/Passport
	bulletin = $Gameplay/InteractiveElements/Bulletin
	rulebook = $"Sprite2D (Rulebook)"
	inspection_table = $Gameplay/InspectionTable
	suspect_panel = $Gameplay/SuspectPanel
	suspect_panel_front = $Gameplay/SuspectPanel/SuspectPanelFront
	suspect = $Gameplay/PotatoMugshot
	
	$"Label (StrikesLabel)".text = "Strikes   " + str(strikes) + " / " + str(max_strikes)

	# Add closed passport to draggable sprites
	draggable_sprites.append(passport)
	draggable_sprites.append(bulletin)
	draggable_sprites.append(rulebook)
	
func setup_megaphone_flash_timer():
	#print("FLASH TIMER: Setup megaphone flash timer")
	megaphone_flash_timer = $SystemManagers/Timers/MegaphoneFlashTimer
	megaphone_flash_timer.wait_time = MEGAPHONE_FLASH_INTERVAL
	megaphone_flash_timer.start()
	
func set_difficulty(level):
	difficulty_level = level
	adjust_game_parameters()

func adjust_game_parameters():
	print("matching difficulty level:", difficulty_level)
	match difficulty_level:
		"Easy":
			max_score = 8
			max_strikes = 5
			processing_time = 60
		"Normal":
			max_score = 10
			max_strikes = 3
			processing_time = 45
		"Hard":
			max_score = 12
			max_strikes = 2
			processing_time = 15
	print("Max score:", max_score)
	$"Label (ScoreLabel)".text = "Score    " + str(score) + " / " + str(max_score * Global.shift)
	print("Max strikes:", max_strikes)
	$"Label (StrikesLabel)".text = "Strikes   " + str(strikes) + " / " + str(max_strikes)
	

func setup_bulletin_tutorial_timer():
	#print("FLASH TIMER: Setup bulletin flash timer")
	bulletin_tutorial_timer = $SystemManagers/Timers/BulletinFlashTimer
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
	print("INFO: This potato should be allowed in, returning true.")
	return true


func update_date_display():
	var current_date = Time.get_date_dict_from_system()
	var formatted_date = "%04d.%02d.%02d" % [current_date.year, current_date.month, current_date.day]
	$"Label (DateLabel)".text = formatted_date

func _on_megaphone_flash_timer_timeout():
	if not is_potato_in_office:
		$Gameplay/CustomsOffice/Megaphone/FlashAlert.visible = !$Gameplay/CustomsOffice/Megaphone/FlashAlert.visible
	else:
		$Gameplay/CustomsOffice/Megaphone/FlashAlert.visible = false

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
	$Gameplay/CustomsOffice/Megaphone/MegaphoneDialogueBoxBlank.visible = true
	$Gameplay/CustomsOffice/Megaphone/MegaphoneDialogueBoxBlank.texture = customs_officer_dialogue.pick_random()
		
		
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
		$Gameplay/CustomsOffice/Megaphone/MegaphoneDialogueBoxBlank.visible = true
		$Gameplay/CustomsOffice/Megaphone/MegaphoneDialogueBoxBlank.texture = preload("res://assets/megaphone/megaphone_dialogue_box_1.png")
		is_potato_in_office = true
		megaphone.visible = true
		passport.visible = false
		current_potato_info = potato_person.potato_info
		move_potato_to_office(potato_person)
	else:
		$Gameplay/CustomsOffice/Megaphone/MegaphoneDialogueBoxBlank.visible = true
		$Gameplay/CustomsOffice/Megaphone/MegaphoneDialogueBoxBlank.texture = preload("res://assets/megaphone/megaphone_dialogue_box_7.png")
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
	passport = $Gameplay/InteractiveElements/Passport
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
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if queue_manager.can_add_potato():
		queue_manager.spawn_new_potato()
	else:
		print("Potato queue limit reached, skip spawning.")
		#spawn_timer.stop()

var how_to_play_note_1 = """INSTRUCTIONS
To begin, press the speaker with the yellow flashing ring on top of the customs office building.
Take the documents from the Potato and bring them to the main table.
Compare the information on the documents with the laws given in your rulebook.
If there are any violated laws, or the potato is expired, deny entry.
After stamping the documents, hand them back to the Potato.

CONTROLS
[LEFT MOUSE] - Pick up and perform actions with objects
[RIGHT MOUSE] - Drop objects 
[ESCAPE] - Pause or return to the main menu
"""

func start_label_tween():
	# Create a new Tween
	label_tween = create_tween().set_loops()
	
	# Tween font size
	label_tween.tween_property(time_label, "theme_override_font_sizes/font_size", 16, 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	label_tween.tween_property(time_label, "theme_override_font_sizes/font_size", 12, 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Tween color
	label_tween.parallel().tween_property(time_label, "theme_override_colors/font_color", Color.RED, 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	label_tween.tween_property(time_label, "theme_override_colors/font_color", Color.WHITE, 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(_delta):
	# Processing timer implementation
	if is_potato_in_office:
		# Show label if potato in customs office
		$UI/Labels/TimeLabel.visible = true
		current_timer += _delta
		$UI/Labels/TimeLabel.text = "Time Left: %s" % str(int(processing_time) - int(current_timer))
		# Update _process to change Time Left: display each second after timer incremented
		if int(processing_time) - int(current_timer) < 5: 
			start_label_tween()
			# Tween text in $"Label (TimeLabel)" between font_size 
			# 12 and 16 w/ easing function, flash red
		if int(current_timer) >= int(processing_time):
			timedOut()
			move_potato_along_path("timedOut")
			is_potato_in_office = false
			# Implicit rejection of potatos via the process_decision(false) function 
			# carries the risk of accidentally passing a potato and improving player score
			# This should be its' own force_decision(), maybe where the Supervisor says 
			# what the right answer was too before punishing the player.
			# Time's up, force a decision or penalize the player
			# move_potato_along_path(approval_status) controls moving the player based on approval status
			# We can add a new approval status (timed_out), and have the potato take a different route. 
			# we can put that logic as well as the logic for adding a strike into the force_decision() function
	else:
		# Hide label if potato is not in/has left customs office
		$UI/Labels/TimeLabel.visible = false
		current_timer = 0
	
	var mouse_pos = get_global_mouse_position()
	if suspect.get_rect().has_point(suspect.to_local(mouse_pos)) and dragged_sprite == passport and is_passport_open == false:
		$Gameplay/InteractiveElements/Passport/ClosedPassport/GivePromptDialogue.visible = true
	else:
		$Gameplay/InteractiveElements/Passport/ClosedPassport/GivePromptDialogue.visible = false
		
	if !$SystemManagers/AudioManager/SFXPool.is_playing():
		$Gameplay/CustomsOffice/Megaphone/MegaphoneDialogueBoxBlank.visible = false
	
	if is_paused == true:
		$PauseContainer/PauseMenu.visible = true
		$Gameplay/InteractiveElements/ApprovalStamp.visible = false
		$Gameplay/InteractiveElements/RejectionStamp.visible = false
	else:
		$Container/pause_menu.visible = false
		$Gameplay/InteractiveElements/ApprovalStamp.visible = true
		$Gameplay/InteractiveElements/RejectionStamp.visible = true
		
	# Check for closing passport
	if (suspect_panel.get_rect().has_point(suspect_panel.to_local(mouse_pos)) or 
		suspect.get_rect().has_point(suspect.to_local(mouse_pos))) and (dragged_sprite == bulletin or dragged_sprite == passport or dragged_sprite == rulebook):
		if not close_sound_played:
			if dragged_sprite == passport:
				close_passport_action()
			elif dragged_sprite == bulletin:
				close_bulletin_action()
			elif dragged_sprite == rulebook:
				close_rulebook_action()
			$SystemManagers/AudioManager/SFXPool.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
			$SystemManagers/AudioManager/SFXPool.play()
			close_sound_played = true
			open_sound_played = false  # Reset open sound flag
	
	# Check for opening passport
	if inspection_table.get_rect().has_point(inspection_table.to_local(mouse_pos)) and (dragged_sprite == bulletin or dragged_sprite == passport or dragged_sprite == rulebook):
		if not open_sound_played:
			if dragged_sprite == passport and is_passport_open == false:
				open_passport_action()
			elif dragged_sprite == bulletin:
				open_bulletin_action()
			elif dragged_sprite == rulebook:
				open_rulebook_action()
			$SystemManagers/AudioManager/SFXPool.stream = preload("res://assets/audio/passport_sfx/open_passport_audio.mp3")
			$SystemManagers/AudioManager/SFXPool.play()
			open_sound_played = true
			close_sound_played = false  # Reset close sound flag
			
	# check if in bulletin tutorial
	if $Gameplay/InteractiveElements/Bulletin/OpenBulletin/BulletinNote.text == how_to_play_note_1:
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
		$Gameplay/InteractiveElements/Passport/OpenPassport/PotatoHeader.text = """{name}""".format(current_potato_info)
		$Gameplay/InteractiveElements/Passport/OpenPassport/PotatoInfo.text = """{date_of_birth}
		{sex} 
		{country_of_issue}
		{expiration_date} 
		{type}
		{condition}
		""".format(current_potato_info)
	else:
		print("No current_potato_info found.")
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
	$Gameplay/InteractiveElements/ApprovalStamp.visible = false
	$Gameplay/InteractiveElements/RejectionStamp.visible = false
	get_tree().change_scene_to_file("res://menus/game_over.tscn")

	
func go_to_game_win():
	print("Transitioning to game win scene with score:", score)
	$Gameplay/InteractiveElements/ApprovalStamp.visible = false
	$Gameplay/InteractiveElements/RejectionStamp.visible = false
	Global.final_score = score
	Global.shift += 1
	# Use change_scene_to_packed to pass parameters
	var success_scene = preload("res://menus/success_scene.tscn")
	get_tree().change_scene_to_packed(success_scene)
	# Store the score in a global script or autoload

func timedOut():
	$UI/Labels/JudgementLabel.text = "You took too long and they left, officer..."
	#strikes += 1
	print("current strikes: ", strikes)
	if strikes >= max_strikes:
		print("Game over!")
		go_to_game_over()
	$UI/Labels/StrikesLabel.text = "Strikes   " + str(strikes) + " / " + str(max_strikes)

func process_decision(allowed):
	print("Evaluating immigration decision in process_decision()...")
	if current_potato_info.is_empty():
		print("No potato to process.")
		return
		
	var correct_decision = is_potato_valid(current_potato_info)
	
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		score += 1
		$UI/Labels/JudgementLabel.text = "You made the right choice, officer."
		# Check if multiple of max_score and win if so
		if score % max_score == 0:
			print("You win!")
			go_to_game_win()
	else:
		$UI/Labels/JudgementLabel.text = "You have caused unnecessary suffering, officer..."
		strikes += 1
		if strikes >= max_strikes:
			print("Game over!")
			go_to_game_over()
			
	$UI/Labels/StrikesLabel.text = "Strikes   " + str(strikes) + " / " + str(max_strikes)
	$UI/Labels/ScoreLabel.text = "Score    " + str(score) + " / " + str(max_score * Global.shift)

	if queue_manager.can_add_potato() and spawn_timer.is_stopped():
		spawn_timer.start()

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
	
	var passport_photo = $Gameplay/InteractiveElements/Passport/OpenPassport/PassportPhoto
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
	$Gameplay/InteractiveElements/Passport/OpenPassport/PassportPhoto.texture = null
	
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
				$Gameplay/InteractiveElements/ApprovalStamp/StampShadow.visible = false
				$Gameplay/InteractiveElements/RejectionStamp/StampShadow.visible = false
		
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not holding_stamp:
				if dragged_sprite == passport:
					$Gameplay/InteractiveElements/Passport/ClosedPassport/GivePromptDialogue.visible = false
					var drop_pos = get_global_mouse_position()
					if inspection_table.get_rect().has_point(inspection_table.to_local(drop_pos)):
						open_passport_action()
					if suspect_panel.get_rect().has_point(suspect_panel.to_local(drop_pos)):
						close_passport_action()
					if suspect.get_rect().has_point(suspect.to_local(drop_pos)):
						close_passport_action()
						remove_stamp()
				elif dragged_sprite == bulletin:
					var drop_pos = get_global_mouse_position()
					if inspection_table.get_rect().has_point(inspection_table.to_local(drop_pos)):
						open_bulletin_action()
					if suspect_panel.get_rect().has_point(suspect_panel.to_local(drop_pos)):
						close_bulletin_action()
					if suspect.get_rect().has_point(suspect.to_local(drop_pos)):
						close_bulletin_action()
				elif dragged_sprite == rulebook:
					var drop_pos = get_global_mouse_position()
					if inspection_table.get_rect().has_point(inspection_table.to_local(drop_pos)):
						open_rulebook_action()
					if suspect_panel.get_rect().has_point(suspect_panel.to_local(drop_pos)):
						close_rulebook_action()
					if suspect.get_rect().has_point(suspect.to_local(drop_pos)):
						close_rulebook_action()
				dragged_sprite = null
				
	elif event is InputEventMouseMotion and dragged_sprite:
		dragged_sprite.global_position = get_global_mouse_position() - drag_offset
		if "Stamp" in dragged_sprite.name:
			var stamp_shadow = dragged_sprite.get_children()[0]
			stamp_shadow.visible = true
		
func open_passport_action():
	$Gameplay/InteractiveElements/Passport.texture = preload("res://assets/documents/passport-old.png")
	$Gameplay/InteractiveElements/Passport/OpenPassport.visible = true
	$Gameplay/InteractiveElements/Passport/ClosedPassport.visible = false
	
func close_passport_action():
	$Gameplay/InteractiveElements/Passport.texture = preload("res://assets/documents/closed_passport_small/closed_passport_small.png")
	$Gameplay/InteractiveElements/Passport/ClosedPassport.visible = true
	$Gameplay/InteractiveElements/Passport/OpenPassport.visible = false
	
func open_bulletin_action():
	$Gameplay/InteractiveElements/Bulletin.texture = preload("res://assets/documents/bulletin/bulletin_main_page.png")
	$Gameplay/InteractiveElements/Bulletin/OpenBulletin.visible = true
	$Gameplay/InteractiveElements/Bulletin/ClosedBulletin.visible = false
	
func close_bulletin_action():
	$Gameplay/InteractiveElements/Bulletin.texture = preload("res://assets/documents/bulletin/closed_bulletin_small/closed_bulletin_small.png")
	$Gameplay/InteractiveElements/Bulletin/ClosedBulletin.visible = true
	$Gameplay/InteractiveElements/Bulletin/OpenBulletin.visible = false
	
func open_rulebook_action():
	$"Sprite2D (Rulebook)".texture = preload("res://assets/documents/rulebook/rulebook_open.png")
	$"Sprite2D (Rulebook)/Sprite2D (Closed Rulebook)".visible = false
	$"Sprite2D (Rulebook)/Sprite2D (Open Rulebook)".visible = true
	
func close_rulebook_action():
	$"Sprite2D (Rulebook)".texture = preload("res://assets/documents/rulebook/rulebook_closed.png")
	$"Sprite2D (Rulebook)/Sprite2D (Closed Rulebook)".visible = true
	$"Sprite2D (Rulebook)/Sprite2D (Open Rulebook)".visible = false
	
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
	if !$SystemManagers/AudioManager/SFXPool.is_playing():
		$SystemManagers/AudioManager/SFXPool.stream = stamp_sounds.pick_random()
		$SystemManagers/AudioManager/SFXPool.play()

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
		$Gameplay/InteractiveElements/Passport/OpenPassport.add_child(final_stamp)
		
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
		path = $Gameplay/Paths/ApprovePath
		process_decision(true)
		
	if approval_status == "timedout":
		path = $Gameplay/Paths/TimedOutPath
		timedOut()
		
	else: 
		if randi() % 5 == 0:  # 20% chance to go sicko mode
			path = $Gameplay/Paths/RunnerPath
		else:
			path = $Gameplay/Paths/RejectPath
		process_decision(false)
			
	# Calculate score change
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	path_follow.add_child(potato_person)
	
	potato_person.position = Vector2.ZERO
	path_follow.progress_ratio = 0.0
	
	passport = $Gameplay/InteractiveElements/Passport
	passport.modulate.a = 0
	
	var exit_tween = create_tween()
	if "Approve" in path:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 10.0)
	if "Reject" in path:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 9.0)
	if "TimedOut" in path:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 9.0)
	else:
		exit_tween.tween_property(path_follow, "progress_ratio", 1.0, 8.0)
		
	exit_tween.tween_callback(func():
		potato_person.queue_free()
		path_follow.queue_free()
		reset_scene()
		)
	
func reset_scene():
	potato_mugshot.position.x = suspect_panel.position.x
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
	
