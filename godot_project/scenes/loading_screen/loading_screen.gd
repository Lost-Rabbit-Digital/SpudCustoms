extends LoadingScreen


func _ready() -> void:
	# Override hardcoded strings with translated versions
	_in_progress = tr("loading_level_in_progress")
	_in_progress_waiting = tr("loading_level_waiting")
	_in_progress_still_waiting = tr("loading_level_still_waiting")
	_complete = tr("loading_level_complete")
