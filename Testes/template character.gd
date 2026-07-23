extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@onready var camera: Camera3D = $Camera3D

@export var sensitivity: float = 0.2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		direction = velocity.move_toward(direction * SPEED, 0.5)
	else:
		direction = velocity.move_toward(Vector3.ZERO, 0.5)
	
	velocity = Vector3(direction.x, velocity.y, direction.z)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var dir = event.screen_relative
		if dir:
			rotation_degrees.y += dir.x * -sensitivity
			self.rotation_degrees.x += dir.y * -sensitivity
			if self.rotation_degrees.x >= 60:
				self.rotation_degrees.x = 60
			elif self.rotation_degrees.x <= -90:
				self.rotation_degrees.x = -90
	
