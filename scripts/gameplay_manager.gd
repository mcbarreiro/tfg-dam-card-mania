class_name GameplayManager
extends Node

@onready var root : Node2D = $".."
@onready var options_screen: OptionsScreenStandardGame = $"../OptionsScreenStandardGame"

# GUI Elements
@onready var target_score_label: Label = $"../UILayer/TargetScore/VBoxContainer/TargetScoreLabel"
@onready var total_score_counter: Counter = $"../TotalScore/MarginContainer/HBoxContainer/ScoreCounter"
@onready var turns_left_label: Label = $"../UILayer/TurnsLeft/MarginContainer/HBoxContainer/Label"
@onready var player_play_value_label: Label = $"../UILayer/PlayerPlayValue/VBoxContainer/PlayerPlayValueLabel"

# Buttons
@onready var player_turn_button: Button = $"../UILayer/PlayerTurnButton"
@onready var draw_card_button: Button = $"../UILayer/DrawCardButton"

@onready var player_objects_container: PlayerObjectsPanel  = $"../UILayer/PlayerObjectsPanel"
var choosing_mod_panel:ChoosingModPanel

# Gameplay Elements
# Hands
@onready var player_hand: ControlHand = $"../GameplayElements/PlayerHand"
@onready var special_cards_hand: ControlHand = $"../GameplayElements/SpecialCardsHand"
@onready var dealer_hand: ControlHand= $"../GameplayElements/DealerCardsControl"

@onready var deck: ControlDeck = $"../GameplayElements/Deck"

var player_turns_left : int = 3

var total_score : int = 0# puntuación de la partida, se acumula tras las partidas
var play_score: int = 0# puntos ganados por la propia mano
var special_score: int = 0# puntos ganados por las cartas especiales
var target_score: int = 0# puntuacion de las cartas del dealer
var player_play_current_value : int = 0 #valor de las cartas seleccionadas/jugada/mano

var hand_selected_cards : Array[CardControl] = [] # selección de cartas hecha por el jugador
var dealer_cards : Array[CardControl] = []
var phase: int = 0

func _ready():
	# Para inicializar la primera vez
	player_turn_button.pressed.connect(_end_player_card_selection)
	deck.standard_game_mode_init()
	draw_card_button.disabled = true
	
	var data = SaveManager.load_scores()
	if data:
		print("DATA no es null --> ", data)
		_load_game_state(data)
	else:
		print("DATA --> ", data)
		_start_new_game()

# Para cuando no hay partida que cargar
func _start_new_game():
	for i in range(5):
		_add_card_to_hand(player_hand, true)

	for i in range(2):
		target_score += _get_dealer_cards().value

	# Actualizar labels
	target_score_label.text = str(target_score)
	turns_left_label.text = str(player_turns_left)
	player_play_value_label.text = str(player_play_current_value)

# Carga los datos guardados
func _load_game_state(data: Dictionary):
	# Cargar valores guardados
	total_score = data.get("total_score", 0)
	special_score = data.get("special_score", 0)
	play_score = data.get("play_score", 0)
	target_score = data.get("target_score", 0)
	player_play_current_value = data.get("player_play_current_value", 0)
	player_turns_left = data.get("player_turns_left", 3)
	phase = data.get("phase", 0)

	# Actualizar labels con valores cargados
	total_score_counter.count(total_score)
	player_play_value_label.text = str(player_play_current_value)
	turns_left_label.text = str(player_turns_left)
	target_score_label.text = str(target_score)

	
	if data.has("player_hand"):
		SaveManager.load_hand_from_data(data["player_hand"], player_hand)
		
	if phase == 1:
		_enable_player_objects()
		player_turn_button.pressed.disconnect(_end_player_card_selection)
		player_turn_button.pressed.connect(_end_game)
		draw_card_button.pressed.connect(_on_pressed_draw_button)
		draw_card_button.disabled = false
	else:
		for card in player_hand.cards_hand:
			card.card_clicked.connect(_on_multiple_card_clicked)
		
	if data.has("dealer_hand"):
		SaveManager.load_hand_from_data(data["dealer_hand"], dealer_hand)
	if data.has("special_hand"):
		SaveManager.load_hand_from_data(data["special_hand"], special_cards_hand, true)

func _end_game():
	# Se desactivan las conexiones de las señales activas
	if player_turns_left > 0:
		turns_left_label.text= str(0)
	draw_card_button.pressed.disconnect(_on_pressed_draw_button)
	draw_card_button.disabled = true
	await _calculate_final_score()	
	print("FIN DE LA PARTIDA")
	player_turn_button.disabled = true

	for node in get_tree().get_nodes_in_group("main_elements_group"):
		node.visible = false
	_show_choosing_panel()

func _show_choosing_panel():
	var choosing_panel_scene = load("res://scenes/choosing_mod_panel.tscn").instantiate()
	choosing_mod_panel = choosing_panel_scene
	add_child(choosing_mod_panel)
	choosing_mod_panel.generate_random_mods()
	choosing_mod_panel.mod_clicked.connect(_assign_mod_to_node)
	choosing_mod_panel.skip_mod_panel.connect(_skip_choosing_mod_panel)

