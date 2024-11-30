extends Node2D

# Knight Variables
const KNIGHT_START_POS := Vector2i(325, 360)
const CAM_START_POS := Vector2i(760, 360)
var DIFFICULTY
var MAX_DIFFICULTY : int = 2
var LAST_OBSTACLE

# Obstacles Variables
var OBSTACLES : Array
var ROCK = preload("res://prefabs/obstacle_1.tscn")
var SNAIL = preload("res://prefabs/obstacle_2.tscn")
var FLY_EYE = preload("res://prefabs/obstacle_3.tscn")
var GHOST = preload("res://prefabs/obstacle_4.tscn")
var BOX = preload("res://prefabs/obstacle_6.tscn")
var OBSTACLE_TYPES := [ROCK, SNAIL, BOX]
var FLY_TYPES := [FLY_EYE, GHOST]
var FLY_HEIGHT := [210, 440]
var obstacle_timer : float = 0.0
var OBSTACLE_INTERVAL : float = 1.5  # Tempo mínimo em segundos entre obstáculos

@export var SPEED : float
const START_SPEED : float = 10.0 * 60
const MAX_SPEED : int = 25 * 60
const SPEED_MODIFIER : int = 5000
var elapsed_time : float = 0.0
var SCREEN_SIZE : Vector2i
var GROUND_HEIGHT : int

var SCORE : int
const SCORE_MODIFIER : int = 10
var HIGHSCORE : int
var START_DURATION : int = 0
var START_BLINK : bool = true

var GAME_START : bool
var game_over_triggered : bool = false

func _ready() -> void:
	SCREEN_SIZE = get_window().size
	var ground_shape = $GroundExample.get_node("CollisionShape2D").shape
	GROUND_HEIGHT = ground_shape.size.y
	
	_new_game()

func _new_game() -> void:
	SCORE = 0
	DIFFICULTY = 0
	elapsed_time = 0.0
	GAME_START = false
	game_over_triggered = false
	$HUD.get_node("Start").show()
	
	for OBS in OBSTACLES:
		OBS.queue_free()
	OBSTACLES.clear()
	
	$Knight.position = KNIGHT_START_POS
	$Knight.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$TileMap.position = Vector2i(0, 35)
	$TileMap2.position = Vector2i(0, 35)
	
	$HUD.get_node("Start").show()
	$Camera2D.get_node("AudioStreamPlayer2D").stop()
	$GameOver.hide()

func _process(delta: float) -> void:
	if GAME_START:
		elapsed_time += delta
		
		_update_speed(delta)
		_adjust_difficulty()
		_generate_obstacles(delta)

		# Multiplica os movimentos por delta
		$Knight.position.x += SPEED * delta
		$Camera2D.position.x += SPEED * delta

		# Verificação e ajuste de posição dos mapas
		if $Camera2D.position.x - $TileMap.position.x > SCREEN_SIZE.x * 1.5:
			$TileMap.position.x += (SCREEN_SIZE.x)
			$TileMap2.position.x += (SCREEN_SIZE.x)

		# Remove obstáculos fora da tela
		for OBS in OBSTACLES:
			if OBS.to_remove:  # Verifica se o obstáculo está marcado para remoção
				_remove_obstacle(OBS)
				SCORE += 1000
			elif OBS.position.x < ($Camera2D.position.x - SCREEN_SIZE.x):
				_remove_obstacle(OBS)

		SCORE += SPEED * delta  # Incrementa o score com base no delta
		$HUD.get_node("Start").hide()
		_show_score()

	else:
		START_DURATION += 2
		if START_DURATION >= 60:
			START_DURATION = 0
			START_BLINK = !START_BLINK

			if START_BLINK:
				$HUD.get_node("Start").visible = true
			else:
				$HUD.get_node("Start").visible = false

		if Input.is_action_just_pressed("start"):
			GAME_START = true
			$Camera2D.get_node("AudioStreamPlayer2D").play()

# Atualização apenas quando a velocidade realmente muda
func _update_speed(delta):
	var new_speed = START_SPEED + (elapsed_time * 10)
	SPEED = clamp(new_speed, START_SPEED, MAX_SPEED)

