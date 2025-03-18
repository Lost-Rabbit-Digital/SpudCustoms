extends Node
class_name StampSystem

# Signals
signal stamp_applied(stamp: StampComponent, document: Node, is_perfect: bool)
signal stamp_animation_started(stamp_type: String)
signal stamp_animation_completed(stamp_type: String)

# Constants
const STAMP_ANIM_DURATION = 0.3  # Duration of stamp animation in seconds
const STAMP_COOLDOWN = 1.0  # Cooldown between stamps

# Configuration
var stamp_textures = {
	"approve": preload("res://assets/stamps/approval_stamp_3.png"),
	"reject": preload("res://assets/stamps/rejection_stamp_2.png")
}

var stamp_result_textures = {
	"approve": preload("res://assets/stamps/approved_stamp.png"),
	"reject": preload("res://assets/stamps/denied_stamp.png")
}

# State tracking
var is_stamping = false
var current_stamp_type = ""
var current_stamp_texture: Texture2D
var stamp_cooldown_timer = 0.0
var stampable_documents: Dictionary = {}  # Maps document nodes to StampableComponent

# Audio
var audio_player: AudioStreamPlayer2D
var stamp_sounds = []

# Shake effect
var shake_callback: Callable

# Constructor - we need to pass in audio player from the main scene
func _init(audio: AudioStreamPlayer2D, shake_func: Callable):
	audio_player = audio
	shake_callback = shake_func
	
	# Load stamp sounds
	for i in range(1, 6):
		stamp_sounds.append(
			"res://assets/audio/mechanical/stamp_sound_" + str(i) + ".mp3"
		)

func _process(delta):
	# Update cooldown timer
	if stamp_cooldown_timer > 0:
		stamp_cooldown_timer -= delta

# Register a document that can be stamped
func register_stampable(document: Node2D, content_node: Node, stamp_area: Rect2 = Rect2()) -> StampableComponent:
	var stampable = StampableComponent.new(document, content_node, stamp_area)
	
	# Connect signals
	stampable.stamped.connect(_on_document_stamped)
	stampable.stamp_applied.connect(_on_stamp_applied)
	
	# Store in our dictionary
	stampable_documents[document] = stampable
	
	if stampable:
		stampable.visualize_stamp_area()
	
	return stampable

# Unregister a document
func unregister_stampable(document: Node2D):
	if stampable_documents.has(document):
		stampable_documents.erase(document)

# Get the stampable component for a document
func get_stampable(document: Node2D) -> StampableComponent:
	if stampable_documents.has(document):
		return stampable_documents[document]
	return null

# Handle a stamp request
func on_stamp_requested(stamp_type: String, stamp_texture: Texture2D = null, source_node: Node = null):
	if is_stamping or stamp_cooldown_timer > 0:
		return
		
	current_stamp_type = stamp_type
	
	# Use provided texture or default to our own
	if stamp_texture != null:
		current_stamp_texture = stamp_texture
	else:
		current_stamp_texture = stamp_textures[stamp_type]
	
	# Get mouse position for target
	var target_position = get_viewport().get_mouse_position()
	
	# Tell the UI controller to animate the stamp (visual feedback only)
	var stamp_bar = source_node if source_node is Node2D else null
	if stamp_bar and stamp_bar.has_method("animate_stamp"):
		stamp_bar.animate_stamp(stamp_type, target_position)
	
	# Actual stamp application logic
	is_stamping = true
	emit_signal("stamp_animation_started", stamp_type)
	
	# Find document under cursor
	for document in stampable_documents.keys():
		var stampable = stampable_documents[document]
		if stampable.is_valid_stamp_position(target_position):
			# Create new stamp component
			var stamp = StampComponent.new(stamp_type, stamp_result_textures[stamp_type])
			
			# Apply to document
			stampable.apply_stamp(stamp, target_position)
			
			# Trigger screen shake if callback is valid
			if shake_callback.is_valid():
				shake_callback.call(4.0, 0.2)
			
			break
	
	# Set cooldown and finish
	stamp_cooldown_timer = STAMP_COOLDOWN
	is_stamping = false
	emit_signal("stamp_animation_completed", stamp_type)

