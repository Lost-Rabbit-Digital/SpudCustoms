@tool
extends EditorPlugin

var button: Button
var confirmation_dialog: ConfirmationDialog
var tree: Tree
var search_text: LineEdit
var filter_option: OptionButton
var warning_label: Label

func _enter_tree():
	# Create the button
	button = Button.new()
	button.text = "Clear User Data"
	button.icon = get_editor_interface().get_base_control().get_theme_icon("Remove", "EditorIcons")
	button.tooltip_text = "Selectively delete user:// directory contents"
	button.pressed.connect(_on_button_pressed)

	# Add button to the main editor toolbar
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)

func _exit_tree():
	# Clean up the button when plugin is disabled
	if button:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
		button.queue_free()
	
	if confirmation_dialog:
		confirmation_dialog.queue_free()

func _on_button_pressed():
	show_confirmation_dialog()

func show_confirmation_dialog():
	# Create confirmation dialog
	confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.title = "Delete User Directory Contents"
	confirmation_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_SCREEN_WITH_MOUSE_FOCUS
	confirmation_dialog.size = Vector2i(700, 550)
	confirmation_dialog.min_size = Vector2i(500, 400)  # Allow resizing, set minimum size
	confirmation_dialog.wrap_controls = true
	confirmation_dialog.get_ok_button().text = "Delete Selected"
	
	# Create a container for the content
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Add search/filter row
	var search_hbox = HBoxContainer.new()
	search_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var search_label = Label.new()
	search_label.text = "Search:"
	search_hbox.add_child(search_label)
	
	search_text = LineEdit.new()
	search_text.placeholder_text = "Filter by name..."
	search_text.custom_minimum_size = Vector2(200, 0)
	search_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_text.text_changed.connect(_on_search_changed)
	search_hbox.add_child(search_text)
	
	var filter_label = Label.new()
	filter_label.text = "Type:"
	search_hbox.add_child(filter_label)
	
	filter_option = OptionButton.new()
	filter_option.add_item("All", 0)
	filter_option.add_item("Files Only", 1)
	filter_option.add_item("Folders Only", 2)
	filter_option.add_item(".json", 3)
	filter_option.add_item(".cache", 4)
	filter_option.item_selected.connect(_on_filter_changed)
	search_hbox.add_child(filter_option)
	
	var clear_filter_btn = Button.new()
	clear_filter_btn.text = "Clear"
	clear_filter_btn.pressed.connect(_on_clear_filters)
	search_hbox.add_child(clear_filter_btn)
	
	vbox.add_child(search_hbox)
	
	# Add selection buttons row
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var select_all_btn = Button.new()
	select_all_btn.text = "Select All"
	select_all_btn.pressed.connect(_on_select_all)
	hbox.add_child(select_all_btn)
	
	var deselect_all_btn = Button.new()
	deselect_all_btn.text = "Deselect All"
	deselect_all_btn.pressed.connect(_on_deselect_all)
	hbox.add_child(deselect_all_btn)
	
	var refresh_btn = Button.new()
	refresh_btn.text = "Refresh"
	refresh_btn.icon = get_editor_interface().get_base_control().get_theme_icon("Reload", "EditorIcons")
	refresh_btn.pressed.connect(_on_refresh_tree)
	hbox.add_child(refresh_btn)
	
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	
	var info_label = Label.new()
	info_label.text = "💡 Tip: Uncheck items to keep them"
	info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hbox.add_child(info_label)
	
	vbox.add_child(hbox)
	
	# Create tree to show directory structure with checkboxes
	tree = Tree.new()
	tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.custom_minimum_size = Vector2(0, 300)
	tree.hide_root = false
	tree.set_columns(3)
	tree.set_column_title(0, "")  # Empty title for checkbox column
	tree.set_column_title(1, "Name")
	tree.set_column_title(2, "Type")
	tree.set_column_titles_visible(true)
	tree.set_column_expand(0, false)
	tree.set_column_expand(1, true)
	tree.set_column_expand(2, true)
	tree.set_column_custom_minimum_width(0, 24)  # Absolute minimum for checkbox
	tree.set_column_custom_minimum_width(1, 200)
	tree.set_column_custom_minimum_width(2, 100)
	tree.set_column_expand_ratio(0, 0)
	tree.set_column_expand_ratio(1, 4)
	tree.set_column_expand_ratio(2, 1)
	
	# Populate the tree with directory contents
	var root = tree.create_item()
	root.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	root.set_checked(0, true)  # Changed to true - selected by default
	root.set_editable(0, true)
	root.set_text(1, "user://")
	root.set_icon(1, get_editor_interface().get_base_control().get_theme_icon("Folder", "EditorIcons"))
	root.set_icon_modulate(1, Color.hex(0xE0A55CFF))  # Hex color for folders
	root.set_text(2, "Directory")
	
	populate_tree(root, "user://")
	
	# Connect item edited signal for checkbox changes
	tree.item_edited.connect(_on_tree_item_edited)
	
	vbox.add_child(tree)
	
	# Add warning label at the bottom
	warning_label = Label.new()
	warning_label.text = "⚠ This action cannot be undone!"
	warning_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(warning_label)
	
	# Update warning label with initial counts
	update_warning_label()
	
	# Add the vbox to dialog
	confirmation_dialog.add_child(vbox)
	
	# Connect confirmation signal
	confirmation_dialog.confirmed.connect(_on_confirmed_delete)
	confirmation_dialog.canceled.connect(_on_dialog_closed)
	confirmation_dialog.close_requested.connect(_on_dialog_closed)
	
	# Add to editor and show
	get_editor_interface().get_base_control().add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()

