class_name  PlayerObjectsPanel
extends PanelContainer

@onready var vbox : VBoxContainer = $VBoxContainer
var object_list : Array[PlayableObject] = []
signal return_playable(playable_object : PlayableObject)

func add_object(object : Array[PlayableObject]):
	for i in object:
		vbox.add_child(i)
		object_list.append(i)
		if i is PlayableObject:
			i.playable_clicked.connect(_on_return_playable)

func remove_object(object : Array[PlayableObject]):
	for i in object:
		vbox.remove_child(i)
		object_list.erase(i)

func _on_return_playable(playable_object):
	return_playable.emit(playable_object)