# Apply a stamp animation
func apply_stamp(stamp_type: String, stamp_bar: Node = null):
	if not current_stamp_texture:
		return
		
	is_stamping = true
	play_random_stamp_sound()
	emit_signal("stamp_animation_started", stamp_type)
	
	# Get the mouse position for target
	var target_position = get_viewport().get_mouse_position()
	
	# Create temporary stamp for animation
	var temp_stamp = Sprite2D.new()
	temp_stamp.texture = current_stamp_texture
	temp_stamp.z_index = 20  # Ensure it appears above everything during animation
	
	# Start from the appropriate button based on stamp type
	var start_pos = Vector2(0, 0)
	
	# If stamp_bar is provided, get the actual button positions
	if stamp_bar:
		if stamp_type == "approve" and stamp_bar.has_node("StampBar/ApprovalStamp"):
			var approve_button = stamp_bar.get_node("StampBar/ApprovalStamp")
			start_pos = approve_button.global_position
		elif stamp_bar.has_node("StampBar/RejectionStamp"):
			var reject_button = stamp_bar.get_node("StampBar/RejectionStamp")
			start_pos = reject_button.global_position
	
	temp_stamp.global_position = start_pos
	
	add_child(temp_stamp)
	
	# Animate stamp movement
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move to target position
	tween.tween_property(temp_stamp, "global_position", target_position, STAMP_ANIM_DURATION/2)
	
	# Apply final stamp to document
	var document_found = false
	
	# *** Debug: Print all documents in our registry ***
	print("Looking for document at position: ", target_position)
	print("Number of registered stampable documents: ", stampable_documents.size())
	for doc in stampable_documents.keys():
		print("Document in registry: ", doc.name if doc else "null")
	
	# Find document under cursor - add debugging info
	for document in stampable_documents.keys():
		var stampable = stampable_documents[document]
		print("Checking document: ", document.name)
		print("Is valid position: ", stampable.is_valid_stamp_position(target_position))
		
		if stampable.is_valid_stamp_position(target_position):
			print("Valid stamp position found for: ", document.name)
			# Create new stamp component
			var stamp = StampComponent.new(stamp_type, stamp_result_textures[stamp_type])
			
			# Apply to document
			stampable.apply_stamp(stamp, target_position)
			document_found = true
			
			# Trigger screen shake
			if shake_callback.is_valid():
				shake_callback.call(4.0, 0.2)  # Mild shake for stamping
			
			break
	
	if not document_found:
		print("No document found at position: ", target_position)
	
	# Return animation
	var return_tween = create_tween()
	return_tween.tween_property(temp_stamp, "global_position", start_pos, STAMP_ANIM_DURATION/2)
	return_tween.tween_callback(func():
		temp_stamp.queue_free()
		is_stamping = false
		stamp_cooldown_timer = STAMP_COOLDOWN
		emit_signal("stamp_animation_completed", stamp_type)
	)

# Play a random stamp sound
func play_random_stamp_sound():
	if audio_player and stamp_sounds.size() > 0:
		# Actually load the audio files
		var sound_files = []
		for sound_path in stamp_sounds:
			var sound = load(sound_path)
			if sound:
				sound_files.append(sound)
			else:
				push_warning("Could not load stamp sound: " + sound_path)
		
		if sound_files.size() > 0:
			audio_player.stream = sound_files[randi() % sound_files.size()]
			audio_player.play()
		else:
			push_warning("No stamp sounds could be loaded")
	else:
		push_warning("STAMP SYSTEM: NO AUDIO SETUP FOR STAMPS")

# Signal handlers
func _on_document_stamped(stamp: StampComponent):
	# Do additional processing here if needed
	pass

func _on_stamp_applied(stamp: StampComponent, is_perfect: bool):
	emit_signal("stamp_applied", stamp, stamp.applied_to, is_perfect)
