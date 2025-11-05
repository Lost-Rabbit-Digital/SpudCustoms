extends SceneTree

# Test runner script for CI/CD
# Run with: godot --headless --script res://tests/run_tests.gd


func _init():
	# Load GUT
	var gut = load("res://addons/gut/gut.gd").new()
	add_child(gut)

	# Configure GUT
	gut.add_directory("res://tests/unit")
	gut.add_directory("res://tests/integration")
	gut.set_include_subdirectories(true)
	gut.set_log_level(1)  # 1 = warnings and errors
	gut.set_should_exit(true)
	gut.set_should_exit_on_success(true)

	# Run tests
	gut.test_scripts()
