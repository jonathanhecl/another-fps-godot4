extends GPUParticles3D

func _process(delta):
	if not emitting:
		await get_tree().create_timer(1.0).timeout
		queue_free()
