class_name DealerCardsControl
extends Control

const CARD_WIDTH: int = 49
const CARD_SPACING: int = 50
@onready var y_position: int = 0
@onready var center_x: int = size.x / 2 # Centro en el eje X de la de la mano

var dealer_cards: Array[CardControl] = []

func add_card_to_dealer(card: CardControl):
	card.visible = true
	dealer_cards.insert(0, card)
	update_hand_positions()
	card.flip_card()

# actualiza la posicion de las cartas
func update_hand_positions():
	for i in range(dealer_cards.size()):
		var new_position: Vector2 = Vector2(calculate_card_position(i), y_position)
		var card: CardControl = dealer_cards[i]
		animate_card_to_position(card, new_position)

func calculate_card_position(index: int):
	var total_width: int = (dealer_cards.size() - 1) * CARD_SPACING
	var start_x: int = center_x - total_width / 2
	return start_x + index * CARD_SPACING

func animate_card_to_position(card: CardControl, new_position: Vector2):
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.3)
	await tween.finished
	card.base_position_y = new_position.y # para seleccionar la carta
