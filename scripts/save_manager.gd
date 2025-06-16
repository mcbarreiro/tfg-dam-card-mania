extends Node

var SAVE_PATH: String = OS.get_user_data_dir() + "/savegame.json"
var saved_data: Dictionary = {}

func save_scores(total_score, special_score, play_score, target_score, play_value, turns_left, phase):
	# Solo actualiza las claves necesarias, sin borrar otras
	saved_data["total_score"] = total_score
	saved_data["special_score"] = special_score
	saved_data["play_score"] = play_score
	saved_data["target_score"] = target_score
	saved_data["player_play_current_value"] = play_value
	saved_data["player_turns_left"] = turns_left
	saved_data["phase"] = phase

	# Guardar el diccionario completo (incluyendo mano, si se guardó antes)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(saved_data))
	file.close()
	print(file.get_path())

# Guarda la mano del jugador
func save_hand_cards(cards: Array[Control], name: String = "player_hand"):
	var serialized_cards = []
	for card in cards:
		if card is CardControl:
			serialized_cards.append({
				"suit": card.suit,
				"value": card.value
			})
	saved_data[name] = serialized_cards

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(saved_data))
	file.close()

# guarda las cartas especiales
func save_special_cards(special_cards: Array[Control]):
	var serialized_specials = []
	for special in special_cards:
		serialized_specials.append({
			"suit": special.suit,
			"type": special.type,
			"value": special.value,
			"price": special.price
		})
	saved_data["special_hand"] = serialized_specials

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(saved_data))
	file.close()

func load_hand_from_data(data: Array, hand: ControlHand, special: bool = false):
	for card_data in data:
		if special:
			var new_card = preload("res://scenes/cards/special_card_control.tscn").instantiate()
			new_card.initialize_card(card_data["suit"], card_data["value"], card_data["type"], card_data["price"])
			hand.add_child(new_card)
			hand.add_card_to_hand(new_card)
		else:
			var new_card = preload("res://scenes/cards/card_control.tscn").instantiate()
			new_card.initialize_card(card_data["suit"], card_data["value"])
			hand.add_child(new_card)
			hand.add_card_to_hand(new_card)

func load_scores() -> Dictionary:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data is Dictionary:
			saved_data = data
			return data
	return {}

func reset_save():
	saved_data.clear()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string("{}")
	file.close()
