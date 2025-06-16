class_name ChoosingModPanel
extends PanelContainer

signal mod_clicked(mod: Control)
signal skip_mod_panel

var hbox: HBoxContainer
var button: Button

const PLAYABLE_OBJECT_SCENE = preload("res://scenes/playable_object.tscn")
const SPECIAL_CARD_SCENE = preload("res://scenes/cards/special_card_control.tscn")
var mods_list: Array[Control] = []

func generate_random_mods():
	hbox = get_node("MarginContainer/VBoxContainer/HBoxContainer")
	button = get_node("MarginContainer/VBoxContainer/Button")
	var playable_obj: PlayableObject = PLAYABLE_OBJECT_SCENE.instantiate()
	var special_card_1: SpecialCardControl = SPECIAL_CARD_SCENE.instantiate()
	var special_card_2: SpecialCardControl = SPECIAL_CARD_SCENE.instantiate()
	_add_mod([special_card_1, playable_obj, special_card_2])

func _add_mod(mod: Array[Control]):
	for i in mod:
		hbox.add_child(i)
		mods_list.append(i)
		if i is PlayableObject:
			i.playable_clicked.connect(_on_playable_object_clicked)
		if i is SpecialCardControl:
			print("_add_mod SPECIAL --> ", i)
			i.special_clicked.connect(_on_playable_object_clicked)

func _make_custom_tooltip(for_text):
	if for_text == '':
		return null
	var tooltip_scene: PackedScene = load("res://scenes/tooltip.tscn")
	var tooltip: PanelContainer = tooltip_scene.instantiate()
	tooltip.get_node("../Label").text = for_text
	return tooltip

func _on_playable_object_clicked(mod):
	mod_clicked.emit(mod)
	print("_on_playable_object_clicked")

func _on_button_pressed():
	skip_mod_panel.emit()
