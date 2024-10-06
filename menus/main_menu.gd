class_name MainMenu
extends Control
@onready var start_button = $MarginContainer/VBoxContainer/StartButton as Button
@onready var options_button = $MarginContainer/VBoxContainer/OptionsButton as Button
@onready var credits_button = $MarginContainer/VBoxContainer/CreditsButton as Button
@onready var disclaimer_button = $MarginContainer/VBoxContainer/DisclaimerButton as Button
@onready var quit_button = $MarginContainer/VBoxContainer/QuitButton as Button

@onready var options_menu = $OptionsMenu as OptionsMenu

@onready var margin_container = $MarginContainer as MarginContainer

@onready var main_game = preload("res://mainGame.tscn") as PackedScene
@onready var confirmation_menu = preload("res://menus/confirmation_scene.tscn") as PackedScene
@onready var credits_menu = preload("res://menus/credits_menu.tscn") as PackedScene
@onready var disclaimer_menu = preload("res://menus/disclaimer_menu.tscn") as PackedScene



func _ready():
	handle_connecting_signals()

func on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_game)

func on_options_button_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true
	
func on_quit_button_pressed() -> void:
	get_tree().change_scene_to_packed(confirmation_menu)
	
func on_disclaimer_button_pressed() -> void:
	get_tree().change_scene_to_packed(disclaimer_menu)
	
func on_credits_button_pressed() -> void:
	get_tree().change_scene_to_packed(credits_menu)

func on_quit_options_menu() -> void:
	margin_container.visible = true
	options_menu.visible = false

func handle_connecting_signals() -> void:
	start_button.button_down.connect(on_start_button_pressed)
	options_button.button_down.connect(on_options_button_pressed)
	quit_button.button_down.connect(on_quit_button_pressed)
	disclaimer_button.button_down.connect(on_disclaimer_button_pressed)
	credits_button.button_down.connect(on_credits_button_pressed)
	
	options_menu.back_from_options_menu.connect(on_quit_options_menu)


func _on_disclaimer_button_pressed():
	pass # Replace with function body.
