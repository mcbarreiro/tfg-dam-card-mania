class_name GamesMenu
extends Control

@onready var panel_2: PanelContainer = $Panel2
@onready var hbox: HBoxContainer = $HBoxContainer
@onready var exit_game_button: Button = $ExitGameButton

func _on_simple_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game_modes/simple_game_mode.tscn")

func _on_standard_game_button_pressed():
	panel_2.visible = true
	hbox.visible = false
	exit_game_button.visible = false

func _on_new_game_button_pressed():
	SaveManager.reset_save()
	print(SaveManager.saved_data)
	get_tree().change_scene_to_file("res://scenes/game_modes/standard_game_mode.tscn")
	
func _on_exit_button_pressed():
	panel_2.visible = false
	hbox.visible = true
	exit_game_button.visible = true

func _on_exit_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _on_load_game_button_pressed():
	var saved_data = SaveManager.load_scores()
	if saved_data:
		get_tree().change_scene_to_file("res://scenes/game_modes/standard_game_mode.tscn")
	else:
		print("No hay partida guardada.")
