class_name ControlHand
extends Control

@onready var hand_y_position : int = 0
@onready var center_screen_x : int = size.x / 2# Centro en el eje X de la mano

const HAND_COUNT : int = 10 # Cuantás cartas instancia.
const CARD_SCENE_PATH = "res://scenes/card.tscn" # cargar la escena Card
const CARD_WIDTH : int = 49 
const CARD_SPACING : int = 50

var cards_hand : Array[Control] = []
var selected_card : CardControl

func _ready():
	update_hand_positions()

func add_card_to_hand(card : Control):
	card.visible = true
	cards_hand.insert(0, card)
	await update_hand_positions()
	if card is CardControl:
		card.flip_card()

# Método para eliminar una carta de la mano y reorganizar las demás
func remove_card_from_hand(card : CardControl, default_animation:bool = true):
	if card in cards_hand:
		cards_hand.erase(card)  # Elimina la carta del array
		remove_child(card)  # La elimina del árbol de nodos
		if default_animation: # En caso de que se vaya a usar otra animación
			update_hand_positions()  # Reorganiza las cartas restantes
	return card # Se devuelve la carta que se ha eliminado de Hand 

func remove_all_cards_from_hand():
	for card in cards_hand:
		remove_child(card)  # La elimina del árbol de nodos
		card.queue_free()
	cards_hand.clear()

# actualiza la posicion de todas las cartas en la mano
func update_hand_positions():
	# Recorre cards_hand y calcula su nueva posicion
	print(cards_hand)
	for i in range(cards_hand.size()):
		var new_position : Vector2 = Vector2(calculate_card_position(i), hand_y_position)
		var card : Control = cards_hand[i]
		animate_card_to_position(card, new_position)

# Calcula la posicion de la carta en la mano
func calculate_card_position(index : int):
	var total_width : int = (cards_hand.size() - 1) * CARD_SPACING
	var start_x : int = center_screen_x - total_width / 2
	return start_x + index * CARD_SPACING

# INFO: simplemente cambia la posicion de la carta con un tween
func animate_card_to_position(card : Control, new_position : Vector2):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.3)
	if card is not Control:
		card.base_position_y = new_position.y
	await tween.finished
