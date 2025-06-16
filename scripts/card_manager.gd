class_name CardManager
extends Node2D

## INFORMACION
# En esta clase se maneja:
# El reparenting de las cartas de Deck a Hand
# Añadir cartas a la Hand
# Que las cartas vuelvan a la Hand cuando son soltadas
# Mover las cartas de la Hand
# Que el Deck "reparta" cartas a la Hand

signal card_clamped
signal end_of_game(score : int)

@onready var deck : ControlDeck = $ControlDeck
@onready var hand: ControlHand = $ControlHand
@onready var turn_button: Button = $"../ButtonControl/TurnButton"
@onready var slot: SlotControl = $"../SlotControl"
@onready var score_label : Label = $"../ScoreControl/PanelContainer/Label"
@onready var options_button : Button = $"../GamesMenuButton"

var score : int
var card_selected : Control
var previous_card_on_slot : CardControl

func _ready():
	turn_button.pressed.connect(check_play)
	options_button.pressed.connect(back_to_games_menu)
	
	deck.simple_game_mode_init() # ya no se inicializa en el ready
	
	_draw_card_to_game()
	for i in range(5): # Se empieza con la mano completa
		_on_deck_clicked()

	# Comprobación para no terminar el juego al empezar
	while !check_for_available_plays():
		card_back_to_deck()
		_draw_card_to_game()

func back_to_games_menu():
	get_tree().change_scene_to_file("res://scenes/menus/games_menu.tscn")

func card_back_to_deck():
	#Se recupera la carta del slot y se guarda una referencia
	var card: CardControl = slot.card_on_slot
	#Reparenting de la carta a la deck (ultima posicion del array)
	if card: 
		card.flip_card()

		var global_pos : Vector2 = card.global_position

		card.get_parent().remove_child(card)
		deck.deck_cards.append(card)
		deck.add_child(card)

		card.global_position = global_pos
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(card, "position", Vector2.ZERO, 0.3)
		await tween.finished

func _draw_card_to_game():
	# Va a poner una carta sobre la "mesa" al principio de la partida
	# y al final de cada turno del jugador
	# la carta no se debe de seleccionar ni poder el jugador interactuar con ella
	var card : CardControl = deck.draw_card()
	if card:
		card.visible = true # Están todas en false para que no se muestren en el lugar de la baraja
		card.flip_card()
		
		var global_pos : Vector2 = card.global_position
		
		card.get_parent().remove_child(card)
		slot.card_on_slot = card # Esta es la que debería estar usando check available plays
		slot.add_child(card)
		
		card.global_position = global_pos
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(card, "position", Vector2.ZERO, 0.3)
		await tween.finished
		# Se emite esta señal porque con los tweens no se actualiza bien cual carta
		# esta en el slot
		emit_signal("card_clamped") 
		
	else:
		# Se acaba la partida simple
		print("Nos hemos quedado sin baraja")

func check_play():
	var game_card : CardControl = slot.card_on_slot
	var player_card : CardControl = card_selected

	# Que haya cartas seleccionadas
	if card_selected != null:
		if check_current_play(game_card,player_card) != 0:
			change_score(game_card,player_card)
			score_label.text = str(score)
			previous_card_on_slot = game_card
			await clamp_card_to_slot()

	# Comprobar que se pueda seguir jugando después de jugar
	# Se dan cartas porque esto ocurre después de un turno
	if check_for_available_plays() and hand.cards_hand.size() <5:
		for i in range(hand.cards_hand.size()):
			_on_deck_clicked()

	# Si hay menos de 5 cartas y no hay jugadas disponible
	# Dar cartas y comprobar que hay jugadas disponibles
	elif !check_for_available_plays() and hand.cards_hand.size() <5:
		for i in range(hand.cards_hand.size()):
			_on_deck_clicked()
		if !check_for_available_plays():
			print("FIN DE LA PARTIDA")
			end_of_game.emit(score)

func check_for_available_plays() -> bool:
	for i in hand.cards_hand:
		if check_current_play(slot.card_on_slot,i) != 0:
			return true
	return false

func check_current_play(game_card : CardControl, player_card : CardControl) -> int:
	if game_card.suit == player_card.suit and game_card.value == player_card.value:
		return 1
	elif game_card.value == player_card.value:
		return 2
	elif game_card.suit == player_card.suit:
		return 3
	else:
		return 0

func change_score(game_card : CardControl, player_card : CardControl):
	match check_current_play(game_card, player_card):
		1:
			score += 20
		2:
			score += 10
		3:
			score += 5
		0:
			return

func _on_card_clicked(card):
	if card_selected:
		if card_selected == card:
			# Si es la misma, la baja y deselecciona.
			# Se sale de la funcion
			card_selected.raise_card()  # La baja
			card_selected = null
			return
		else:
			# Si es otra, bajamos la anterior
			card_selected.raise_card()
	# selecciona la nueva carta y la levanta
	card_selected = card
	card_selected.raise_card()

func clamp_card_to_slot():
	if card_selected != null and card_selected.selected:
		hand.selected_card = card_selected
		# Guardar posición global antes de moverla
		var global_pos : Vector2 = card_selected.global_position
		
		# Cambiar de padre
		hand.remove_card_from_hand(card_selected)
		slot.card_on_slot = card_selected
		slot.add_child(card_selected)
		# Restaurar posición global
		card_selected.global_position = global_pos
		card_selected.card_clicked.disconnect(_on_card_clicked)
		
		# Tween hacia la posición local (0,0 == Vector2.ZERO)
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(card_selected, "position", Vector2.ZERO, 0.3)
		
		await tween.finished
		_draw_card_to_game()
		card_selected = null
		
	else:
		hand.selected_card = null

func _on_deck_clicked():
	# Desde aquí estamos gestionando el emparentamiento de nodos
	# no hace falta hacerlo desde los metodos
	var card : CardControl
	if hand.cards_hand.size() < 5:
		card = deck.draw_card()
	if card:
		# Guardar la posición global ANTES de cambiar de padre
		var global_pos : Vector2= card.global_position

		# Si se elimina desde el draw_card de Deck va a desplazarse la carta desde la esquina
		# porque no se ha guardado por ningún sitio esa posicion en la que esta
		card.get_parent().remove_child(card) 
		hand.add_child(card)
		card.global_position = global_pos  # Reestablece su posición global tras el cambio de padre
		hand.add_card_to_hand(card)
		card.card_clicked.connect(_on_card_clicked)
		card.base_position_y = position.y
