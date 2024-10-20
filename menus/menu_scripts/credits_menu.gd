extends Control

@onready var vbox_container = $MarginContainer/VBoxContainer

func _ready():
	var json_text = FileAccess.get_file_as_string("res://ATTRIBUTIONS.md")
	var json = JSON.parse_string(json_text)
	
	if json:
		# Clear any existing children first (except for UI elements you want to keep)
		for child in vbox_container.get_children():
			if child.name != "BackButton":  # Keep the back button if it exists
				child.queue_free()
		
		# Loop through each category
		for category in json:
			# Create category header
			var header = Label.new()
			header.name = "Header"
			header.text = category.capitalize()
			header.add_theme_font_size_override("font_size", 24)
			vbox_container.add_child(header)
			
			# Add each attribution in the category
			for item in json[category]:
				var name_label = Label.new()
				name_label.name = "Name"
				name_label.text = "• " + item
				name_label.add_theme_font_size_override("font_size", 16)
				vbox_container.add_child(name_label)
			
			# Add spacing after each category
			var spacer = Control.new()
			spacer.custom_minimum_size.y = 20
			vbox_container.add_child(spacer)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
