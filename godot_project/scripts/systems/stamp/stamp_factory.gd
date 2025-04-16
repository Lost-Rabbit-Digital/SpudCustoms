class_name StampFactory
extends Node


# Create a fully configured stamp system
static func create_stamp_system(game_scene: Node) -> StampSystem:
	# Get necessary references from the game scene
	var audio_player = game_scene.get_node_or_null("SystemManagers/AudioManager/SFXPool")

	# Create a shake callback function
	var shake_callback: Callable

	# Find the main game node and check if it has shake_screen method
	var main_game = game_scene
	if main_game.has_method("shake_screen"):
		shake_callback = main_game.shake_screen
	else:
		# Create empty callable
		shake_callback = Callable()

	# Create the stamp system
	var stamp_system = StampSystem.new(audio_player, shake_callback)
	stamp_system.name = "StampSystem"

	# Add it to the appropriate parent in the scene
	var system_managers = game_scene.get_node_or_null("SystemManagers")
	if system_managers:
		system_managers.add_child(stamp_system)
	else:
		game_scene.add_child(stamp_system)

	return stamp_system


static func create_passport_stampable(
	game_scene: Node, stamp_system: StampSystem
) -> StampableComponent:
	# Get necessary references
	var passport_node = game_scene.get_node_or_null("Gameplay/InteractiveElements/Passport")
	var open_passport_node = passport_node.get_node_or_null("OpenPassport")

	if !passport_node or !open_passport_node:
		push_error("Could not find passport or its open content node")
		return null

	# Get the actual visual size from the document texture/sprite
	var document_sprite = null

	# Look for the sprite containing the document texture in the open passport
	for child in open_passport_node.get_children():
		if child is Sprite2D:
			document_sprite = child
			break

	if !document_sprite:
		# If we didn't find a sprite, use the open_passport_node itself
		push_warning("Could not find a Sprite2D in OpenPassport, using node dimensions")

		# Calculate the stamp area based on the passport's global position and size
		# From your screenshot, I can see the visa area is roughly centered and takes up
		# about 60% of the width and 70% of the height
		var passport_rect = Rect2(
			passport_node.global_position,
			Vector2(passport_node.texture.get_width(), passport_node.texture.get_height())
		)

		# Target the red highlighted visa area from your screenshot
		var visa_area = Rect2(
			(
				passport_rect.position
				+ Vector2(passport_rect.size.x * 0.25, passport_rect.size.y * 0.25)
			),
			Vector2(passport_rect.size.x * 0.5, passport_rect.size.y * 0.5)
		)

		print("Created stamp area: ", visa_area)

		# Register with the stamp system
		var stampable = stamp_system.register_stampable(
			passport_node, open_passport_node, visa_area
		)

		return stampable

	if document_sprite:
		# If we found a sprite, use its dimensions
		var sprite_global_rect = Rect2(
			(
				document_sprite.global_position
				- (document_sprite.texture.get_size() * document_sprite.scale / 2)
			),
			document_sprite.texture.get_size() * document_sprite.scale
		)

		# Based on your screenshot, the visa area seems to be in the center-right
		# part of the document, taking about 60% of the height and 40% of the width
		var visa_area = Rect2(
			(
				sprite_global_rect.position
				+ Vector2(sprite_global_rect.size.x * 0.3, sprite_global_rect.size.y * 0.2)
			),
			Vector2(sprite_global_rect.size.x * 0.4, sprite_global_rect.size.y * 0.6)
		)

		print("Created stamp area from sprite: ", visa_area)

		# Register with the stamp system
		var stampable = stamp_system.register_stampable(
			passport_node, open_passport_node, visa_area
		)

		return stampable

	return


# Connect the stamp system to the stamp bar controller
static func connect_stamp_bar_to_system(stamp_bar: Node, stamp_system: StampSystem):
	if stamp_bar:
		# Check if stamp_bar has the stamp_selected signal
		if stamp_bar.has_signal("stamp_selected"):
			# Connect with bind to pass the stamp_bar itself as the third argument
			stamp_bar.stamp_selected.connect(
				func(type, texture): stamp_system.on_stamp_requested(type, texture, stamp_bar)
			)
			print("Connected StampBarController to StampSystem")
		else:
			push_error("StampBarController doesn't have the stamp_selected signal")
	else:
		push_error("Invalid StampBarController passed to connect_stamp_bar_to_system")
