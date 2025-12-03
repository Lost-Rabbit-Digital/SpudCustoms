extends Control
## Twitch configuration menu for setting up viewer name integration
##
## Allows streamers to enable Twitch integration and manage viewer names
## that will appear on potato passports during gameplay.

signal closed

@onready var enable_checkbox: CheckBox = %EnableCheckbox
@onready var channel_input: LineEdit = %ChannelInput
@onready var viewer_input: LineEdit = %ViewerInput
@onready var add_viewer_button: Button = %AddViewerButton
@onready var viewer_list: ItemList = %ViewerList
@onready var remove_button: Button = %RemoveButton
@onready var clear_all_button: Button = %ClearAllButton
@onready var close_button: Button = %CloseButton
@onready var viewer_count_label: Label = %ViewerCountLabel
@onready var status_label: Label = %StatusLabel


func _ready():
	# Connect signals
	enable_checkbox.toggled.connect(_on_enable_toggled)
	channel_input.text_changed.connect(_on_channel_changed)
	viewer_input.text_submitted.connect(_on_viewer_submitted)
	add_viewer_button.pressed.connect(_on_add_viewer_pressed)
	remove_button.pressed.connect(_on_remove_pressed)
	clear_all_button.pressed.connect(_on_clear_all_pressed)
	close_button.pressed.connect(_on_close_pressed)
	viewer_list.item_selected.connect(_on_viewer_selected)

	# Connect to TwitchIntegrationManager signals
	if TwitchIntegrationManager:
		TwitchIntegrationManager.viewer_added.connect(_on_viewer_added)
		TwitchIntegrationManager.viewer_removed.connect(_on_viewer_removed)

	# Connect to localization
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_on_language_changed)

	refresh_ui()
	_update_labels()


func refresh_ui():
	"""Refresh all UI elements with current state"""
	if not TwitchIntegrationManager:
		return

	# Update checkbox
	enable_checkbox.button_pressed = TwitchIntegrationManager.is_enabled()

	# Update channel input
	channel_input.text = TwitchIntegrationManager.get_channel_name()

	# Update viewer list
	_refresh_viewer_list()

	# Update controls state
	_update_controls_state()

	# Update count label
	_update_viewer_count()


func _refresh_viewer_list():
	"""Refresh the viewer list display"""
	viewer_list.clear()
	if not TwitchIntegrationManager:
		return

	var viewers = TwitchIntegrationManager.get_all_viewers()
	for viewer in viewers:
		viewer_list.add_item(viewer)


func _update_controls_state():
	"""Update enabled/disabled state of controls"""
	var enabled = TwitchIntegrationManager.is_enabled() if TwitchIntegrationManager else false

	channel_input.editable = enabled
	viewer_input.editable = enabled
	add_viewer_button.disabled = not enabled
	remove_button.disabled = not enabled or viewer_list.get_selected_items().is_empty()
	clear_all_button.disabled = not enabled or viewer_list.item_count == 0


func _update_viewer_count():
	"""Update the viewer count label"""
	if not TwitchIntegrationManager:
		viewer_count_label.text = "0"
		return

	var count = TwitchIntegrationManager.get_viewer_count()
	viewer_count_label.text = str(count)

	# Update status
	if TwitchIntegrationManager.is_enabled():
		if count == 0:
			status_label.text = tr("twitch_status_no_viewers")
		else:
			status_label.text = tr("twitch_status_ready").format({"count": count})
	else:
		status_label.text = tr("twitch_status_disabled")


func _update_labels():
	"""Update all text labels for localization"""
	# Labels will use tr() in the scene, but we update dynamic ones here
	_update_viewer_count()


func _on_language_changed(_locale: String):
	"""Handle language change"""
	_update_labels()


func _on_enable_toggled(enabled: bool):
	"""Handle enable checkbox toggle"""
	if TwitchIntegrationManager:
		TwitchIntegrationManager.set_enabled(enabled)
	_update_controls_state()
	_update_viewer_count()


func _on_channel_changed(new_text: String):
	"""Handle channel name change"""
	if TwitchIntegrationManager:
		TwitchIntegrationManager.set_channel_name(new_text)


func _on_viewer_submitted(viewer_name: String):
	"""Handle viewer name submitted via Enter key"""
	_add_viewer(viewer_name)


func _on_add_viewer_pressed():
	"""Handle add viewer button pressed"""
	_add_viewer(viewer_input.text)


func _add_viewer(viewer_name: String):
	"""Add a viewer to the list"""
	if not TwitchIntegrationManager:
		return

	if TwitchIntegrationManager.add_viewer(viewer_name):
		viewer_input.text = ""
		viewer_input.grab_focus()


func _on_viewer_added(viewer_name: String):
	"""Handle viewer added signal"""
	_refresh_viewer_list()
	_update_viewer_count()
	_update_controls_state()


func _on_viewer_removed(viewer_name: String):
	"""Handle viewer removed signal"""
	_refresh_viewer_list()
	_update_viewer_count()
	_update_controls_state()


func _on_viewer_selected(index: int):
	"""Handle viewer selection in list"""
	_update_controls_state()


func _on_remove_pressed():
	"""Handle remove button pressed"""
	var selected = viewer_list.get_selected_items()
	if selected.is_empty():
		return

	var viewer_name = viewer_list.get_item_text(selected[0])
	if TwitchIntegrationManager:
		TwitchIntegrationManager.remove_viewer(viewer_name)


func _on_clear_all_pressed():
	"""Handle clear all button pressed"""
	if TwitchIntegrationManager:
		TwitchIntegrationManager.clear_all_viewers()
	_refresh_viewer_list()
	_update_viewer_count()
	_update_controls_state()


func _on_close_pressed():
	"""Handle close button pressed"""
	closed.emit()
	queue_free()


func _input(event):
	"""Handle input for closing with Escape"""
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
