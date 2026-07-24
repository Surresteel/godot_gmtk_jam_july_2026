extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const INT_COLLIDER: int = 1 << 2

var hand: Ingredient #holds ingredients and maybe also appliances and timers

@onready var camera: Camera3D = $Camera3D

@export var sensitivity: float = 0.2
var held_inter: Interactable = null

signal primary_click(player: Player)
signal secondary_click(player: Player)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	hand = $HandPivot/Ingredient #delete this

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
	if event is InputEventMouseButton:
		var interactable = _cast_mouse_ray()
		if event.is_action_pressed("left_click"):
			if interactable != null:
				signal_check(primary_click,interactable.activate)
				primary_click.emit(self)
				if interactable.hold:
					held_inter = interactable
		if event.is_action_pressed("right_click"):
			if interactable != null:
				signal_check(secondary_click,interactable.deactivate)
				secondary_click.emit(self)
		if held_inter:
			if event.is_action_released("left_click"):
				held_inter.deactivate(self)
				held_inter = null
	if event is InputEventMouseMotion and not held_inter:
		var dir = event.screen_relative
		if dir:
			rotation_degrees.y += dir.x * -sensitivity
			camera.rotation_degrees.x += dir.y * -sensitivity
			if camera.rotation_degrees.x >= 90:
				camera.rotation_degrees.x = 90
			elif camera.rotation_degrees.x <= -90:
				camera.rotation_degrees.x = -90

func _cast_mouse_ray() -> Interactable:
	var vp: Viewport = get_viewport()
	var cam: Camera3D = vp.get_camera_3d()
	if not cam:
		return
	
	var m_pos: Vector2 = vp.get_mouse_position()
	var start: Vector3 = cam.project_ray_origin(m_pos)
	var end: Vector3 = start + cam.project_ray_normal(m_pos) * 1.5
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
	
	return interact

func give_ingredient() -> Ingredient:
	var give: Ingredient = hand
	hand = null
	return give

func take_ingredient(ingredient: Ingredient) -> bool:
	if hand == null:
		hand = ingredient
		ingredient.physically_move($HandPivot)
		return true
	return false

func signal_check(action: Signal, callable: Callable) -> void:
	print(action.get_connections())
	if !action.is_connected(callable):
		if action.has_connections():
			action.disconnect(action.get_connections().get(0)["callable"])
		action.connect(callable)
