extends CharacterBody3D
class_name Player


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const INT_COLLIDER: int = 1 << 2


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

func _unhandled_input(event: InputEvent) -> void:
	#left click
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			_cast_mouse_ray(true)
		elif event.is_action_pressed("right_click"):
			_cast_mouse_ray(false)
	#mouse movement
	if event is InputEventMouseMotion:
		var dir = event.screen_relative
		if dir:
			rotation_degrees.y += dir.x * -sensitivity
			self.rotation_degrees.x += dir.y * -sensitivity
			if self.rotation_degrees.x >= 90:
				self.rotation_degrees.x = 90
			elif self.rotation_degrees.x <= -90:
				self.rotation_degrees.x = -90

func _cast_mouse_ray(activate: bool) -> void:
	var vp: Viewport = get_viewport()
	var cam: Camera3D = vp.get_camera_3d()
	if not cam:
		return
	
	var m_pos: Vector2 = vp.get_mouse_position()
	var start: Vector3 = cam.project_ray_origin(m_pos)
	var end: Vector3 = start + cam.project_ray_normal(m_pos) * 1_000.0
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = INT_COLLIDER
	var result = space_state.intersect_ray(query)
	
	if not result:
		return
	
	var interact: Interactable = result["collider"]
	if not interact:
		return
	
	if activate:
		interact.activate()
	else:
		interact.deactivate()
	
	return
