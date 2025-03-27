extends Control


func _on_feedback_button_pressed() -> void:
		apply_button_juice(%FeedbackButton, "https://docs.google.com/forms/d/1COq7e4ODVKL4HbWyhuthXT73FaxXd5YcBlJwtp6kPZY/edit")

## Applies a juicy animation effect to a button and then opens a URL.
##
## This function handles the entire animation sequence including shrinking,
## darkening, bouncing back, and then opening the specified URL. The button
## will animate from its center for a polished effect.
##
## @param button The button control node to animate
## @param url The URL to open after animation completes
func apply_button_juice(button: Control, url: String) -> void:
	# Ensure the button scales from its center
	button.pivot_offset = button.size / 2
	
	# Create a tween for smooth animations
	var tween = create_tween().set_parallel()
	
	# Initial shrink animation (quick)
	tween.tween_property(button, "scale", Vector2(0.8, 0.8), 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", Color(0.7, 0.7, 0.7, 1.0), 0.1)
	
	# Chain a tween for the bounce-back animation
	tween.chain().tween_property(button, "scale", Vector2(1.1, 1.1), 0.2).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(button, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(button, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)
	
	# Wait for animation to finish before opening the URL
	await tween.finished
	
	# Open the link after animation completes
	OS.shell_open(url)
