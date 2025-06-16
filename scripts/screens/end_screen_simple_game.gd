class_name EndScreenSimpleGame
extends CanvasLayer

@onready var total_score: Label = $PanelContainer/MarginContainer/VBoxContainer/TotalScore
@onready var card_manager: CardManager = $"../CardManager"
@onready var games_menu_button: Button = $PanelContainer/MarginContainer/VBoxContainer/GamesMenuButton

func _ready():
	card_manager.end_of_game.connect(end_screen_show)
	print(get_tree())
	games_menu_button.pressed.connect(back_to_games_menu)
	print(get_tree())
	
func end_screen_show(score: int):
	for node in get_tree().get_nodes_in_group("game_group"):
		node.visible = false
	visible = true
	total_score.text = str(score)

func back_to_games_menu():
	get_tree().change_scene_to_file("res://scenes/menus/games_menu.tscn")
