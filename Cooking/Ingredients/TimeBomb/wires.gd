extends Node3D
class_name Wires

@onready var alarm: Alarm = $"../Alarm"

@onready var red_interact: Interactable = $RedMain/RedCut/RedInteract
@onready var blue_interact: Interactable = $BlueMain/BlueCut/BlueInteract
@onready var green_interact: Interactable = $GreenMain/GreenCut/GreenInteract
@onready var yellow_interact: Interactable = $YellowMain/YellowCut/YellowInteract

@onready var red_cut: MeshInstance3D = $RedMain/RedCut
@onready var blue_cut: MeshInstance3D = $BlueMain/BlueCut
@onready var green_cut: MeshInstance3D = $GreenMain/GreenCut
@onready var yellow_cut: MeshInstance3D = $YellowMain/YellowCut

var wires_cut: Array[bool] = [false,false,false,false]

signal defused()

func _ready() -> void:
	red_interact.pressed.connect(cut_wire.bind(red_cut))
	blue_interact.pressed.connect(cut_wire.bind(blue_cut))
	green_interact.pressed.connect(cut_wire.bind(green_cut))
	yellow_interact.pressed.connect(cut_wire.bind(yellow_cut))
	
	enable(false)


func cut_wire(_player: Player, wire: MeshInstance3D) -> void:
	match wire:
		red_cut:
			if alarm_check("4") and not wires_cut[0]:
				wire.rotation_degrees += Vector3(0,5,0)
				red_interact.toggle(false)
				wires_cut[0] = true
		blue_cut:
			if alarm_check("1") and not wires_cut[1]:
				wire.rotation_degrees += Vector3(0,-5,0)
				blue_interact.toggle(false)
				wires_cut[1] = true
		green_cut:
			if alarm_check("3") and not wires_cut[2]:
				wire.rotation_degrees += Vector3(0,8,0)
				green_interact.toggle(false)
				wires_cut[2] = true
		yellow_cut:
			if alarm_check("2") and not wires_cut[3]:
				wire.rotation_degrees += Vector3(0,-2,0)
				yellow_interact.toggle(false)
				wires_cut[3] = true
	if wires_cut.all(func truthers(wire_is_cut): return wire_is_cut):
		defused.emit()

func enable(value: bool = true) -> void:
	red_interact.toggle(value)
	blue_interact.toggle(value)
	green_interact.toggle(value)
	yellow_interact.toggle(value)

func alarm_check(time: String) -> bool:
	var time_left: String = alarm.get_time_str()
	if time_left.find(time) != -1:
		return true
	else:
		return false
		
