extends ParallaxBackground

func _physics_process(delta: float) -> void:
	if get_parent().GAME_START:
		pass
	else:
		scroll_base_offset -= Vector2(60, 0) * delta
