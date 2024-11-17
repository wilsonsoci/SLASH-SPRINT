extends CPUParticles2D

var elapsed_time : float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	
	if elapsed_time > 10:
		queue_free()
