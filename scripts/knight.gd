extends CharacterBody2D

@export var JUMP_VELOCITY = -900.0
@onready var anim = $AnimatedSprite2D
@onready var sprint = $Sprint
@onready var slide = $Slide
var GRAVITY = 1800.0
const NORMAL_GRAVITY = 1800.0

var is_slashing = false
var slash_timer = 0.0
const SLASH_DURATION = 0.4

var slash_count = 0  # Contador para slashes no ar
const MAX_AIR_SLASHES = 2  # Limite de slashes no ar
@onready var slash = $"Slash/CollisionShape2D"
@onready var aerial_slash = $"AerialSlash/CollisionShape2D"

var is_sliding = false
var slide_sound_played = false

var current_state = "idle"
var transitioning = false

func _ready() -> void:
	# Configurar para desativar os hitboxes no início
	slash.visible = false
	slash.disabled = true
	aerial_slash.visible = false
	aerial_slash.disabled = true

func _activate_hitbox(state: bool) -> void:
	# Liga ou desliga os hitboxes de ataque
	if current_state == "slashing":
		slash.visible = state
		slash.disabled = not state
	elif current_state == "slashing_on_air":
		aerial_slash.visible = state
		aerial_slash.disabled = not state

func _physics_process(delta: float) -> void:
	if not get_parent().GAME_START:
		current_state = "idle"
		anim.play("idle")
		$RunParticles.emitting = false
	else:
		_handle_animation()
		_handle_movement(delta)

func _handle_movement(delta):
	velocity.y += GRAVITY * delta

	if is_slashing:
		slash_timer -= delta

		# Verifique o progresso do temporizador para ativar ou desativar o hitbox
		if slash_timer <= SLASH_DURATION * 0.75 and slash_timer > SLASH_DURATION * 0.3: 
			# Ativar hitbox no meio do ataque (ajuste os valores para o momento certo)
			_activate_hitbox(true)
		else:
			_activate_hitbox(false)

	if is_on_floor():
		$FallParticles.emitting = false
		$RunParticles.emitting = true
		slash_count = 0  # Reseta o contador de slashes no ar ao tocar o chão
		aerial_slash.visible = false
		aerial_slash.disabled = true
		GRAVITY = NORMAL_GRAVITY

		if Input.is_action_pressed("slide"):
			is_sliding = true
			sprint.hide()
			sprint.disabled = true
			slide.show()
			slide.disabled = false
			current_state = "sliding"
			anim.play("slide")
			if not slide_sound_played:
				$SlideSFX.play()
				slide_sound_played = true
			return
		else:
			is_sliding = false
			sprint.show()
			sprint.disabled = false
			slide.hide()
			slide.disabled = true
			slide_sound_played = false

		if current_state == "slashing":
			if is_slashing:
				slash_timer -= delta
			if slash_timer <= 0:
				is_slashing = false
			else:
				anim.play("slash")
				move_and_slide()
				return
		elif current_state == "slashing_on_air":
			if is_slashing:
				slash_timer -= delta
			if slash_timer <= 0:
				is_slashing = false
			else:
				anim.play("slash_on_air")
				move_and_slide()
				return

		if Input.is_action_just_pressed("slash"):
			is_slashing = true
			slash.visible = true
			slash.disabled = false
			slash_timer = SLASH_DURATION
			current_state = "slashing"
			$SlashSFX.play()
		elif Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			$JumpParticles.restart()
			$JumpSFX.play()
		else:
			sprint.visible = true
			slash.visible = false
			slash.disabled = true
			aerial_slash.visible = false
			aerial_slash.disabled = true
			$Sprint.show()
			current_state = "sprint"
			anim.play("sprint")
	else:
		$RunParticles.emitting = false
		if Input.is_action_just_pressed("slash") and slash_count < MAX_AIR_SLASHES:
			is_slashing = true
			aerial_slash.visible = true
			aerial_slash.disabled = false
			slash_timer = SLASH_DURATION
			current_state = "slashing_on_air"
			slash_count += 1  # Incrementa o contador de slashes no ar
			$SlashSFX.play()
		if current_state == "slashing_on_air":
			if is_slashing:
				anim.play("slash_on_air")
				slash_timer -= delta
				if slash_timer <= 0:  # Quando o tempo do slash termina
					is_slashing = false
					aerial_slash.visible = false
					aerial_slash.disabled = true
					current_state = "falling"  # Muda para falling
			else:
				current_state = "falling"
				anim.play("falling")  # Garante a animação correta
		else:
			if velocity.y > 0 and current_state == "jumping":
				current_state = "falling"
				transitioning = true
				anim.play("falling_transition")
			elif velocity.y < 0:
				current_state = "jumping"
				anim.play("jumping")
			elif velocity.y > 0:
				current_state = "falling"
				anim.play("falling")

			if Input.is_action_just_pressed("slide"):
				GRAVITY *= 8
				$FallParticles.emitting = true

	move_and_slide()

func _handle_animation():
	if transitioning:
		if not anim.is_playing():
			transitioning = false
			if current_state == "sliding":
				anim.play("slide")
			elif current_state == "slashing_on_air":
				anim.play("slash_on_air")
			elif current_state == "falling":
				anim.play("falling")
				return