func _generate_obstacles(delta: float) -> void:
	# Incrementa o temporizador com base no delta
	obstacle_timer += delta
	
	# Gera novos obstáculos apenas se o tempo mínimo foi atingido
	if obstacle_timer >= OBSTACLE_INTERVAL:
		obstacle_timer = 0.0  # Reinicia o temporizador
		
		if OBSTACLES.is_empty() or LAST_OBSTACLE.position.x < $Camera2D.position.x + SCREEN_SIZE.x / 2:
			var TYPES = OBSTACLE_TYPES[randi() % OBSTACLE_TYPES.size()]
			var FTYPES = FLY_TYPES[randi() % FLY_TYPES.size()]
			var OBS
			var MAX = DIFFICULTY + 1
			
			var num_obstacles = 1 if TYPES == BOX else randi() % MAX + 1
			
			
			for i in range(num_obstacles):
				OBS = TYPES.instantiate()
				var OBSTACLE_X = $Camera2D.position.x + SCREEN_SIZE.x + (i * 130)
				var OBSTACLE_Y
				
				if TYPES == BOX:
					var OBSTACLE_HEIGHT = OBS.get_node("CollisionShape2D").shape.size.y
					var OBSTACLE_SCALE = OBS.get_node("CollisionShape2D").scale
					OBSTACLE_Y = SCREEN_SIZE.y - GROUND_HEIGHT - (OBSTACLE_HEIGHT * OBSTACLE_SCALE.y / 2) + 100
					LAST_OBSTACLE = OBS
					_add_obstacle(OBS, OBSTACLE_X, OBSTACLE_Y)
					break
				else:
					var OBSTACLE_HEIGHT = OBS.get_node("CollisionShape2D").shape.size.y
					var OBSTACLE_SCALE = OBS.get_node("CollisionShape2D").scale
					OBSTACLE_Y = SCREEN_SIZE.y - GROUND_HEIGHT - (OBSTACLE_HEIGHT * OBSTACLE_SCALE.y / 2) + 100
					LAST_OBSTACLE = OBS
					_add_obstacle(OBS, OBSTACLE_X, OBSTACLE_Y)
			
			if DIFFICULTY == MAX_DIFFICULTY:
				if (randi() % 2) == 0:
					OBS = FTYPES.instantiate()
					var OBSTACLE_X : int = $Camera2D.position.x + SCREEN_SIZE.x + 100
					var OBSTACLE_Y : int = FLY_HEIGHT[randi() % FLY_HEIGHT.size()]
					_add_obstacle(OBS, OBSTACLE_X, OBSTACLE_Y)
					OBSTACLE_INTERVAL = randi_range(1.3, 1.5)

func _add_obstacle(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.disable_mode = false  # Ativa o obstáculo ao adicioná-lo
	obs.body_entered.connect(_hit_obstacle)
	add_child(obs)
	OBSTACLES.append(obs)

func _remove_obstacle(obs):
	obs.queue_free()
	OBSTACLES.erase(obs)

func _hit_obstacle(body):
	if body.name == "Knight":
		var obstacle = self  # Referencia o nó atual onde o corpo entrou
		if not obstacle.has_method("disable_mode") or obstacle.disable_mode == false:
			_game_over()

func _show_score() -> void:
	$HUD.get_node("Score").text = "SCORE: " + str(SCORE / SCORE_MODIFIER)
	
func _check_highscore() -> void:
	if SCORE >= HIGHSCORE:
		HIGHSCORE = SCORE
	$HUD.get_node("Control").get_node("HighScore").text = "HIGH SCORE: " + str(HIGHSCORE / SCORE_MODIFIER)
	
func _adjust_difficulty():
	DIFFICULTY = SCORE / SPEED_MODIFIER
	if DIFFICULTY > MAX_DIFFICULTY:
		DIFFICULTY = MAX_DIFFICULTY

func _game_over():
	if game_over_triggered:
		return
	game_over_triggered = true

	if SCORE > HIGHSCORE:
		$GameOver.get_node("HighScore").show()
		$Camera2D.get_node("NewScore").play()
	else:
		$GameOver.get_node("HighScore").hide()
		$Camera2D.get_node("Dead").play()
	_check_highscore()

	get_tree().paused = true
	GAME_START = false
	$GameOver.show()
