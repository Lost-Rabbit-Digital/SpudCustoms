extends Sprite2D

@onready var clock_label = %ClockLabel

func _ready():
	# Set up a timer to update every second
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_Timer_timeout)
	timer.start(1.0)  # Update every second
	
	# Initial update
	_update_time()

func _on_Timer_timeout():
	_update_time()

func _update_time():
	var time = Time.get_time_dict_from_system()
	var hours = "%02d" % time.hour      # Pad with leading zero if needed
	var minutes = "%02d" % time.minute  # Pad with leading zero if needed
	var seconds = "%02d" % time.second  # Pad with leading zero if needed
	clock_label.text = hours + ":" + minutes + ":" + seconds
