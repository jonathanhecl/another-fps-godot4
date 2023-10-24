extends Node3D

@onready var HORN_RAY = $RayCast3D

const SPEED: float = 40.0
const Particle = preload("res://scenes/gpu_particles.tscn")
var instance

func _physics_process(delta):
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	
	if HORN_RAY.is_colliding():
		instance = Particle.instantiate()
		instance.global_position = global_position
		instance.emitting = true
		get_parent().add_child(instance)

func _on_timer_timeout():
	queue_free()
