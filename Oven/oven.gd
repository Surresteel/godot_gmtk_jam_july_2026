#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Oven
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# MESHES:
@onready var _mesh_dial: MeshInstance3D = $Oven/Dial
@onready var _mesh_door: MeshInstance3D = $Oven/Door
var start_positions: Dictionary[Node3D, Vector3]

# INTERACTABLES:
@onready var _int_dial: Interactable = $InterDial
@onready var _int_door: Interactable = $Oven/Door/InterDoor
var is_listening: bool = false

# STATE:
const DOOR_ANG_LIMIT: float = deg_to_rad(90.0)
var is_opened: bool = false

# ANIMATION AND SOUND:
const DIAL_ROT_MAX: float = deg_to_rad(135.0)
const DIAL_ROT_SCALE: float = 0.01
@onready var light: AreaLight3D = $Light
@onready var clicker: AudioStreamPlayer3D = $Clicker
@onready var hum: AudioStreamPlayer3D = $Hum
var _dial_rot_amount: float = 0.0
var _door_twn: Tween = null
var _hum_twn: Tween = null

# HEATING:
const HEAT_MAX: float = 600.0
@onready var _heat_pos: Vector3 = $HeatPos.position
var _food_item: Node3D = null
var _heat_scale: float = 0.0

# INTERFACE:



#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	_int_door.pressed.connect(_toggle_door)
	_int_dial.pressed.connect(func(): is_listening = true)
	_int_dial.released.connect(func(): is_listening = false)
	light.visible = false
	hum.volume_db = -80.0
	return

func _process(_delta: float) -> void:
	_mesh_dial.rotation.z = _dial_rot_amount
	if not _food_item:
		return
	# Do food cooking stuff here vv:
	
	# Do food cooking stuff here ^^:
	return

func _unhandled_input(event: InputEvent) -> void:
	if not is_listening:
		return
	
	if event is InputEventMouseMotion:
		_dial_rot_amount += event.relative.x * DIAL_ROT_SCALE
		_dial_rot_amount = clampf(_dial_rot_amount, 0.0, DIAL_ROT_MAX)
		_heat_scale = _dial_rot_amount / DIAL_ROT_MAX
		if _heat_scale > 0.01:
			light.visible = true
			if not hum.playing:
				if _hum_twn and _hum_twn.is_valid():
					_hum_twn.kill()
				_hum_twn = create_tween()
				var vol: float = -24 if is_opened else -32
				_hum_twn.tween_property(hum, "volume_db", vol, 0.5)
				hum.play()
		else:
			light.visible = false
			if hum.playing:
				if _hum_twn and _hum_twn.is_valid():
					_hum_twn.kill()
				_hum_twn = create_tween()
				_hum_twn.tween_property(hum, "volume_db", -80.0, 0.5)
				await get_tree().create_timer(0.5).timeout
				hum.stop()
	return


#===============================================================================
#	ANIMATIONS AND SOUND:
#===============================================================================
# Opens and closes the door:
func _toggle_door() -> void:
	if _door_twn and _door_twn.is_valid():
		_door_twn.kill()
	_door_twn = create_tween()
	var rot: float = 0.0 if is_opened else -DOOR_ANG_LIMIT
	is_opened = !is_opened
	print(rot)
	_door_twn.set_ease(Tween.EASE_OUT)
	_door_twn.set_trans(Tween.TRANS_QUAD)
	_door_twn.tween_property(_mesh_door, "rotation:x", rot, 0.5)
	
	if _hum_twn and _hum_twn.is_valid():
		_hum_twn.kill()
	_hum_twn = create_tween()
	if is_opened:
		_hum_twn.tween_property(hum, "volume_db", -24.0, 0.5)
	else:
		_hum_twn.tween_property(hum, "volume_db", -32.0, 0.5)
	return

#===============================================================================
#	OPERATIONS:
#===============================================================================
## Adds a food item to the microwave:
func add_food(obj: Node3D) -> void:
	if not obj:
		print("Can't add a null object to microwave.")
		return
	if _food_item:
		print("Microwave already has a food item.")
		return
	
	_food_item = obj
	obj.reparent(self)
	obj.position = _heat_pos
	return

## Removes a food item from the microwave:
func remove_food() -> Node3D:
	if not _food_item:
		print("Cannot remove food from microwave; it has none.")
		return
	var par: Node = self.get_parent()
	assert(par)
	_food_item.reparent(par)
	return


#===============================================================================
#	EOF:
#===============================================================================
