extends Node3D
class_name Ingredient


@export var data: IngredientData
const COOK_SHADER_DEFAULT = preload("uid://cd34muvt67ex5")
const COOK_SHADER_Z = preload("uid://ecp15so151v4")
const COOK_SHADER_X = preload("uid://dqu0s5nb21df2")


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

var pan_facing_side: side = side.BOTTOM

var cook_level: float = 0
var top_side_cook_level: float = 0
var bot_side_cook_level: float = 0

var cook_type: IngredientData.COOK
var doneness_type: IngredientData.DONENESS
var prep_type: IngredientData.PREP

# PICKUP STUFF:
@export var inter_pickup: Interactable = null
var is_on_ground: bool = false

@export var use_z_shader: bool = false
@export var use_x_shader: bool = false

func _ready() -> void:
	if inter_pickup:
		inter_pickup.process_mode = Node.PROCESS_MODE_DISABLED
		inter_pickup.pressed.connect(pickup)
	if data.doneness == null:
		data.doneness.append(data.DONENESS.NA)
	_create_detection_area()
	
	_shader_material_force()

func _shader_material_force() -> void:
	for i in meshes:
		for j in range(i.get_surface_override_material_count()):
			if i.get_surface_override_material(j) == null:
				if use_z_shader:
					var shader = COOK_SHADER_Z.duplicate()
					i.set_surface_override_material(j, COOK_SHADER_Z.duplicate())
				elif use_x_shader:
					i.set_surface_override_material(j, COOK_SHADER_X.duplicate())
				else:
					i.set_surface_override_material(j, COOK_SHADER_DEFAULT.duplicate())

func do_shader_stuff() -> void:
	var max_cook_time = data.doneness_intervals[data.doneness_intervals.size()-1]
	var current_mesh: = meshes[current_mesh_index].mesh
	
	var top = remap(top_side_cook_level, 0,max_cook_time/2, 0,1)
	var bot = remap(bot_side_cook_level,0,max_cook_time/2, 0,1)
	
	var aabb = meshes[current_mesh_index].mesh.get_aabb()
	var min: float
	var max: float
	if use_z_shader:
		min = aabb.position.z
		max = aabb.position.z + aabb.size.z
	elif use_x_shader:
		min = aabb.position.x
		max = aabb.position.x + aabb.size.x
	else:
		min = aabb.position.y
		max = aabb.position.y + aabb.size.y
	for i in range(current_mesh.get_surface_count()):
		var material : ShaderMaterial = meshes[current_mesh_index].get_surface_override_material(i)
		
		
		material.set_shader_parameter("top_cook", top)
		material.set_shader_parameter("bot_cook", bot)
		
		
		
		material.set_shader_parameter("base_colour",\
				 current_mesh.surface_get_material(i).albedo_color)
		material.set_shader_parameter("cooked_colour",\
				 data.cooked_colour)

		material.set_shader_parameter("min_y", min)
		material.set_shader_parameter("max_y", max)

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
		top_side_cook_level += amount/2
		bot_side_cook_level += amount/2
	elif pan_facing_side == side.TOP:
		top_side_cook_level += amount
		bot_side_cook_level += amount * 0.4
	else:
		#top_side_cook_level += amount * 0.4
		bot_side_cook_level += amount
	
	cook_level = top_side_cook_level + bot_side_cook_level
	
	if cook_level > data.doneness_intervals[data.doneness_intervals.size()-1]:
		scale_tween = create_tween()
		scale_tween.tween_property(self, "scale", scale - (Vector3.ONE * amount * 0.1) ,0.1)
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
	do_shader_stuff()

func physically_move(new_parent: Node3D, Offset: Vector3 = Vector3.ZERO, Rotation: Vector3 = Vector3.ZERO) -> void:
	reparent(new_parent)
	global_position = new_parent.global_position + Offset
	rotation = Rotation

func _is_evenly_cooked() -> bool:
	var n : float
	var d : float
	if top_side_cook_level < bot_side_cook_level:
		n = top_side_cook_level
		d = bot_side_cook_level
	else:
		n = bot_side_cook_level
		d = top_side_cook_level
	
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
	pan_facing_side = (pan_facing_side + 1) % side.size() as side

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
