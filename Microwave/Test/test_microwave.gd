extends Node3D

const INT_COLLIDER: int = 1 << 2

@onready var mwave: Microwave = $mwave
@onready var food: Node3D = $Food
@onready var cam_anchor: Node3D = $CamAnchor
var start_pos := Vector3.ZERO
@onready var camera_3d: Camera3D = $CamAnchor/Camera3D
var held_inter: Interactable = null


func _ready() -> void:
	mwave.test()
	mwave.add_food(food)
	start_pos = cam_anchor.global_position
	return

func _process(_delta: float) -> void:
	#var right: Vector3 = cam_anchor.global_basis.x
	#cam_anchor.global_position = start_pos + (right * sin(float(Time.get_ticks_msec()) / 1000.0))
	#camera_3d.look_at(Vector3.ZERO)
	return

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	event = event as InputEventMouseButton
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cast_mouse_ray()
	if not held_inter:
		return
	if event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		held_inter.deactivate()
		held_inter = null
	return

func _cast_mouse_ray() -> void:
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
	
	interact.activate()
	if not interact.hold:
		interact.deactivate()
	else:
		held_inter = interact
	
	return
