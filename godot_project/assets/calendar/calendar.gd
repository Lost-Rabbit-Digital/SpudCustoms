extends Sprite2D

@onready var calendar_label = %CalendarLabel


func _ready():
	# Set up a timer to update daily
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_Timer_timeout)
	timer.start(86400.0)  # Update every 24 hours (86400 seconds)

	# Initial update
	_update_date()


func _on_Timer_timeout():
	_update_date()


func _update_date():
	var time = Time.get_datetime_dict_from_system()
	var year = "%04d" % time.year  # Four digit year
	var month = "%02d" % time.month  # Pad with leading zero if needed
	var day = "%02d" % time.day  # Pad with leading zero if needed
	calendar_label.text = year + "-" + month + "-" + day
