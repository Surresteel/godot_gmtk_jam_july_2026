#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name KitchenCorner
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# DOORS:
@onready var handle: Interactable = $Counter/AnimBodyBase/AnimBodyDoor/Handle
@onready var door_inner: AnimatableBody3D = $Counter/AnimBodyBase
@onready var door_outer: AnimatableBody3D = $Counter/AnimBodyBase/AnimBodyDoor
var is_opened: bool = false
var door_angle_inner: Array[float] = [deg_to_rad(0), deg_to_rad(120)]
var door_angle_outer: Array[float] = [deg_to_rad(60), deg_to_rad(160)]


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	handle.pressed.connect(toggle_door)
	return


#===============================================================================
#	ANIMATIONS:
#===============================================================================
func toggle_door(_p: Player) -> void:
	var rot_inner_1: float = door_angle_inner[1]/2
	var rot_outer_1: float = door_angle_outer[1]
	var rot_inner_2: float = door_angle_inner[0] if is_opened \
			else door_angle_inner[1]
	var rot_outer_2: float = deg_to_rad(90) if is_opened \
			else door_angle_outer[0]
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(door_inner, "rotation:y", rot_inner_1, 0.5)
	tween.parallel().tween_property(door_outer, "rotation:y", rot_outer_1, 0.5)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(door_inner, "rotation:y", rot_inner_2, 0.5)
	tween.parallel().tween_property(door_outer, "rotation:y", rot_outer_2, 0.5)
	is_opened = !is_opened
	return

#===============================================================================
#	EOF:
#===============================================================================
