
extends IngredientContainer

class_name IngredientGiver


const x_size: float = 0.8
const y_size: float = 0.8
@onready var multimesh: MultiMesh = $MultiMeshInstance3D.multimesh


@export_range(0,100) var amount: int = 1:
	set(value):
		amount = value
		_update_multimesh()
@export var ing_scale: float:
	set(value):
		ing_scale = value
		_update_multimesh()
@export var ingredient_to_give: IngredientMetaData:
	set(value):
		ingredient_to_give = value
		_update_multimesh()
@export_range(0,100) var rows:int = 3:
	set(value):
		rows = value
		_update_multimesh()
@export_range(0,100) var spacing: float = 1:
	set(value):
		spacing = value
		_update_multimesh()
@export var pos: Vector3 = Vector3.ZERO:
	set(value):
		pos = value
		_update_multimesh()


func put_in(player: Player) -> void:
	super.put_in(player)
	if ingredient == null:
		return
	ingredient.queue_free()
	ingredient = null

func take_out(player:Player) -> void:
	ingredient = ingredient_to_give.scene.instantiate()
	add_child(ingredient)
	super.take_out(player)

func _update_multimesh() -> void:
	if not Engine.is_editor_hint():
		return
	if ingredient_to_give == null:
		return
	multimesh.mesh = ingredient_to_give.data.mesh
	multimesh.instance_count = amount
	
	var x := 0
	var z := 0
	for i in range(0,amount):
		var where = Vector3(pos.x + x + spacing  + randf_range(-spacing,spacing), pos.y, pos.z + z * spacing + randf_range(-spacing,spacing))
		var rot = Quaternion(Vector3(randf(), randf(), randf()).normalized(), randf() * PI * 2)
		var base = Basis()
		base = base.scaled(rot * ing_scale)
		var trans = Transform3D(base,where)
		multimesh.set_instance_transform(i,trans)
		
		if x < rows-1:
			x += 1
		else:
			z += 1
			x = 0
	
	
