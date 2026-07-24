extends Node3D
class_name Ingredient


@export var data: IngredientData

@export var temp: MeshInstance3D
@export var temp_2: MeshInstance3D
var label_offset: Vector3
@export var temp_label: Label3D #delete all temp and maybe the gradient, that may go into data

const COOK_COLOURS: Gradient = preload("uid://88d3j1g3o83w")

signal destroy_me(me)

enum side {TOP, BOTTOM}

var cook_level: float = 0
var side_a_cook_level: float = 0
var side_b_cook_level: float = 0
var current_side: side = side.TOP

var cook_type: IngredientData.COOK
var doneness_type: IngredientData.DONENESS
var prep_type: IngredientData.PREP

func cook(amount: float, even_cook: bool) -> void:
	if even_cook:
		side_a_cook_level += amount/2
		side_b_cook_level += amount/2
	elif current_side == side.TOP:
		side_a_cook_level += amount
		side_b_cook_level += amount * 0.61
	else:
		side_a_cook_level += amount * 0.61
		side_b_cook_level += amount
	
	cook_level = side_a_cook_level + side_b_cook_level
	print("Cook Level = ", str(cook_level).pad_decimals(2))
	if _is_evenly_cooked():
		_set_doneness()
	else:
		if cook_level < data.doneness_intervals[data.doneness_intervals.size()-1]:
			doneness_type = data.DONENESS.RAW
		else:
			doneness_type = data.DONENESS.BURNT 

func _ready() -> void:
	label_offset = temp_label.global_position
	pass

func _process(_delta: float) -> void:
	temp_label.global_position = global_position + label_offset
	temp_label.text = data.DONENESS.keys()[doneness_type]
	
	#delete all this
	var max_cook_time = data.doneness_intervals[data.doneness_intervals.size()-1]
	var v = remap(side_a_cook_level, 0,max_cook_time/2, 0,1)
	var v2 = remap(side_b_cook_level,0,max_cook_time/2, 0,1)
	temp.mesh.surface_get_material(0).albedo_color = COOK_COLOURS.sample(v)
	temp_2.mesh.surface_get_material(0).albedo_color = COOK_COLOURS.sample(v2)

func physically_move(new_parent: Node3D, Offset: Vector3 = Vector3.ZERO) -> void:
	reparent(new_parent)
	global_position = new_parent.global_position + Offset

func _is_evenly_cooked() -> bool:
	var n : float
	var d : float
	if side_a_cook_level < side_b_cook_level:
		n = side_a_cook_level
		d = side_b_cook_level
	else:
		n = side_b_cook_level
		d = side_a_cook_level
	
	var evenness: float = n/d
	print(str(n).pad_decimals(2)," : ",str(d).pad_decimals(2), " = ", str(evenness * 100).pad_decimals(2), "%")
	if evenness <= 0.6:
		return false
	else:
		return true

func _set_doneness() -> void:
	var iterations: int = data.doneness_intervals.size()
	for i in range(iterations-1,-1,-1):
		if cook_level < data.doneness_intervals[i]:
			doneness_type = data.doneness[i]
		else:
			break
	
	if cook_level > data.doneness_intervals[iterations-1]:
		doneness_type = data.DONENESS.BURNT

func flip_side() -> void:
	current_side = (current_side + 1) % side.size() as side
