class_name ControlDeck
extends Control
# Está clase sirve para gestionar baraja
# La baraja tendrá todas las cartas cuando inicia una partida 
# que necesite una baraja
# Al menos que sirva para agregar cartas a la mano
var deck_cards : Array[CardControl]

func _ready():
	pass

func simple_game_mode_init():
	var card_scene : Resource = preload("res://scenes/cards/card_control.tscn")
	for suit in CardControl.Suits.values():
		for value in range(1, 14):
			var card : CardControl = card_scene.instantiate()
			card.visible = false # Para no ver las cartas instanciadas sobre la baraja
			add_child(card) # Si no se añaden como hijos, todo lo que esté onready no funcionará
			card.initialize_card(suit, value) 
			deck_cards.append(card)
	deck_cards.shuffle()

func standard_game_mode_init():
	var card_scene : Resource = preload("res://scenes/cards/card_control.tscn")
	for suit in range(1,53): #1 al 52
		var card : CardControl = card_scene.instantiate()
		card.visible = false # Para no ver las cartas instanciadas sobre la baraja
		add_child(card)
		card.random_initialize_card() 
		deck_cards.append(card)
	deck_cards.shuffle()

# Sacar una carta de la baraja
func draw_card() -> CardControl:
	if deck_cards.is_empty():
		return null  # Si no hay más cartas en la baraja, devuelve null
	var card : CardControl = deck_cards.pop_front()  # Extrae la primera carta
	return card  # Devuelve la carta extraída
