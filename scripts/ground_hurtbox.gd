
extends Area2D

var BLOOD = preload("res://prefabs/wood_particles.tscn")

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))  # Conecta a detecção de hitbox

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null:
		get_parent().to_remove = true  # Marca o obstáculo para remoção
		var blood = BLOOD.instantiate()
		blood.position = Vector2i(get_parent().position.x, get_parent().position.y - 20)
		get_tree().get_current_scene().add_child(blood)
		blood.restart()
