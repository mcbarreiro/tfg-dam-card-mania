class_name CardControl
extends MarginContainer

signal card_clicked(card: CardControl)

# Enum de palos
enum Suits {Hearts, Diamonds, Spades, Clubs}
# export de los palos. Para mostrarlos en el inspector
@export var suit: Suits = Suits.Hearts
# export del valor de la carta
@export var value: int = 1
# Para cargar el AtlasTexture y mostrar la textura correctamente
var card_texture: Texture2D = preload("res://img/cards/Poker Cards pack/cards.png")
var card_width: int = 49
var card_height: int = 65
var space_x: int = 15
var space_y: int = 31
var cards_per_row: int = 13

# sprite2D (nodo hijo) del que se actualizará la textura
var card_face_sprite: TextureRect
var card_back_sprite: TextureRect

#var original_position: Vector2 # para que se usaba esto ???
var selected: bool = false
var base_position_y: float # Para cuando es seleccionada
var is_higlighted: bool = false

func _to_string():
	var string: String = str(value) + " of " + suit_to_string(suit)
	return string

func initialize_card(card_suit: Suits, card_value: int):
	suit = card_suit
	set_value(card_value)
	card_face_sprite = get_node("Face")
	card_back_sprite = get_node("Back")
	base_position_y = position.y
	set_card_texture(suit, value)

func random_initialize_card():
	suit = randi() % 3
	value = randi() % 13 + 1
	set_value(value)
	card_face_sprite = get_node("Face")
	card_back_sprite = get_node("Back")
	base_position_y = position.y
	set_card_texture(suit, value)

func raise_card():
	selected = !selected
	var tween: Tween = get_tree().create_tween()
	var target_y: float = base_position_y - 20 if selected else base_position_y
	tween.tween_property(self, "position:y", target_y, 0.2)
	await tween.finished
	
func flip_card():
	var tween: Tween = get_tree().create_tween()
	# Primera mitad: reducir escala.x a 0
	tween.tween_property(self, "scale:x", 0.0, 0.35).set_trans(Tween.TRANS_LINEAR)
	# Cuando llega a la mitad de la animación, cambiar visibilidad de las caras
	tween.tween_callback(Callable(self, "_on_flip_halfway"))
	# Segunda mitad: aumentar escala.x a 1
	tween.tween_property(self, "scale:x", 1.0, 0.1).set_trans(Tween.TRANS_LINEAR)
	await tween.finished

func _on_flip_halfway():
	card_face_sprite.visible = !card_face_sprite.visible
	card_back_sprite.visible = !card_back_sprite.visible

func shrink_card_animation():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween
	
func hightlight_card():
	var tween = create_tween()
	if hightlight_card():
		tween.tween_property(self, "modulate", Color(1, 1, 0.5), 0.1) # Amarillo claro
	else:
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1) # Vuelve a blanco (normal)
	is_higlighted = !is_higlighted

# Asigna la textura de la carta según el palo y valor
func set_card_texture(selected_suit: Suits, selected_value: int):
	var row: Suits = selected_suit # filas 0-3
	var column: int = selected_value - 1 # columnas 0-12
	# Para calcular la posición en X e Y de la carta en la textura/atlas
	var x_offset: int = column * (card_width + space_x)
	var y_offset: Suits = (row * (card_height + space_y)) as Suits
	# Se crea la atlasTextura
	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = card_texture # imagen que usa
	# la region es la parte del atlas que se verá de la textura.
	# card_width y card_height son las dimensiones de la carta
	# x_offset y y_offset son coordenadas para la imagen
	atlas_texture.region = Rect2(x_offset, y_offset, card_width, card_height)
	# asignación de la textura 
	card_face_sprite.texture = atlas_texture

# Muestra la info de la carta (palo y valor)
# Borrar más tarde
func print_card_info(selected_suit: Suits, selected_value: int):
	var value_name: String = ""
	match selected_value: # match == switch
		1: value_name = "Ace"
		11: value_name = "Jack"
		12: value_name = "Queen"
		13: value_name = "King"
		_: # (default)
			value_name = str(selected_value) # Para los valores numéricos 2-10
	print("Selected card: " + value_name + " of " + suit_to_string(selected_suit))

# convierte el palo a string
func suit_to_string(selected_suit: Suits) -> String:
	match selected_suit:
		Suits.Hearts: return "Hearts"
		Suits.Diamonds: return "Diamonds"
		Suits.Spades: return "Spades"
		Suits.Clubs: return "Clubs"
	return "Unknown"

# setter para que el valor sea 1-13
func set_value(val: int) -> void:
	if val < 1:
		value = 1
	elif val > 13:
		value = 13
	else:
		value = val

# getter
func get_value() -> int:
	return value

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		card_clicked.emit(self)
