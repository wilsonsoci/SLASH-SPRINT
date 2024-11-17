extends ParallaxBackground

func _physics_process(delta: float) -> void:
	scroll_base_offset -= Vector2(60, 0) * delta
