@tool
extends Label
class_name LocalizedVersionLabel
## Displays the version using the translation key "main_menu_version".
## This replaces the addon's ConfigVersionLabel to properly support localization.


func _ready() -> void:
	update_version_label()
	# Re-update when locale changes
	if not Engine.is_editor_hint():
		TranslationServer.get_locale()  # Trigger initial translation
		# Connect to locale changes if needed
		get_tree().process_frame.connect(_on_process_frame, CONNECT_ONE_SHOT)


func _on_process_frame() -> void:
	update_version_label()


func update_version_label() -> void:
	text = tr("main_menu_version")
