class_name HitBox
extends Area2D

@export var DAMAGE : int = 1 : set = _set_damage, get = _get_damage

func _set_damage(value: int):
	DAMAGE = value

func _get_damage() -> int:
	return DAMAGE
