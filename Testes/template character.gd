extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const INT_ENV: int = 1 << 0
const INT_COLLIDER: int = 1 << 2


@export var hand: Ingredient #holds ingredients and maybe also appliances and timers
@export var hand_pivot: Node3D

@onready var camera: Camera3D = $Camera3D
@onready var crosshair: Crosshair = $UI/Crosshair
@onready var ticket_pos: Node3D = $Camera3D/TicketPos
var ticket: Ticket = null

var camera_lock: bool = false

@export var sensitivity: float = 0.2
var held_inter: Interactable = null

signal primary_click(player: Player)
signal secondary_click(player: Player)

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
	#if event is InputEventMouseButton:
	
	if event is InputEventMouse:
		
		var interactable = _cast_mouse_ray()
		
		if interactable:
			crosshair.queue_redraw()
			crosshair.color = Color.GREEN
		else:
			crosshair.queue_redraw()
			crosshair.color = Color.WHITE
		
		if event.is_action_pressed("left_click"):
			if ticket:
				putdown_ticket()
			elif interactable != null:
				signal_check(primary_click,interactable.activate)
				primary_click.emit(self)
				if interactable.hold:
					held_inter = interactable
			elif hand:
				putdown_ingredient()
	
		if event.is_action_pressed("right_click"):
			if interactable != null:
				signal_check(secondary_click,interactable.deactivate)
				secondary_click.emit(self)
	
		if held_inter:
			if event.is_action_released("left_click"):
				held_inter.deactivate(self)
				held_inter = null
	
	if event is InputEventMouseMotion and not held_inter and not camera_lock:
		var dir = event.screen_relative
		if dir:
			rotation_degrees.y += dir.x * -sensitivity
			camera.rotation_degrees.x += dir.y * -sensitivity
			if camera.rotation_degrees.x >= 90:
				camera.rotation_degrees.x = 90
			elif camera.rotation_degrees.x <= -90:
				camera.rotation_degrees.x = -90
				
	if event.is_action_pressed("crouch"):
		
		crouch(-0.25)
		
	elif event.is_action_released("crouch"):
		
		crouch(0.53)
		
	if event.is_action_pressed("zoom"):
		
		zoom(40.0)
		
	if event.is_action_released("zoom"):
		
		zoom(75.0)
		
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

func _get_look_point() -> Dictionary:
	var vp: Viewport = get_viewport()
	var cam: Camera3D = vp.get_camera_3d()
	if not cam:
		return Dictionary()
	
	var m_pos: Vector2 = vp.get_mouse_position()
	var start: Vector3 = cam.project_ray_origin(m_pos)
	var end: Vector3 = start + cam.project_ray_normal(m_pos) * 1.5
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.collision_mask = INT_ENV
	return space_state.intersect_ray(query)


func give_ingredient() -> Ingredient:
	var give: Ingredient = hand
	hand = null
	return give

func take_ingredient(ingredient: Ingredient) -> bool:
	if hand == null and ingredient != null:
		hand = ingredient
		ingredient.physically_move(hand_pivot)
		return true
	return false

func signal_check(action: Signal, callable: Callable) -> void:
	#print(action.get_connections())
	if !action.is_connected(callable):
		if action.has_connections():
			action.disconnect(action.get_connections().get(0)["callable"])#should only ever be connected to one thing
		action.connect(callable)

func lock_camera(state: bool) -> void:
	camera_lock = state
	
func crouch(crouch_amount: float):
	
	var crouch_tween : Tween = create_tween()
	
	crouch_tween.tween_property(camera, "position", Vector3(0,crouch_amount,0), 0.3)
	
func zoom(zoom_amount: float):
	
	var zoom_tween : Tween = create_tween()
	
	zoom_tween.tween_property(camera, "fov", zoom_amount, 0.4).\
	set_trans(Tween.TRANS_CUBIC)


#===============================================================================
#	PICK UP/DOWN STUFF:
#===============================================================================
func pickup_ticket(t: Ticket) -> void:
	if ticket or hand:
		return
	t.reparent(ticket_pos)
	t.position = Vector3.ZERO
	t.basis = ticket_pos.basis
	ticket = t
	return

func putdown_ticket() -> void:
	if not ticket:
		return
	
	var result: Dictionary = _get_look_point()
	if not result:
		return
	ticket.reparent(result["collider"])
	ticket.global_position = result["position"] + result["normal"] * 0.005
	var b := Basis.looking_at(result["normal"], ticket_pos.global_basis.y)
	ticket.global_basis = b
	ticket = null
	return


func putdown_ingredient() -> void:
	if not hand:
		return
	var result: Dictionary = _get_look_point()
	if not result:
		return
	if result["normal"].dot(Vector3.UP) < 0.95:
		return
	hand.reparent(result["collider"])
	hand.global_position = result["position"] + result["normal"] * 0.005
	#var b := Basis.looking_at(result["normal"], hand_pivot.global_basis.y)
	var b := Basis.looking_at(Vector3.FORWARD, Vector3.UP).scaled(hand.scale)
	hand.global_basis = b
	hand.put_down()
	hand = null
	return


#===============================================================================
#	EOF:
#===============================================================================
