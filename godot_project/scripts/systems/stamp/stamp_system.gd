extends Node
class_name StampSystem

# Signals
signal stamp_applied(stamp: StampComponent, document: Node, is_perfect: bool)
signal stamp_animation_started(stamp_type: String)
signal stamp_animation_completed(stamp_type: String)

# Constants
const STAMP_ANIM_DURATION = 0.2  # Duration of stamp animation in seconds
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
	
	# Call the apply_stamp function directly with the source node
	apply_stamp(stamp_type, source_node)

# Apply a stamp animation using the existing UI stamps with a fixed vertical offset
# In StampSystem.gd

func apply_stamp(stamp_type: String, stamp_bar: Node = null):
	if is_stamping or stamp_cooldown_timer > 0:
		return
		
	is_stamping = true
	current_stamp_type = stamp_type
	
	# Play sound effect
	play_random_stamp_sound()
	emit_signal("stamp_animation_started", stamp_type)
	
	# Get the fixed stamp position from the stamp bar
	var fixed_stamp_position = Vector2.ZERO
	if stamp_bar and stamp_bar.has_method("get_stamp_origin"):
		# Use the stamp bar's method to get the stamp origin (source position)
		var stamp_origin = stamp_bar.get_stamp_origin()
		
		# Calculate the fixed stamp position directly below the stamp bar
		fixed_stamp_position = Vector2(stamp_origin.x, stamp_origin.y + 120)  # Offset by 120 pixels down
	else:
		# Fallback to center of screen if no stamp bar
		fixed_stamp_position = get_viewport().get_visible_rect().size / 2
	
	# Find the appropriate stamp button in the UI
	var stamp_button: TextureButton = null
	var original_position: Vector2 = Vector2.ZERO
	var original_scale: Vector2 = Vector2.ONE
	var original_rotation: float = 0.0
	
	if stamp_bar:
		# Get the approval or rejection button based on stamp type
		if stamp_type == "approve" and stamp_bar.has_node("%ApprovalButton"):
			stamp_button = stamp_bar.get_node("%ApprovalButton")
			original_position = stamp_button.global_position
			original_scale = stamp_button.scale
			original_rotation = stamp_button.rotation
		elif stamp_type == "reject" and stamp_bar.has_node("%RejectionButton"):
			stamp_button = stamp_bar.get_node("%RejectionButton")
			original_position = stamp_button.global_position
			original_scale = stamp_button.scale
			original_rotation = stamp_button.rotation
	
	if not stamp_button:
		push_warning("Could not find stamp button for animation")
		is_stamping = false
		return
	
	# Store the original z_index to restore later
	var original_z_index = stamp_button.z_index
	var original_mouse_filter = stamp_button.mouse_filter
	
	# Temporarily disable button interaction during animation
	stamp_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create the tween for animation
	var tween = create_tween()
	tween.set_parallel(true)  # Parallel for position, scale and rotation
	
	# Move to fixed position with slight scaling and rotation
	tween.tween_property(stamp_button, "global_position", fixed_stamp_position, STAMP_ANIM_DURATION/2)
	tween.tween_property(stamp_button, "scale", original_scale * randf_range(0.9, 1.1), STAMP_ANIM_DURATION/2)
	tween.tween_property(stamp_button, "rotation", original_rotation + randf_range(-0.1, 0.1), STAMP_ANIM_DURATION/2)
	
	# Second tween after reaching target
	var second_tween = create_tween()
	second_tween.set_parallel(false)  # Sequential for the impact effect
	second_tween.tween_callback(func():
		# Apply slight "press down" scaling effect
		var press_tween = create_tween()
		press_tween.set_parallel(true)
		press_tween.tween_property(stamp_button, "scale", original_scale * 0.9, STAMP_ANIM_DURATION/6)
		
		# Apply the actual stamp at the fixed position, not at the mouse position
		var document_found = false
		
		# Find document under the fixed stamp position
		for document in stampable_documents.keys():
			var stampable = stampable_documents[document]
			
			if stampable.is_valid_stamp_position(fixed_stamp_position):
				# Create new stamp component
				var stamp = StampComponent.new(stamp_type, stamp_result_textures[stamp_type])
				
				# Check if this is a perfect stamp based on document position
				var is_perfect = stampable.is_perfect_stamp_position(fixed_stamp_position)
				stamp.is_perfect = is_perfect
				
				# Apply to document
				stampable.apply_stamp(stamp, fixed_stamp_position)
				document_found = true
				
				# Trigger screen shake
				if shake_callback.is_valid():
					shake_callback.call(4.0, 0.2)  # Mild shake for stamping
				
				break
		
		if not document_found:
			print("No document found at fixed position: ", fixed_stamp_position)
	).set_delay(STAMP_ANIM_DURATION/2)  # Delay to match first tween duration
	
	# Return animation with slight bounce effect
	second_tween.tween_callback(func():
		var return_tween = create_tween()
		return_tween.set_parallel(true)
		return_tween.tween_property(stamp_button, "global_position", original_position, STAMP_ANIM_DURATION/2)
		return_tween.tween_property(stamp_button, "scale", original_scale, STAMP_ANIM_DURATION/2).set_trans(Tween.TRANS_BOUNCE)
		return_tween.tween_property(stamp_button, "rotation", original_rotation, STAMP_ANIM_DURATION/2)
		
		# Restore original properties and set state when done
		return_tween.tween_callback(func():
			stamp_button.z_index = original_z_index
			stamp_button.mouse_filter = original_mouse_filter
			is_stamping = false
			stamp_cooldown_timer = STAMP_COOLDOWN
			emit_signal("stamp_animation_completed", stamp_type)
		)
	).set_delay(STAMP_ANIM_DURATION/6)  # Short delay for the press effect

func check_perfect_alignment(document: Node2D, stamp_position: Vector2) -> bool:
	# Convert stamp position to document-local coordinates
	var local_stamp_pos = document.to_local(stamp_position)
	
	# Get the document size
	var doc_rect = document.get_rect()
	
	# Calculate the "perfect" area (top 1/3 and center 1/3)
	var perfect_area = Rect2(
		doc_rect.size.x / 3,      # Start from 1/3 of width 
		0,                        # Start from top
		doc_rect.size.x / 3,      # Width is 1/3 of document width
		doc_rect.size.y / 3       # Height is 1/3 of document height
	)
	
	# Check if stamp position is within the perfect area
	return perfect_area.has_point(local_stamp_pos)

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
