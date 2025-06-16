class_name MenuTestButton
extends Button

signal menu_test_button_pressed

func _on_pressed():
	menu_test_button_pressed.emit()
