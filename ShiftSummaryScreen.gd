# ShiftSummaryScreen.gd
extends Control

@onready var animation_player = $AnimationPlayer
@onready var stats_container = $StatsContainer
@onready var continue_button = $ContinueButton

var stats: Dictionary

func _ready():
	hide()
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)

func show_summary(stats_data: Dictionary):
	stats = stats_data
	show()
	populate_stats()
	play_entry_animation()

func populate_stats():
	var stats_text = """
	SHIFT {shift} COMPLETE

	Time Taken: {time_m}m {time_s}s
	Total Score: {score}
	
	--- MISSILE STATS ---
	Missiles Fired: {missiles_fired}
	Missiles Hit: {missiles_hit}
	Perfect Hits: {perfect_hits}
	Hit Rate: {hit_rate}%
	
	--- DOCUMENT STATS ---
	Documents Stamped: {total_stamps}
	Potatoes Approved: {potatoes_approved}
	Potatoes Rejected: {potatoes_rejected}
	Perfect Stamps: {perfect_stamps}
	
	--- BONUSES ---
	Speed Bonus: {speed_bonus}
	Accuracy Bonus: {accuracy_bonus}
	Perfect Hit Bonus: {perfect_bonus}
	
	FINAL SCORE: {final_score}
	"""
	
	# Calculate derived stats
	var hit_rate = 0.0
	if stats.get("missiles_fired", 0) > 0:
		hit_rate = (float(stats.get("missiles_hit", 0)) / stats.get("missiles_fired", 0)) * 100
	
	var time_taken = stats.get("time_taken", 0)
	var minutes = int(time_taken / 60)
	var seconds = int(time_taken) % 60
	
	# Format the stats text with proper dictionary keys matching end_shift()
	stats_text = stats_text.format({
		"shift": stats.get("shift", 1),
		"time_m": minutes,
		"time_s": seconds,
		"score": stats.get("score", 0),
		"missiles_fired": stats.get("missiles_fired", 0),
		"missiles_hit": stats.get("missiles_hit", 0),
		"perfect_hits": stats.get("perfect_hits", 0),
		"hit_rate": "%.1f" % hit_rate,
		"total_stamps": stats.get("total_stamps", 0),
		"approved": stats.get("potatoes_approved", 0),
		"rejected": stats.get("potatoes_rejected", 0),
		"perfect_stamps": stats.get("perfect_stamps", 0),
		"speed_bonus": stats.get("speed_bonus", 0),
		"accuracy_bonus": stats.get("accuracy_bonus", 0),
		"perfect_bonus": stats.get("perfect_bonus", 0),
		"final_score": stats.get("final_score", 0)
	})
	
	$StatsContainer/StatsLabel.text = stats_text

func play_entry_animation():
	if animation_player:
		animation_player.play("show_summary")

func _on_continue_pressed():
	hide()
	continue_button.pressed.emit()
