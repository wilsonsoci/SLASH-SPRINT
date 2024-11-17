extends Area2D

var to_remove = false

func _process(delta: float) -> void:
	$AnimatedSprite2D.play("default")
	position.x -= (get_parent().SPEED / 2) * delta