func populate_tree(parent_item: TreeItem, path: String):
	"""Recursively populate tree with directory contents"""
	var dir = DirAccess.open(path)
	
	if dir == null:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		
		var full_path = path.path_join(file_name)
		var item = tree.create_item(parent_item)
		item.set_metadata(1, full_path)  # Store full path for deletion
		
		# Add checkbox in first column - SELECTED BY DEFAULT
		item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		item.set_checked(0, true)  # Changed to true - selected by default
		item.set_editable(0, true)
		
		item.set_text(1, file_name)
		
		if dir.current_is_dir():
			item.set_text(2, "Folder")
			item.set_icon(1, get_editor_interface().get_base_control().get_theme_icon("Folder", "EditorIcons"))
			item.set_icon_modulate(1, Color.hex(0xE0A55CFF))  # Hex color for folders
			item.set_collapsed(true)  # Start with folders collapsed
			# Recursively add subdirectory contents
			populate_tree(item, full_path)
		else:
			item.set_text(2, "File")
			item.set_icon(1, get_editor_interface().get_base_control().get_theme_icon("File", "EditorIcons"))
			
			# Show file size
			var file = FileAccess.open(full_path, FileAccess.READ)
			if file:
				var size = file.get_length()
				var size_text = format_file_size(size)
				item.set_text(2, "File (%s)" % size_text)
				file.close()
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _on_tree_item_edited():
	"""Handle checkbox state changes and propagate to children"""
	var edited_item = tree.get_edited()
	if edited_item == null:
		return
	
	var is_checked = edited_item.is_checked(0)
	
	# Propagate to all children
	propagate_check_state(edited_item, is_checked)
	
	# Update warning label with new counts
	update_warning_label()

func propagate_check_state(item: TreeItem, checked: bool):
	"""Recursively check/uncheck all children"""
	var child = item.get_first_child()
	while child != null:
		child.set_checked(0, checked)
		propagate_check_state(child, checked)
		child = child.get_next()

func _on_select_all():
	"""Select all items in the tree"""
	var root = tree.get_root()
	if root:
		root.set_checked(0, true)
		propagate_check_state(root, true)
		update_warning_label()

func _on_deselect_all():
	"""Deselect all items in the tree"""
	var root = tree.get_root()
	if root:
		root.set_checked(0, false)
		propagate_check_state(root, false)
		update_warning_label()

func _on_refresh_tree():
	"""Refresh the tree to show current directory state"""
	if tree == null:
		return
	
	# Clear existing tree
	tree.clear()
	
	# Recreate root and repopulate - WITH SELECTION
	var root = tree.create_item()
	root.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	root.set_checked(0, true)  # Changed to true - selected by default
	root.set_editable(0, true)
	root.set_text(1, "user://")
	root.set_icon(1, get_editor_interface().get_base_control().get_theme_icon("Folder", "EditorIcons"))
	root.set_icon_modulate(1, Color.hex(0xE0A55CFF))  # Hex color for folders
	root.set_text(2, "Directory")
	
	populate_tree(root, "user://")
	
	print("Tree refreshed")
	update_warning_label()

