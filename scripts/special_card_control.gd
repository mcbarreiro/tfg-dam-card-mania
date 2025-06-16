class_name SpecialCardControl
extends TextureRect
# Cartas especiales: modifican la puntuación que se recibe (ej x3, x2)
# según las cartas que se jueguen
signal special_clicked(special : SpecialCardControl)

enum TYPE {SUIT}
# SUIT: modifica el valor según el palo del mod
enum SUITS { Hearts, Diamonds, Spades, Clubs }

@onready var card_texture : Texture2D = preload("res://img/cards/cardsMods.png")
@export var suit : SUITS = SUITS.Hearts
@export var type : TYPE
@export var value : int # los puntos por los que se multiplica la puntuacion

var price:int

var card_width : int = 49
var card_height : int = 65
var space_x : int = 15
var cards_per_row : int = 4

func _ready():
	_random_init()

func _random_init():
	suit = randi() % 3
	type = TYPE.SUIT
	value = randi() % 4 + 1
	price = 15
	tooltip_text = str(price)
	set_card_texture(suit)

func initialize_card(card_suit: SUITS, card_value: int, card_type: TYPE, card_price: int):
	suit = card_suit
	value = card_value
	type = card_type
	price = card_price
	set_card_texture(suit)
	
func set_card_texture(suit: SUITS):
	var column : SUITS = suit  # columnas 0-3
	var x_offset : int = column * (card_width + space_x)
	var atlas_texture : AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = card_texture
	atlas_texture.region = Rect2(x_offset, 0, card_width, card_height)
	texture = atlas_texture
	
func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		special_clicked.emit(self)
