extends Control

@onready var animation_player = $AnimationPlayer
@onready var background = $Background

var stats: Dictionary
const BACKGROUND_TEXTURE = preload("res://assets/shift_summary/shift_summary_mockup_empty.png")

func _init():
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow input to pass through to buttons

func _ready():
	hide()
	setup_background()
	setup_styling()
	# Use stored stats if available, otherwise use test data
	if !Global.current_game_stats.is_empty():
		show_summary(Global.current_game_stats)
	else:
		show_summary(generate_test_stats())
	# Fix button layering and input
	for button in [$SubmitScoreButton, $RefreshButton, $RestartButton, $MainMenuButton]:
		button.z_index = 15  # Ensure buttons are above all content
		button.mouse_filter = Control.MOUSE_FILTER_STOP  # Force input handling
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	# Ensure ScreenBackground and other full-screen elements don't block input
	$ScreenBackground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SubmitScoreButton.z_index = 15
	$RefreshButton.z_index = 15
	$RestartButton.z_index = 15
	$MainMenuButton.z_index = 15
	# Make sure no overlays are blocking
	$Background.z_index = 6
	$ScreenBackground.z_index = 1
	$PotatoRain.z_index = 3

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
	var total_time = stats.get("processing_time") - stats.get("processing_time_left", 0)
	var minutes = int(total_time / 60)
	var seconds = int(total_time) % 60
	
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
		"fired": format_number(stats.get("missiles_fired", 0)),
		"hit": format_number(stats.get("missiles_hit", 0)),
		"perfect": format_number(stats.get("perfect_hits", 0)),
		"rate": calculate_hit_rate()
	})
	
	# Update document stats
	$RightPanel/DocumentStats.text = """--- DOCUMENT STATS ---
Documents Stamped: {stamped}
Potatoes Approved: {approved}
Potatoes Rejected: {rejected}
Perfect Stamps: {perfect}""".format({
		"stamped": format_number(stats.get("total_stamps", 0)),
		"approved": format_number(stats.get("potatoes_approved", 0)),
		"rejected": format_number(stats.get("potatoes_rejected", 0)),
		"perfect": format_number(stats.get("perfect_stamps", 0))
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

# Helper function to format numbers with commas
func format_number(number: int) -> String:
	var str_num = str(number)
	var formatted = ""
	var count = 0
	
	# Add commas every 3 digits from the right
	for i in range(str_num.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = str_num[i] + formatted
		count += 1
		
	return formatted

func calculate_hit_rate() -> String:
	if stats.get("missiles_fired", 0) > 0:
		return "%d" % ((float(stats.get("missiles_hit", 0)) / stats.get("missiles_fired", 0)) * 100)
	return "0"

func update_leaderboard():
	print("Updating leaderboard...")
	$LeaderboardTitlePanel/Title.text = "Global Leaderboard\nEndless - %s" % Global.difficulty_level
	# Format leaderboard entries
	var request_success = Global.request_leaderboard_entries(Global.difficulty_level)
	var leaderboard_text = ""
	if request_success: 
		leaderboard_text = "Getting leaderboard scores..."
		$LeaderboardPanel/Entries.text = leaderboard_text
		
	await get_tree().create_timer(1.0).timeout
	leaderboard_text = ""
	$LeaderboardPanel/Entries.text = ""
	await get_tree().create_timer(1.0).timeout
	
	var entries = []
	entries = Global.cached_leaderboard_entries
	for i in range(min(entries.size(), 12)):
		leaderboard_text += "%2d  %-15s  %s\n" % [
			i + 1,
			entries[i].name,
			format_number(entries[i].score)
		]
	
	$LeaderboardPanel/Entries.text = leaderboard_text
	print("Leaderboard updated.")

func play_entry_animation():
	if animation_player:
		animation_player.play("show_summary")

func generate_test_stats() -> Dictionary:
	return {
		"shift": 5,                    # Current shift number
		"time_taken": 1970.0,           # Time taken in seconds
		"processing_time_left": 15.0,  # Time remaining
		"score": 1337,                 # Base score
		"missiles_fired": 666,
		"missiles_hit": 666,
		"perfect_hits": 666,
		"total_stamps": 666,
		"potatoes_approved": 666,
		"potatoes_rejected": 666,
		"perfect_stamps": 666,
		"speed_bonus": 666,
		"accuracy_bonus": 666,
		"perfect_bonus": 666,
		"final_score": 0
	}


func _on_submit_score_button_pressed() -> void:
	print("Submitting score of: ")
	print(stats.get("final_score"))
	Global.submit_score(stats.get("final_score"))


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scenes/scenes/game_scene/levels/mainGame.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scenes/scenes/menus/main_menu/main_menu_with_animations.tscn")
