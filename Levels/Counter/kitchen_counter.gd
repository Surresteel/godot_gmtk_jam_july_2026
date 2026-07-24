#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name KitchenCounter
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# DOORS:
@onready var handle_l: Interactable = $Counter/AnimBodyL/DoorL/HandleL
@onready var handle_r: Interactable = $Counter/AnimBodyR/DoorR/HandleR
@onready var door_l: AnimatableBody3D = $Counter/AnimBodyL
@onready var door_r: AnimatableBody3D = $Counter/AnimBodyR
var is_opened: Dictionary[AnimatableBody3D, bool]
var door_angles: Dictionary[AnimatableBody3D, float]


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	is_opened[door_l] = false
	is_opened[door_r] = false
	door_angles[door_l] = -deg_to_rad(120.0)
	door_angles[door_r] = deg_to_rad(120.0)
	handle_l.pressed.connect(toggle_door.bind(door_l))
	handle_r.pressed.connect(toggle_door.bind(door_r))
	return


#===============================================================================
#	ANIMATIONS:
#===============================================================================
func toggle_door(_p: Player, d: AnimatableBody3D) -> void:
	var value: bool = !is_opened[d]
	var rot: float = 0.0 if !value else door_angles[d]
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(d, "rotation:y", rot, 0.5)
	is_opened[d] = value
	return


#===============================================================================
#	EOF:
#===============================================================================
