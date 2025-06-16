class_name PlayableObject
extends Container

signal playable_clicked(playable_object : PlayableObject)
enum ACTIONS {CUT}
@onready var texture_button : TextureButton = $TextureButton
var action_type : ACTIONS = ACTIONS.CUT
var price: int
var normal_texture : Texture2D

func _ready():
	_random_init()
	texture_button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	playable_clicked.emit(self)

func _random_init():
	action_type = ACTIONS.CUT
	price = 20
	texture_button.tooltip_text = str(price)
	_set_textures()

func _set_textures():
	match action_type:
		ACTIONS.CUT: 
			normal_texture = preload("res://img/objects/scissors-svgrepo-com.png")
			texture_button.texture_normal = normal_texture
