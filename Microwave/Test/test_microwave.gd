extends Node3D

const INT_COLLIDER: int = 1 << 2

@onready var mwave: Microwave = $mwave


func _ready() -> void:
	mwave.test()
	return

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cast_mouse_ray()
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
	interact.deactivate()
	
	return
