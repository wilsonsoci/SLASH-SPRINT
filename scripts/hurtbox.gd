class_name HurtBox
extends Area2D

func _ready() -> void:
	connect("area_entered", Callable(self, "_on_area_entered"))  # Conecta a detecção de hitbox

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox != null:
		print("Slashed")
		
		get_parent().disable_mode = true  # Marca o obstáculo como desativado

		# Ativa partículas de sangue (se houver)
		get_parent().get_node("BloodParticles").restart()

		# Desativa a colisão do obstáculo (incluindo hurtbox)
		get_parent().get_node("CollisionShape2D").disabled = true

		# Desativa a colisão da própria HurtBox
		$CollisionShape2D.disabled = true

		# Torna os sprites invisíveis
		get_parent().get_node("AnimatedSprite2D").visible = false
		
		print("CollisionShape2D do Obstáculo:", get_parent().get_node("CollisionShape2D").disabled)
		print("CollisionShape2D do HurtBox:", $CollisionShape2D.disabled)