func _assign_mod_to_node(mod:Control):

	if mod.price <= total_score:
		choosing_mod_panel.button.disabled = true
		print("MOD PRICE --> ",mod.price)
		if mod is SpecialCardControl:
			mod.get_parent().remove_child(mod)
			special_cards_hand.add_child(mod)
			special_cards_hand.add_card_to_hand(mod)
			total_score -= mod.price
			await total_score_counter.count(total_score)
			choosing_mod_panel.mods_list.erase(mod)
		if mod is PlayableObject:
			mod.get_parent().remove_child(mod)
			player_objects_container.add_object([mod])
			total_score -= mod.price
			await total_score_counter.count(total_score)
			choosing_mod_panel.mods_list.erase(mod)
		_new_game()

func _skip_choosing_mod_panel():
	_new_game()

func _new_game():
	player_turn_button.disabled = false
	await _enable_player_objects(true)
	for node in get_tree().get_nodes_in_group("main_elements_group"):
		node.visible = true
	choosing_mod_panel.visible = false

	player_hand.remove_all_cards_from_hand()
	_reset_score_turns_labels() # reinicia los labels: total_score, turn, play
	# Volver a dar cartas a la mano
	for i in range(5):
		_add_card_to_hand(player_hand, true)
	player_turn_button.pressed.disconnect(_end_game)
	player_turn_button.pressed.connect(_end_player_card_selection)

func _reset_score_turns_labels():
	player_play_current_value = 0
	player_turns_left = 3
	turns_left_label.text = str(player_turns_left)
	player_play_value_label.text = str(player_play_current_value)

func _calculate_final_score():
	var diff = abs(player_play_current_value - target_score)
	# Penalización
	var penalty = int(diff * 2)
	var final_play_score = max(player_play_current_value - penalty, 0)
	
	if player_play_current_value == target_score:
		final_play_score += 10
	
	total_score += final_play_score
	play_score += final_play_score
	
	_calculate_mod_score()
	await total_score_counter.count(total_score)
	print(total_score)


func _calculate_mod_score():
	if special_cards_hand.cards_hand != []:
		for i in special_cards_hand.cards_hand:
			if i.type == SpecialCardControl.TYPE.SUIT:
				for j in player_hand.cards_hand:
					if j.suit == i.suit: 
						total_score += i.value
						special_score += i.value

func _decrease_turns_left():
	player_turns_left -= 1
	turns_left_label.text = str(player_turns_left)

	if player_turns_left <= 0:
		_end_game()

# para el boton END TURN
# Habilita el boton DRAW CARDS y los PLAYABLE OBJECTS
func _end_player_card_selection():
	# Fase de selección de cartas
	player_turn_button.disabled = true
	await _hand_card_selection(player_hand)
	player_turn_button.disabled = false
	player_turn_button.pressed.disconnect(_end_player_card_selection)
	player_turn_button.pressed.connect(_end_game)

	# Ya no se podrá hacer click en las cartas
	for i in player_hand.cards_hand:
		i.card_clicked.disconnect(_on_multiple_card_clicked)
		
	draw_card_button.disabled = false
	draw_card_button.pressed.connect(_on_pressed_draw_button)
	
	# Habilitar la seleccion de objetos por parte del jugador
	await _enable_player_objects()

# Mueve el contenedor hacia el viewport/ donde el jugador puede verlo
func _enable_player_objects(hide:bool = false):
	var hide_panel : int = 1
	if hide:
		hide_panel = -1
		player_objects_container.return_playable.disconnect(_playable_object_action)
	else:
		phase = 1
		player_objects_container.return_playable.connect(_playable_object_action)
	
	var tween : Tween = get_tree().create_tween()
	var new_x : int = player_objects_container.position.x + (player_objects_container.size.x) * hide_panel
	var new_y : int = player_objects_container.position.y
	var new_position : Vector2 = Vector2(new_x,new_y)
	tween.tween_property(player_objects_container, "position", new_position, 0.3)
	await tween.finished

func _playable_object_action(object: PlayableObject):
	match object.action_type:
		object.ACTIONS.CUT:
			_cut_object_action()

func _cut_object_action():
	for i in player_hand.cards_hand:
		if not i.card_clicked.is_connected(_on_card_to_cut):
			i.card_clicked.connect(_on_card_to_cut)

func _on_card_to_cut(card:CardControl):
	card.raise_card()
	if card.selected:
		await card.shrink_card_animation()
		player_hand.cards_hand.erase(card)
		player_hand.update_hand_positions()
		for i in player_hand.cards_hand:
			i.card_clicked.disconnect(_on_card_to_cut)
	player_play_current_value -= card.value
	player_play_value_label.text = str(player_play_current_value)
	_decrease_turns_left()

