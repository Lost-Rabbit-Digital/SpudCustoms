extends Control

@onready var animation_player = $AnimationPlayer
@onready var background = $Background
signal closed

var stats: Dictionary
const BACKGROUND_TEXTURE = preload("res://assets/menu/shift_summary_end_screen.png")

func _init():
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow input to pass through to buttons

func _ready():
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_STOP  # Block input from passing through
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	# Use stored stats if available, otherwise use test data
	if !Global.current_game_stats.is_empty():
		show_summary(Global.current_game_stats)
	else:
		show_summary(generate_test_stats())
		
	# Ensure buttons are interactive
	for button in [$SubmitScoreButton, $RefreshButton, $RestartButton, $MainMenuButton]:
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
	# Make sure child elements don't block input for buttons
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ScreenBackground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Connect button signals
	$RestartButton.connect("pressed", Callable(self, "_on_restart_button_pressed"))
	$MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_button_pressed"))
	
	setup_background()
	setup_styling()
	
	# Call animation
	play_entry_animation()

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

func populate_stats():
	
	# Update shift info
	$HeaderPanel/Title.text = "SHIFT SUMMARY\n %s" % Global.difficulty_level
	
	# Update missile stats with calculated hit rate
	$LeftPanel/MissileStats.text = """--- MISSILE STATS ---
Missiles Fired: {fired}
Missiles Hit: {hit}
Perfect Hits: {perfect}
Hit Rate: {rate}%""".format({
		"fired": format_number(stats.get("missiles_fired", 0)),
		"hit": format_number(stats.get("missiles_hit", 0)),
		"perfect": format_number(stats.get("perfect_hits", 0)),
		"rate": stats.get("hit_rate", 0.0)
	})
	
	# Update document stats
	$RightPanel/DocumentStats.text = """--- DOCUMENT STATS ---
Documents Stamped: {stamped}
Potatoes Approved: {approved}
Potatoes Rejected: {rejected}""".format({
		"stamped": format_number(stats.get("total_stamps", 0)),
		"approved": format_number(stats.get("potatoes_approved", 0)),
		"rejected": format_number(stats.get("potatoes_rejected", 0)),
	})
	
	# Update bonus stats without speed bonus
	$RightPanel/BonusStats.text = """--- BONUSES ---
Accuracy Bonus: {accuracy}

FINAL SCORE: {final}""".format({
		"accuracy": format_number(stats.get("accuracy_bonus", 0)),
		"final": format_number(stats.get("final_score", 0))
	})
	
	# Update leaderboard
	update_leaderboard()
	
		# Add performance comparison
	var difficulty_rating = "Normal"
	var expected_score = 10000  # Base expected score
	
	# Adjust expectations based on difficulty
	match Global.difficulty_level:
		"Easy":
			expected_score = 8000
			difficulty_rating = "Easy"
		"Normal":
			expected_score = 10000
			difficulty_rating = "Normal"
		"Expert":
			expected_score = 14000
			difficulty_rating = "Expert"
	
	# Calculate performance percentage
	var performance = float(stats.get("final_score", 0)) / float(expected_score) * 100
	var performance_text = "Average"
	var performance_color = Color(1.0, 0.8, 0)  # Default yellow
	
	if performance >= 150:
		performance_text = "Exceptional!"
		performance_color = Color(1.0, 0.4, 0.8)  # Pink
	elif performance >= 120:
		performance_text = "Excellent!"
		performance_color = Color(0.2, 0.8, 0.2)  # Green
	elif performance >= 90:
		performance_text = "Good"
		performance_color = Color(0.4, 0.7, 0.1)  # Light green
	elif performance < 70:
		performance_text = "Needs Improvement"
		performance_color = Color(0.8, 0.4, 0.1)  # Orange
	elif performance < 50:
		performance_text = "Poor"
		performance_color = Color(0.8, 0.2, 0.2)  # Red
	
	# Add performance rating to display
	$RightPanel/PerformanceStats.text = """
	--- PERFORMANCE ---
	Difficulty: {difficulty}
	Performance Rating: {rating}
	Score vs Expected: {percent}%
	""".format({
		"difficulty": difficulty_rating,
		"rating": performance_text,
		"percent": int(performance)
	})
	
	$RightPanel/PerformanceStats.add_theme_color_override("font_color", performance_color)

# Add to ShiftSummaryScreen.gd
func play_entry_animation():
	# Set initial states
	$LeftPanel.modulate.a = 0
	$RightPanel.modulate.a = 0
	$HeaderPanel.modulate.a = 0
	$LeaderboardPanel.modulate.a = 0
	$LeaderboardTitlePanel.modulate.a = 0
	
	# Create animation sequence
	var tween = create_tween()
	tween.set_parallel(false)  # Sequential animations
	
	# Header fades in first
	tween.tween_property($HeaderPanel, "modulate:a", 1.0, 0.5)
	
	# Then the panels fade in
	tween.tween_property($LeftPanel, "modulate:a", 1.0, 0.4)
	tween.tween_property($RightPanel, "modulate:a", 1.0, 0.4)
	
	# Finally the leaderboard
	tween.tween_property($LeaderboardTitlePanel, "modulate:a", 1.0, 0.3)
	tween.tween_property($LeaderboardPanel, "modulate:a", 1.0, 0.3)
	
	# Start animation
	tween.play()

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

func generate_test_stats() -> Dictionary:
	return {
		"shift": 1337,                    # Current shift number
		"time_taken": 1337.0,           # Time taken in seconds
		"score": 1337,                 # Base score
		"missiles_fired": 1337,
		"missiles_hit": 1337,
		"perfect_hits": 1337,
		"total_stamps": 1337,
		"potatoes_approved": 1337,
		"potatoes_rejected": 1337,
		"accuracy_bonus": 1337,
		"final_score": 1337
	}


func _on_submit_score_button_pressed() -> void:
	print("Submitting score of: ")
	print(stats.get("final_score"))
	Global.submit_score(stats.get("final_score"))


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scenes/scenes/game_scene/levels/mainGame.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_scenes/scenes/menus/main_menu/main_menu_with_animations.tscn")
