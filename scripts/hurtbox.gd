class_name HurtBox
extends Area2D

var BLOOD = preload("res://prefabs/blood_particles.tscn")

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))  # Conecta a detecção de hitbox

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null:
		print("Slashed")
		get_parent().to_remove = true  # Marca o obstáculo para remoção
		var blood = BLOOD.instantiate()
		blood.position = get_parent().position
		get_tree().get_current_scene().add_child(blood)
		blood.restart()