# Elimina las cartas que no son seleccionadas
func _hand_card_selection(hand:ControlHand):
	var cards_to_remove : Array[CardControl] = []

	for i in hand.cards_hand:
		if i not in hand_selected_cards:
			cards_to_remove.append(i)

	for i in cards_to_remove:
		var new_position : Vector2 = i.global_position
		hand.remove_card_from_hand(i,false)
		root.add_child(i)
		i.position = new_position
		await hand.animate_card_to_position(i, Vector2(new_position.x, new_position.y+100))
		i.queue_free() # Libera la carta de memoria
		
	for i in hand_selected_cards:
		i.selected = false

	await hand.update_hand_positions()
	hand_selected_cards.clear() # el array queda vacio

# para añadir una carta a la PLAYER HAND
func _add_card_to_hand(hand:ControlHand = player_hand, connect_signal:bool = false):
	var card : CardControl

	if hand.cards_hand.size() < 5:
		card = deck.draw_card()
	if card:
		# Guardar la posición global ANTES de cambiar de padre
		var global_pos : Vector2 = card.global_position
		# Si se elimina desde el draw_card de Deck va a desplazarse la carta desde la esquina
		# porque no se ha guardado por ningún sitio esa posicion en la que esta
		card.get_parent().remove_child(card) 
		hand.add_child(card)
		card.global_position = global_pos  # Reestablece su posición global tras el cambio de padre
		hand.add_card_to_hand(card)
		if hand == player_hand and connect_signal:
			card.card_clicked.connect(_on_multiple_card_clicked)

# inicializa la SPECIAL HAND
func _add_cards_to_special_hand():
	# se consiguen después de cada ronda
	var special_card_scene : Resource = preload("res://scenes/cards/special_card_control.tscn")
	var card : SpecialCardControl = special_card_scene.instantiate()

	if card:
		# Guardar la posición global ANTES de cambiar de padre
		var global_pos : Vector2 = card.global_position
		# Si se elimina desde el draw_card de Deck va a desplazarse la carta desde la esquina
		# porque no se ha guardado por ningún sitio esa posicion en la que esta
		special_cards_hand.add_child(card)
		card.global_position = global_pos  # Reestablece su posición global tras el cambio de padre
		special_cards_hand.add_card_to_hand(card)

# Funcionalidad para elegir las cartas
# En el modo standard se puede elegir varias cartas
func _on_multiple_card_clicked(card):
	await card.raise_card()
	# Comprobaciones para añadir al array de cartas seleccionadas
	if card.selected == false and card in hand_selected_cards:
		hand_selected_cards.remove_at(hand_selected_cards.find(card))
		player_play_current_value -= card.value
		player_play_value_label.text = str(player_play_current_value)
	if card.selected == true and card not in hand_selected_cards:
		hand_selected_cards.append(card)
		player_play_current_value += card.value
		player_play_value_label.text = str(player_play_current_value)

# funcionalidad DRAW BUTTON 
func _on_pressed_draw_button(hand:ControlHand = player_hand, connect_signal:bool = false):
	var card : CardControl

	if hand.cards_hand.size() < 5:
		card = deck.draw_card()
	if card:
		# Guardar la posición global ANTES de cambiar de padre
		var global_pos : Vector2 = card.global_position
		# Si se elimina desde el draw_card de Deck va a desplazarse la carta desde la esquina
		# porque no se ha guardado por ningún sitio esa posicion en la que esta
		card.get_parent().remove_child(card) 
		hand.add_child(card)
		card.global_position = global_pos  # Reestablece su posición global tras el cambio de padre
		hand.add_card_to_hand(card)
		player_play_current_value += card.value
		player_play_value_label.text = str(player_play_current_value)
		_decrease_turns_left()

# Para HAND del DEALER
func _get_dealer_cards():
	# se ponen dos cartas aleatorias en CardPitPanel
	var card : CardControl

	if dealer_cards.size() < 2:
		card = deck.draw_card()

	if card:
		# Guardar la posición global ANTES de cambiar de padre
		var global_pos : Vector2= card.global_position
		# Si se elimina desde el draw_card de Deck va a desplazarse la carta desde la esquina
		# porque no se ha guardado por ningún sitio esa posicion en la que esta
		card.get_parent().remove_child(card) 
		dealer_hand.add_child(card)
		card.global_position = global_pos  # Reestablece su posición global tras el cambio de padre
		dealer_hand.add_card_to_hand(card)
		dealer_cards.append(card)
		card.base_position_y = get_viewport().position.y
	return card

func _on_options_button_pressed():
	for node in get_tree().get_nodes_in_group("main_elements_group"):
		node.visible = false
	options_screen.visible = true
	options_screen.show_score(play_score,special_score)

func _on_save_button_pressed():
	SaveManager.save_scores(
		total_score,
		special_score,
		play_score,
		target_score,
		player_play_current_value,
		player_turns_left,
		phase
	)
	SaveManager.save_hand_cards(player_hand.cards_hand)
	SaveManager.save_hand_cards(dealer_hand.cards_hand, "dealer_hand")
	SaveManager.save_special_cards(special_cards_hand.cards_hand)
	print("SAVE DATA --> ", SaveManager.saved_data)
