extends CharacterBody3D

@export var CAMERA: Node3D
@export var HORN_RAY: RayCast3D

const TILT_LOWER: float = -90.0
const TILT_HIGH: float = 90.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const MOUSE_SENS: float = 0.5

var camera_basis: Vector3

const Bullet = preload("res://scenes/bullet.tscn")
const Particle = preload("res://scenes/gpu_particles.tscn")
var instance

var mouse_rotation: float
var mouse_tilt: float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	var mouse_input = (event is InputEventMouseMotion) and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		mouse_rotation = -event.relative.x * MOUSE_SENS
		mouse_tilt = -event.relative.y * MOUSE_SENS

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	update_camera(delta)
	
	if HORN_RAY.is_colliding():
		instance = Particle.instantiate()
		instance.global_position = HORN_RAY.get_collision_point()
		instance.emitting = true
		get_parent().add_child(instance)
		
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	if Input.is_action_pressed("shoot"):
		instance = Bullet.instantiate()
		#instance.global_position = HORN_RAY.global_position
		instance.global_transform = HORN_RAY.global_transform
		get_parent().add_child(instance)

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func update_camera(delta):
	camera_basis.x += mouse_tilt * delta
	camera_basis.x = clamp(camera_basis.x, TILT_LOWER, TILT_HIGH)
	camera_basis.y += mouse_rotation * delta
		
	#CAMERA.transform.basis = Basis.from_euler(camera_basis)
	CAMERA.transform.basis = Basis.from_euler(Vector3(camera_basis.x, 0, 0))
	CAMERA.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(Vector3(0, camera_basis.y, 0))
	
	mouse_rotation = 0.0
	mouse_tilt = 0.0
