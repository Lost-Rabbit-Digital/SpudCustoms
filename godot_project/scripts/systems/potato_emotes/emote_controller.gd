extends Node
## Helper script for the PotatoEmoteSystem controller node.
##
## This script contains callback methods that respond to timer signals from
## the emote system. It avoids using static functions for signal connections,
## which can cause issues with freed instances.

func _ready() -> void:
	# Connect timer signals
	if has_node("Timer"):
		$Timer.timeout.connect(_on_emote_timer_timeout)
	
	if has_node("Timer2"):
		$Timer2.timeout.connect(_on_dot_sequence_timer_timeout)

## Callback for when the emote timer expires
func _on_emote_timer_timeout() -> void:
	PotatoEmoteSystem.hide_emote()

## Callback for dot sequence animation
func _on_dot_sequence_timer_timeout() -> void:
	# Get current emote from the system
	var current_emote = PotatoEmoteSystem.current_emote
	
	if current_emote == PotatoEmoteSystem.EmoteType.DOT_1:
		PotatoEmoteSystem.show_emote(PotatoEmoteSystem.EmoteType.DOT_2)
	elif current_emote == PotatoEmoteSystem.EmoteType.DOT_2:
		PotatoEmoteSystem.show_emote(PotatoEmoteSystem.EmoteType.DOT_3)
	elif current_emote == PotatoEmoteSystem.EmoteType.DOT_3:
		PotatoEmoteSystem.show_emote(PotatoEmoteSystem.EmoteType.DOT_1)
	else:
		# If we're not in the dot sequence, stop the timer
		if has_node("Timer2"):
			$Timer2.stop()