func update_warning_label():
	"""Update warning label with file count and total size"""
	if warning_label == null:
		return
	
	var items_to_delete = []
	var total_size_ref = [0]  # Use array to pass by reference
	var file_count_ref = [0]
	var folder_count_ref = [0]
	
	collect_checked_items_with_stats(tree.get_root(), items_to_delete, total_size_ref, file_count_ref, folder_count_ref)
	
	var total_size = total_size_ref[0]
	var file_count = file_count_ref[0]
	var folder_count = folder_count_ref[0]
	
	if items_to_delete.size() == 0:
		warning_label.text = "⚠ No items selected for deletion"
		warning_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	else:
		var size_text = format_file_size(total_size)
		var items_text = ""
		
		if file_count > 0 and folder_count > 0:
			items_text = "%d files and %d folders" % [file_count, folder_count]
		elif file_count > 0:
			items_text = "%d files" % file_count
		elif folder_count > 0:
			items_text = "%d folders" % folder_count
		
		warning_label.text = "⚠ About to delete %s (%s total) - This cannot be undone!" % [items_text, size_text]
		warning_label.add_theme_color_override("font_color", Color.ORANGE_RED)

func collect_checked_items_with_stats(item: TreeItem, result: Array, total_size_ref: Array, file_count_ref: Array, folder_count_ref: Array):
	"""Recursively collect checked items and calculate stats"""
	if item == null:
		return
	
	var is_checked = item.is_checked(0)
	
	if is_checked:
		var path = item.get_metadata(1)
		if path:
			result.append(path)
			
			# Check if it's a file or folder
			var item_type_text = item.get_text(2)
			var is_folder = item_type_text.begins_with("Folder")
			
			if is_folder:
				folder_count_ref[0] += 1
				# Calculate folder size by iterating through actual filesystem
				var folder_size = calculate_folder_size(path)
				total_size_ref[0] += folder_size
				# Don't process children since we already counted the entire folder
				return
			else:
				file_count_ref[0] += 1
				# Get file size
				var file = FileAccess.open(path, FileAccess.READ)
				if file:
					total_size_ref[0] += file.get_length()
					file.close()
	
	# Only process children if this item is NOT checked (to avoid double counting)
	var child = item.get_first_child()
	while child != null:
		collect_checked_items_with_stats(child, result, total_size_ref, file_count_ref, folder_count_ref)
		child = child.get_next()

func calculate_folder_size(path: String) -> int:
	"""Calculate total size of all files in a folder recursively"""
	var total_size = 0
	var dir = DirAccess.open(path)
	
	if dir == null:
		return 0
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		
		var full_path = path.path_join(file_name)
		
		if dir.current_is_dir():
			total_size += calculate_folder_size(full_path)
		else:
			var file = FileAccess.open(full_path, FileAccess.READ)
			if file:
				total_size += file.get_length()
				file.close()
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return total_size

func _on_search_changed(new_text: String):
	"""Filter tree based on search text"""
	apply_filters()

func _on_filter_changed(index: int):
	"""Filter tree based on file type selection"""
	apply_filters()

func _on_clear_filters():
	"""Clear all filters and show everything"""
	search_text.text = ""
	filter_option.select(0)
	apply_filters()

func apply_filters():
	"""Apply current search and filter settings to the tree"""
	var search_term = search_text.text.to_lower()
	var filter_type = filter_option.get_selected_id()
	
	# Recursively filter tree items
	filter_tree_item(tree.get_root(), search_term, filter_type)
	
	# Expand directories that contain matching items
	if filter_type != 0 or not search_term.is_empty():
		expand_matching_parents(tree.get_root())

