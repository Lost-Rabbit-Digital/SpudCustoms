extends HBoxContainer

signal reset_confirmed

## Duration to show success message before reverting to original text
const SUCCESS_FEEDBACK_DURATION: float = 2.0

## Original button text for restoration after feedback
var _original_button_text: String = ""


func _on_ResetButton_pressed() -> void:
	$ConfirmResetDialog.popup_centered()
	$ResetButton.disabled = true


func _on_ConfirmResetDialog_confirmed() -> void:
	reset_confirmed.emit()
	_show_reset_success_feedback()


func _on_confirm_reset_dialog_canceled() -> void:
	$ResetButton.disabled = false


## Shows temporary success feedback on the button, then re-enables it
func _show_reset_success_feedback() -> void:
	_original_button_text = $ResetButton.text
	$ResetButton.text = tr("reset_game_success")

	# Create one-shot timer for feedback duration
	var timer: SceneTreeTimer = get_tree().create_timer(SUCCESS_FEEDBACK_DURATION)
	timer.timeout.connect(_restore_button_state)


## Restores button to original state after success feedback
func _restore_button_state() -> void:
	$ResetButton.text = _original_button_text
	$ResetButton.disabled = false
