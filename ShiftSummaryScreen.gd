extends Control

@onready var animation_player = $AnimationPlayer
@onready var background = $Background

var stats: Dictionary
const BACKGROUND_TEXTURE = preload("res://assets/shift_summary/shift_summary_mockup_empty.png")

func _ready():
	hide()
	setup_background()
	setup_styling()
	show_summary(generate_test_stats())
	Steam.findLeaderboard("endless_expert")
	Global.submit_score(1000)

func setup_background():
	if background and BACKGROUND_TEXTURE:
		background.texture = BACKGROUND_TEXTURE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func setup_styling():
	var font = preload("res://assets/fonts/Modern_DOS_Font_Variation.tres")
	var text_color = Color("#ffa500")  # Orange/gold color
	var outline_color = Color("#4d2600")  # Dark brown
	
	for label in get_tree().get_nodes_in_group("summary_text"):
		if font:
			label.add_theme_font_override("font", font)
		label.add_theme_color_override("font_color", text_color)
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_color_override("font_outline_color", outline_color)

func show_summary(stats_data: Dictionary):
	stats = stats_data
	show()
	populate_stats()
	play_entry_animation()

func populate_stats():
	var minutes = int(stats.get("time_taken", 0) / 60)
	var seconds = int(stats.get("time_taken", 0)) % 60
	
	# Update shift info
	$HeaderPanel/Title.text = "SHIFT SUMMARY\nEndless - %s" % Global.difficulty_level
	
	# Update shift complete section
	$LeftPanel/ShiftComplete.text = """--- SHIFT {shift} COMPLETE ---

Time Taken: {m}m {s}s
Total Score: {score}""".format({
		"shift": stats.get("shift", 1),
		"m": minutes,
		"s": seconds,
		"score": format_number(stats.get("score", 0))
	})
	
	# Update missile stats
	$LeftPanel/MissileStats.text = """--- MISSILE STATS ---
Missiles Fired: {fired}
Missiles Hit: {hit}
Perfect Hits: {perfect}
Hit Rate: {rate}%""".format({
		"fired": stats.get("missiles_fired", 0),
		"hit": stats.get("missiles_hit", 0),
		"perfect": stats.get("perfect_hits", 0),
		"rate": calculate_hit_rate()
	})
	
	# Update document stats
	$RightPanel/DocumentStats.text = """--- DOCUMENT STATS ---
Documents Stamped: {stamped}
Potatoes Approved: {approved}
Potatoes Rejected: {rejected}
Perfect Stamps: {perfect}""".format({
		"stamped": stats.get("total_stamps", 0),
		"approved": stats.get("potatoes_approved", 0),
		"rejected": stats.get("potatoes_rejected", 0),
		"perfect": stats.get("perfect_stamps", 0)
	})
	
	# Update bonus stats
	$RightPanel/BonusStats.text = """--- BONUSES ---
Speed Bonus: {speed}
Accuracy Bonus: {accuracy}
Perfect Hit Bonus: {perfect}

FINAL SCORE: {final}""".format({
		"speed": format_number(stats.get("speed_bonus", 0)),
		"accuracy": format_number(stats.get("accuracy_bonus", 0)),
		"perfect": format_number(stats.get("perfect_bonus", 0)),
		"final": format_number(stats.get("final_score", 0))
	})
	
	# Update leaderboard
	update_leaderboard()

func calculate_hit_rate() -> String:
	if stats.get("missiles_fired", 0) > 0:
		return "%d" % ((float(stats.get("missiles_hit", 0)) / stats.get("missiles_fired", 0)) * 100)
	return "0"

func format_number(number: int) -> String:
	return "{:,}".format(number)

func update_leaderboard():
	print("Updating leaderboard...")
	
	$LeaderboardTitlePanel/Title.text = "Global Leaderboard\nEndless - %s" % Global.difficulty_level
	# Format leaderboard entries
	var entries = Global.get_leaderboard_entries(Global.difficulty_level)
	print(entries)
	var leaderboard_text = ""
	
	for i in range(min(entries.size(), 12)):
		leaderboard_text += "%2d  %-15s  %s\n" % [
			i + 1,
			entries[i].name,
			format_number(entries[i].score)
		]
	
	$LeaderboardPanel/Entries.text = leaderboard_text

func play_entry_animation():
	if animation_player:
		animation_player.play("show_summary")

func generate_test_stats() -> Dictionary:
	return {
		"shift": 5,                    # Current shift number
		"time_taken": 970.0,           # Time taken in seconds
		"processing_time_left": 15.0,  # Time remaining
		"score": 7280,                 # Base score
		"missiles_fired": 333,
		"missiles_hit": 111,
		"perfect_hits": 15,
		"total_stamps": 144,
		"potatoes_approved": 80,
		"potatoes_rejected": 64,
		"perfect_stamps": 12,
		"speed_bonus": 1200,
		"accuracy_bonus": 5000,
		"perfect_bonus": 2000,
		"final_score": 15480
	}
