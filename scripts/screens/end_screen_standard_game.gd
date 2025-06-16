class_name OptionsScreenStandardGame
extends CanvasLayer

@onready var gameplay_manager: GameplayManager = $"../GameplayManager"
var counter_play_score: Counter
var counter_special_score: Counter
var counter_total_score: Counter
var init_all_counters: bool = true

func _init_counters():
	counter_play_score = get_node("../OptionsScreenStandardGame/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/CounterPlayScore") as Counter
	counter_special_score = get_node("../OptionsScreenStandardGame/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer2/CounterSpecialCardsScore") as Counter
	counter_total_score = get_node("../OptionsScreenStandardGame/PanelContainer/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer3/CounterTotalScore") as Counter

func show_score(play_score: int, special_score: int):
	if init_all_counters:
		_init_counters()
		init_all_counters = false
	counter_play_score.count(play_score)
	counter_special_score.count(special_score)
	var total_score: int = play_score + special_score
	counter_total_score.count(total_score)

func _on_keep_playing_button_pressed():
	visible = false
	for node in get_tree().get_nodes_in_group("main_elements_group"):
		node.visible = true

func _on_games_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/games_menu.tscn")
