extends Area2D

func _process(delta: float) -> void:
	$AnimatedSprite2D.play("default")
	position.x -= (get_parent().SPEED / 2) * delta
