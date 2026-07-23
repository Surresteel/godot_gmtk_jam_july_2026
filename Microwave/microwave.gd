#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Microwave
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# MESHES:
@onready var _mesh_btn_s: MeshInstance3D = $Body/BtnShort
@onready var _mesh_btn_m: MeshInstance3D = $Body/BtnMed
@onready var _mesh_btn_l: MeshInstance3D = $Body/BtnLong
@onready var _mesh_btn_o: MeshInstance3D = $Body/BtnOpen
@onready var _mesh_door: MeshInstance3D = $Body/Door
var start_positions: Dictionary[Node3D, Vector3]

# INTERACTABLES:
@onready var int_btn_s: Interactable = $IntBtnS
@onready var int_btn_m: Interactable = $IntBtnM
@onready var int_btn_l: Interactable = $IntBtnL
@onready var int_btn_o: Interactable = $IntBtnO

# ALARM:
@onready var alarm: Alarm = $Alarm
@onready var timer: Label3D = $Body/Door/Timer

# STATE:
const DOOR_ANG_LIMIT: float = deg_to_rad(120.0)
var is_opened: bool = false

# ANIMATION AND SOUND:
@onready var light: AreaLight3D = $Light
@onready var beeper: AudioStreamPlayer3D = $Beeper
@onready var hum: AudioStreamPlayer3D = $Hum
var _btn_move_amount: float = 0.005
var _door_twn: Tween = null

# HEATING:
@onready var _heat_pos: Vector3 = $HeatPos.position
var _food_item: Node3D = null


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	int_btn_s.pressed.connect(_handle_btn.bind(_mesh_btn_s, 10.0))
	int_btn_m.pressed.connect(_handle_btn.bind(_mesh_btn_m, 30.0))
	int_btn_l.pressed.connect(_handle_btn.bind(_mesh_btn_l, 60.0))
	int_btn_o.pressed.connect(_toggle_door.bind(_mesh_btn_o))
	
	start_positions[_mesh_btn_s] = _mesh_btn_s.global_position
	start_positions[_mesh_btn_m] = _mesh_btn_m.global_position
	start_positions[_mesh_btn_l] = _mesh_btn_l.global_position
	start_positions[_mesh_btn_o] = _mesh_btn_o.global_position
	
	alarm.timeout.connect(_stop_op)
	light.visible = false
	return

func _process(_delta: float) -> void:
	timer.text = alarm.get_time_str()
	if alarm.is_active:
		timer.modulate = Color.RED
	else:
		timer.modulate = Color.WHITE
	if _food_item and alarm.is_set:
		_food_item.rotate(Vector3.UP, 0.01)
	return


#===============================================================================
#	BUTTON FUNCTIONS:
#===============================================================================
# Handles button time logic.
func _handle_btn(m_inst: MeshInstance3D, t: float) -> void:
	if alarm and not is_opened:
		alarm.add_time(t)
		if not hum.playing:
			hum.play()
			light.visible = true
	if m_inst:
		_button_anim(m_inst)
	return


#===============================================================================
#	ANIMATIONS AND SOUND:
#===============================================================================
# Animates the buttons:
func _button_anim(m_inst: MeshInstance3D) -> void:
	if not m_inst:
		return
	beeper.play()
	var start_position = start_positions[m_inst]
	var twn: Tween = create_tween()
	var fwd: Vector3 = -m_inst.global_basis.z
	var tgt: Vector3 = start_position + (fwd * _btn_move_amount)
	twn.tween_property(m_inst, "global_position", tgt, 0.1)
	twn.tween_property(m_inst, "global_position", start_position, 0.1)
	return

# Opens and closes the door:
func _toggle_door(m_inst: MeshInstance3D) -> void:
	if m_inst:
		_button_anim(m_inst)
	if _door_twn and _door_twn.is_valid():
		_door_twn.kill()
	_door_twn = create_tween()
	var rot: float = 0.0 if is_opened else -DOOR_ANG_LIMIT
	is_opened = !is_opened
	_door_twn.set_ease(Tween.EASE_OUT)
	_door_twn.set_trans(Tween.TRANS_QUAD)
	_door_twn.tween_property(_mesh_door, "rotation:y", rot, 0.5)
	alarm.reset()
	hum.stop()
	light.visible = false
	return

func _stop_op() -> void:
	hum.stop()
	light.visible = false
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
#	TESTING:
#===============================================================================
func test() -> void:
	#_toggle_door(_mesh_btn_o)
	return


#===============================================================================
#	EOF:
#===============================================================================
