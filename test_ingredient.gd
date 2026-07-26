extends Ingredient

#@onready var label_3d: Label3D = $Label3D

var top_cook: float
var bot_cook: float

@export_range(0,1,0.01) var split_point: float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	#inter_pickup.process_mode = Node.PROCESS_MODE_DISABLED
	#inter_pickup.pressed.connect(pickup)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	#var max_cook_time = data.doneness_intervals[data.doneness_intervals.size()-1]
	#var current_mesh: = meshes[current_mesh_index].mesh
	#
	#var top = remap(top_side_cook_level, 0,max_cook_time/2, 0,1)
	#var bot = remap(bot_side_cook_level,0,max_cook_time/2, 0,1)
	#
	#var aabb = meshes[current_mesh_index].mesh.get_aabb()
	#
	#var min_y = aabb.position.y
	#var max_y = aabb.position.y + aabb.size.y
	#for i in range(current_mesh.get_surface_count()):
		#var material : ShaderMaterial = meshes[current_mesh_index].get_surface_override_material(i)
		#
		#
		#material.set_shader_parameter("top_cook", top)
		#material.set_shader_parameter("bot_cook", bot)
		#
		#
		#
		#material.set_shader_parameter("base_colour",\
				 #current_mesh.surface_get_material(i).albedo_color)
		#material.set_shader_parameter("cooked_colour",\
				 #data.cooked_colour)
#
		#material.set_shader_parameter("min_y", min_y)
		#material.set_shader_parameter("max_y", max_y)
		
	
	#label_3d.text = "Cook: " + str(IngredientData.COOK.find_key(cook_type)) +"\nDone: " + str(IngredientData.DONENESS.find_key(doneness_type)) + "\nPrep: " + str(IngredientData.PREP.find_key(prep_type))
