class_name GlobalState
extends Node

const SAVE_STATE_PATH = "user://global_state_1.tres"
const NO_VERSION_NAME = "0.0.0"

static var current: GlobalStateData
static var current_version: String


static func _log_opened():
	if current is GlobalStateData:
		current.last_unix_time_opened = int(Time.get_unix_time_from_system())


static func _log_version():
	if current is GlobalStateData:
		current_version = ProjectSettings.get_setting("application/config/version", NO_VERSION_NAME)
		if current_version.is_empty():
			current_version = NO_VERSION_NAME
		if not current.first_version_opened:
			current.first_version_opened = current_version
		current.last_version_opened = current_version


static func _load_or_new(new_state: Resource = null):
	if current is GlobalStateData:
		return
	if FileAccess.file_exists(SAVE_STATE_PATH):
		# Check if the save file can be loaded - it may reference moved/deleted scripts
		if ResourceLoader.exists(SAVE_STATE_PATH):
			current = ResourceLoader.load(SAVE_STATE_PATH)
		if not current:
			push_error("Failed to load save state from file - save may reference missing scripts")
			# Backup the corrupted file for debugging
			_backup_corrupted_save()
		else:
			return
	if new_state:
		current = new_state
	else:
		current = GlobalStateData.new()


static func _backup_corrupted_save():
	# Backup corrupted save file before creating a fresh one
	if FileAccess.file_exists(SAVE_STATE_PATH):
		var backup_path = SAVE_STATE_PATH.replace(".tres", "_backup_%d.tres" % int(Time.get_unix_time_from_system()))
		var dir = DirAccess.open("user://")
		if dir:
			var err = dir.copy(SAVE_STATE_PATH, backup_path)
			if err == OK:
				push_warning("Corrupted save backed up to: %s" % backup_path)
			# Remove corrupted file so fresh save can be created
			dir.remove(SAVE_STATE_PATH)


static func open():
	_load_or_new()
	_log_opened()
	_log_version()
	save()


static func save():
	if current is GlobalStateData:
		var what_is_state = current
		ResourceSaver.save(current, SAVE_STATE_PATH)


static func has_state(state_key: String) -> bool:
	if current is not GlobalStateData:
		return false
	return current.has_state(state_key)


static func get_state(state_key: String, state_type_path: String):
	if current is not GlobalStateData:
		return
	return current.get_state(state_key, state_type_path)


static func reset():
	if current is not GlobalStateData:
		return
	current.states.clear()
	save()