func filter_tree_item(item: TreeItem, search_term: String, filter_type: int) -> bool:
	"""
	Recursively filter tree items. Returns true if item or any child matches filters.
	Items that don't match are hidden.
	"""
	if item == null:
		return false
	
	var item_name = item.get_text(1).to_lower()
	var item_type_text = item.get_text(2)
	var is_folder = item_type_text.begins_with("Folder") or item_type_text == "Directory"
	
	# Check if this item matches the search term
	var matches_search = search_term.is_empty() or item_name.contains(search_term)
	
	# Check if this item matches the type filter
	var matches_type = false
	match filter_type:
		0: # All
			matches_type = true
		1: # Files only - explicitly exclude folders
			matches_type = not is_folder
		2: # Folders only
			matches_type = is_folder
		3: # .json
			matches_type = not is_folder and item_name.ends_with(".json")
		4: # .cache
			matches_type = not is_folder and item_name.ends_with(".cache")
	
	# Check children
	var any_child_visible = false
	var child = item.get_first_child()
	while child != null:
		if filter_tree_item(child, search_term, filter_type):
			any_child_visible = true
		child = child.get_next()
	
	# For "Files Only" filter, folders should only be visible if they have visible children
	# For other filters, item is visible if it matches filters OR any child is visible
	var should_be_visible = false
	if filter_type == 1 and is_folder:
		# Files Only: folders visible only if they contain matching files
		should_be_visible = any_child_visible
	else:
		should_be_visible = (matches_search and matches_type) or any_child_visible
	
	item.visible = should_be_visible
	
	return should_be_visible

func expand_matching_parents(item: TreeItem):
	"""Expand all parent directories that contain visible children"""
	if item == null:
		return
	
	var item_type_text = item.get_text(2)
	var is_folder = item_type_text.begins_with("Folder") or item_type_text == "Directory"
	
	# Check if this folder has any visible children
	if is_folder and item.visible:
		var has_visible_child = false
		var child = item.get_first_child()
		while child != null:
			if child.visible:
				has_visible_child = true
				break
			child = child.get_next()
		
		# If has visible children, expand this folder
		if has_visible_child:
			item.set_collapsed(false)
	
	# Recursively process children
	var child = item.get_first_child()
	while child != null:
		expand_matching_parents(child)
		child = child.get_next()

func format_file_size(bytes: int) -> String:
	"""Format file size in human-readable format with 2 decimal places like Windows"""
	if bytes < 1024:
		return "%d B" % bytes
	elif bytes < 1024 * 1024:
		return "%.2f KB" % (bytes / 1024.0)
	else:
		return "%.2f MB" % (bytes / (1024.0 * 1024.0))

func _on_confirmed_delete():
	delete_selected_items()
	_on_dialog_closed()

func _on_dialog_closed():
	if confirmation_dialog:
		confirmation_dialog.queue_free()
		confirmation_dialog = null

func delete_selected_items():
	"""Delete only the checked items"""
	var items_to_delete = []
	collect_checked_items(tree.get_root(), items_to_delete)
	
	# Sort by path depth (deepest first) to avoid deleting parent before children
	items_to_delete.sort_custom(func(a, b): return a.count("/") > b.count("/"))
	
	var deleted_count = 0
	var failed_count = 0
	
	for path in items_to_delete:
		if path == "user://":
			# Don't delete the root directory itself
			continue
			
		var error = OK
		if DirAccess.dir_exists_absolute(path):
			# For directories, ensure they're empty first
			delete_directory_contents(path)
			error = DirAccess.remove_absolute(path)
		else:
			error = DirAccess.remove_absolute(path)
		
		if error == OK:
			print("Deleted: ", path)
			deleted_count += 1
		else:
			push_error("Failed to delete: %s (Error Code: %d)", [path, error])
			failed_count += 1
	
	print("Deletion complete. Deleted: %d, Failed: %d" % [deleted_count, failed_count])

func collect_checked_items(item: TreeItem, result: Array):
	"""Recursively collect all checked items"""
	if item == null:
		return
	
	if item.is_checked(0):
		var path = item.get_metadata(1)
		if path:
			result.append(path)
	
	# Process children
	var child = item.get_first_child()
	while child != null:
		collect_checked_items(child, result)
		child = child.get_next()

func delete_directory_contents(path: String):
	"""Recursively delete all files and folders in the given directory"""
	var dir = DirAccess.open(path)
	
	if dir == null:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
		
		var full_path = path.path_join(file_name)
		
		if dir.current_is_dir():
			delete_directory_contents(full_path)
			DirAccess.remove_absolute(full_path)
		else:
			DirAccess.remove_absolute(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
