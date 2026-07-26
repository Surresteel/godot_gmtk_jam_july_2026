extends Node3D
class_name Ingredient


@export var data: IngredientData

@export var meshes: Array[MeshInstance3D]
@export var top_half_mesh: MeshInstance3D
@export var bottom_half_mesh: MeshInstance3D # repalce with shader if can
var current_mesh_index: int = 0

@export var prep_colour: Color = Color.WHITE

@export var prep_dictionary: Dictionary[IngredientData.PREP, MeshInstance3D]

const COOK_COLOURS: Gradient = preload("uid://88d3j1g3o83w")
const ING_SPHERE = preload("uid://diegpaqm2wyqr")

signal destroy_me(me)

var scale_tween: Tween

enum side {TOP, BOTTOM}

var cook_level: float = 0
var side_a_cook_level: float = 0
var side_b_cook_level: float = 0
var current_side: side = side.TOP

var cook_type: IngredientData.COOK
var doneness_type: IngredientData.DONENESS
var prep_type: IngredientData.PREP

# PICKUP STUFF:
@export var inter_pickup: Interactable = null
var is_on_ground: bool = false


func _ready() -> void:
	if inter_pickup:
		inter_pickup.process_mode = Node.PROCESS_MODE_DISABLED
		inter_pickup.pressed.connect(pickup)
	if data.doneness == null:
		data.doneness.append(data.DONENESS.NA)
	_create_detection_area()


func _create_detection_area() -> void:
	var ar := Area3D.new()
	self.add_child(ar)
	ar.collision_layer = 1 << 1
	ar.collision_mask = 0
	ar.monitorable = true
	ar.monitoring = false
	var cs := CollisionShape3D.new()
	ar.add_child(cs)
	cs.shape = ING_SPHERE
	return


func cook(amount: float, even_cook: bool) -> void:
	if even_cook:
		side_a_cook_level += amount/2
		side_b_cook_level += amount/2
	elif current_side == side.TOP:
		side_a_cook_level += amount
		side_b_cook_level += amount * 0.4
	else:
		side_a_cook_level += amount * 0.4
		side_b_cook_level += amount
	
	cook_level = side_a_cook_level + side_b_cook_level
	
	if cook_level > data.doneness_intervals[data.doneness_intervals.size()-1]:
		scale_tween = create_tween()
		scale_tween.tween_property(self, "scale", scale - Vector3.ONE * amount * 0.1 ,0.1)
		if scale <= Vector3.ZERO:
			visible = false
			destroy_me.emit()
			queue_free()
	
	#print("Cook Level = ", str(cook_level).pad_decimals(2))
	if _is_evenly_cooked():
		_set_doneness()
	else:
		if cook_level > data.doneness_intervals[data.doneness_intervals.size()-1]:
			doneness_type = data.DONENESS.BURNT

func _process(_delta: float) -> void:
	pass
	#delete all this
	#var max_cook_time = data.doneness_intervals[data.doneness_intervals.size()-1]
	#if top_half_mesh != null and bottom_half_mesh != null:
		#var top = remap(side_a_cook_level, 0,max_cook_time/2, 0,1)
		#var bot = remap(side_b_cook_level,0,max_cook_time/2, 0,1)
		#var mat: StandardMaterial3D = top_half_mesh.mesh.surface_get_material(0)
		#mat.albedo_color = COOK_COLOURS.sample(top)
		#mat = bottom_half_mesh.surface_get_material(0)
		#mat.albedo_color = COOK_COLOURS.sample(bot)
	#else:
		#var all = remap(cook_level, 0,max_cook_time, 0,1)
		#var mat: StandardMaterial3D = meshes[current_mesh_index].mesh.surface_get_material(0)
		#mat.albedo_color = COOK_COLOURS.sample(all)

func physically_move(new_parent: Node3D, Offset: Vector3 = Vector3.ZERO, Rotation: Vector3 = Vector3.ZERO) -> void:
	reparent(new_parent)
	global_position = new_parent.global_position + Offset
	rotation = Rotation

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
	#print(str(n).pad_decimals(2)," : ",str(d).pad_decimals(2), " = ", str(evenness * 100).pad_decimals(2), "%")
	if evenness <= 0.6:
		return false
	else:
		return true

func _set_doneness() -> void:
	if data.doneness_intervals.size() != data.doneness.size():
		return
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

func prep_ingredient(prep_style: IngredientData.PREP) -> void:
	if prep_dictionary.has(prep_style):
		change_mesh(prep_dictionary[prep_style])
	prep_type = prep_style

func change_mesh(new_mesh: MeshInstance3D) -> void:
	var index: int = 0
	for i in meshes:
		if i == new_mesh:
			i.visible = true
			current_mesh_index = index
		else:
			i.visible = false
		
		index +=1
	

func set_cook_type(type: IngredientData.COOK) -> void:
	cook_type = type


func pickup(p: Player) -> void:
	if not p or p.hand or p.ticket:
		return
	#physically_move(p.hand_pivot)
	p.take_ingredient(self)
	is_on_ground = false
	if inter_pickup:
		inter_pickup.process_mode = Node.PROCESS_MODE_DISABLED
	return


func put_down() -> void:
	is_on_ground = true
	if inter_pickup:
		inter_pickup.process_mode = Node.PROCESS_MODE_INHERIT
	return
