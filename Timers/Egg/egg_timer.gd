#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name EggTimer
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# IMPORTS:
@onready var mesh_top: MeshInstance3D = $Bottom/Top
@onready var _int_timer: Interactable = $Interactable
@onready var alarm: Alarm = $Alarm

# TIME KEEPING:
const TIME_MAX: float = 60.0

# INTERACTION:
const ROT_SCALE: float = 0.01
const ROT_MAX: float = deg_to_rad(360)
var is_listening: bool = false
var _rot_amount: float = 0.0


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	_int_timer.pressed.connect(func(_p: Player): is_listening = true;\
			alarm.reset())
	_int_timer.released.connect(func(_p: Player): is_listening = false;\
			alarm.set_time((_rot_amount / ROT_MAX) * TIME_MAX))
	return


func _process(_delta: float) -> void:
	mesh_top.rotation.y = -_rot_amount
	if is_listening:
		return
	_rot_amount = clampf((alarm.get_time() / TIME_MAX) * ROT_MAX, 0.0, ROT_MAX)
	return


func _unhandled_input(event: InputEvent) -> void:
	if not is_listening:
		return
	
	if event is InputEventMouseMotion:
		_rot_amount -= event.relative.x * ROT_SCALE
		_rot_amount = clampf(_rot_amount, 0.0, ROT_MAX)
		#alarm.set_time((_rot_amount / ROT_MAX) * TIME_MAX)
	
	return


#===============================================================================
#	EOF:
#===============================================================================
