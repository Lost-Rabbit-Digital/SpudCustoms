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
	# Animation configuration variables
	var initial_shrink_scale := Vector2(0.8, 0.8)
	var initial_shrink_time := 0.1
	var initial_darken_color := Color(0.7, 0.7, 0.7, 1.0)
	var initial_darken_time := 0.1
	
	var bounce_scale := Vector2(1.1, 1.1)
	var bounce_time := 0.2
	
	var final_scale := Vector2(1.0, 1.0)
	var final_scale_time := 0.1
	var final_color := Color(1.0, 1.0, 1.0, 1.0)
	var final_color_time := 0.2
	
	# Ensure the button scales from its center
	button.pivot_offset = button.size / 2
	
	# Create a tween for smooth animations
	var tween = create_tween().set_parallel()
	
	# Initial shrink animation (quick)
	tween.tween_property(button, "scale", initial_shrink_scale, initial_shrink_time).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", initial_darken_color, initial_darken_time)
	
	# Chain a tween for the bounce-back animation
	tween.chain().tween_property(button, "scale", bounce_scale, bounce_time).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(button, "scale", final_scale, final_scale_time).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(button, "modulate", final_color, final_color_time)
	
	# Wait for animation to finish before opening the URL
	await tween.finished
	
	# Open the link after animation completes
	OS.shell_open(url)
