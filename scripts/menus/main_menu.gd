class_name MainMenu
extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/games_menu.tscn")

func _on_exit_button_pressed():
	get_tree().quit()
