extends CanvasLayer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("start"):
		get_tree().paused = false
		get_parent()._new_game()
