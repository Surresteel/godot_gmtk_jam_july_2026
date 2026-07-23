extends Node3D
class_name Ingredient

@export var temp: MeshInstance3D
@export var temp_2: MeshInstance3D
const COOK_COLOURS: Gradient = preload("uid://88d3j1g3o83w")

var cook_level: float = 0
var side_a_cook_level: float = 0
var side_b_cook_level: float = 0

func cook(amount: float,side_a: bool, side_b: bool) -> void:
	if side_a:
		side_a_cook_level += amount
	if side_b:
		side_b_cook_level += amount
	cook_level = side_a_cook_level + side_b_cook_level
	print(cook_level)

func _process(_delta: float) -> void:
	
	var v = remap(side_a_cook_level,0,10, 0,1)
	var v2 = remap(side_b_cook_level,0,10, 0,1)
	temp.mesh.surface_get_material(0).albedo_color = COOK_COLOURS.sample(v)
	temp_2.mesh.surface_get_material(0).albedo_color = COOK_COLOURS.sample(v2)


func physically_move(new_parent: Node3D, Offset: Vector3 = Vector3.ZERO) -> void:
	reparent(new_parent)
	global_position = new_parent.global_position + Offset
