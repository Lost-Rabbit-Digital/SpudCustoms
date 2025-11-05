extends Node

# Configuration
const MAX_LOG_SIZE = 10 * 1024 * 1024  # 10 MB
const MAX_LOG_FILES = 5
const LOG_PATH = "user://logs/"
const DEBUG_STEAM = true  # Set to true to enable Steam debugging

var _current_log_file: FileAccess
var _log_file_path: String
var _initialized: bool = false


func _ready():
	# Initialize the log system
	initialize()


func initialize():
	if _initialized:
		return

	# Create logs directory if it doesn't exist
	if not DirAccess.dir_exists_absolute(LOG_PATH):
		DirAccess.make_dir_recursive_absolute(LOG_PATH)

	# Generate log filename with timestamp
	var datetime = Time.get_datetime_dict_from_system()
	var timestamp = (
		"%04d-%02d-%02d_%02d-%02d-%02d"
		% [
			datetime.year,
			datetime.month,
			datetime.day,
			datetime.hour,
			datetime.minute,
			datetime.second
		]
	)
	_log_file_path = LOG_PATH + "game_log_" + timestamp + ".txt"

	# Create and open the log file
	_current_log_file = FileAccess.open(_log_file_path, FileAccess.WRITE)
	if _current_log_file:
		_initialized = true
		write_info("Log system initialized. Game version: " + Engine.get_version_info().string)
		write_info("System info: " + OS.get_name() + ", " + OS.get_processor_name())

		# Log Steam status on startup
		if DEBUG_STEAM:
			write_info("Steam running: " + str(Steam.isSteamRunning()))
			write_info("Steam initialized: " + str(Steam.steamInit()))
			write_info("Steam user ID: " + str(Steam.getSteamID()))

		# Set up error handling
		print_rich("[color=yellow]Log Manager: Log file created at ", _log_file_path, "[/color]")
		print_rich("[color=green]To view logs, check: ", OS.get_user_data_dir() + "/logs/[/color]")
	else:
		print_rich("[color=red]Failed to create log file![/color]")

	# Rotate old log files
	_rotate_logs()


func _rotate_logs():
	# Get all log files
	var dir = DirAccess.open(LOG_PATH)
	if dir:
		dir.list_dir_begin()
		var file_list = []

		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".txt"):
				# Get file info
				var file_path = LOG_PATH + file_name
				var file_time = FileAccess.get_modified_time(file_path)
				file_list.append({"name": file_name, "path": file_path, "time": file_time})

			file_name = dir.get_next()

		# Sort by modification time (oldest first)
		file_list.sort_custom(func(a, b): return a.time < b.time)

		# Remove oldest files if we have too many
		while file_list.size() > MAX_LOG_FILES:
			var oldest = file_list.pop_front()
			if FileAccess.file_exists(oldest.path):
				var error = DirAccess.remove_absolute(oldest.path)
				write_info("Removed old log file: " + oldest.name + " - Result: " + str(error))


func write_entry(level: String, message: String):
	if not _initialized:
		initialize()

	if not _current_log_file:
		return

	var datetime = Time.get_datetime_dict_from_system()
	var timestamp = "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second]

	var formatted_message = "[%s] [%s] %s\n" % [timestamp, level, message]
	_current_log_file.store_string(formatted_message)
	_current_log_file.flush()  # Make sure it's written immediately

	# Check if we need to rotate log
	if _current_log_file.get_length() > MAX_LOG_SIZE:
		_current_log_file.close()
		initialize()  # Create a new log file


func write_debug(message: String):
	write_entry("DEBUG", message)
	print_rich("[color=gray][DEBUG] " + message + "[/color]")


func write_info(message: String):
	write_entry("INFO", message)
	print_rich("[color=white][INFO] " + message + "[/color]")


func write_warning(message: String):
	write_entry("WARNING", message)
	print_rich("[color=yellow][WARNING] " + message + "[/color]")


func write_error(message: String):
	write_entry("ERROR", message)
	print_rich("[color=red][ERROR] " + message + "[/color]")


func write_steam(message: String):
	if DEBUG_STEAM:
		write_entry("STEAM", message)
		print_rich("[color=green][STEAM] " + message + "[/color]")


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Game is being closed
		if _current_log_file:
			write_info("Application closing")
			_current_log_file.close()
