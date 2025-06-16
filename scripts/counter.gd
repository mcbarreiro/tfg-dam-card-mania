class_name Counter
extends Label

var tween: Tween = null
var current_number: int = 0

func count(target_number: int):
	if tween:
		tween.kill()
		
	var diff = abs(target_number - current_number)
	var duration = diff * 0.07 
	duration = clamp(duration, 0.5, 2.0)
	
	tween = create_tween()
	tween.tween_method(update_label, current_number, target_number, duration)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	current_number = int(target_number)

func update_label(value: int):
	text = str(value)
