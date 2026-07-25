#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name ChoppingBoard
extends StaticBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# MESHES:
@onready var knife: Node3D = $Knife

# INTERACTION:
@onready var food_slot: Interactable = $FoodSlot
@onready var use_knife: Interactable = $Knife/UseKnife

# OPERATION:
var _ingredient: Ingredient = null

# ANIMATIONS:
@export var chop_height: float = 0.05
@export var chop_cycles: int = 10
@export var chop_time: float = 3.0
@export var chop_rot: float = deg_to_rad(20.0)
@onready var pos_idle: Transform3D = $KIdle.transform
@onready var pos_start: Transform3D = $KStart.transform
@onready var pos_end: Transform3D = $KEnd.transform


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	food_slot.pressed.connect(add_food)
	food_slot.released.connect(remove_food)
	use_knife.pressed.connect(cut)
	return


#===============================================================================
#	ANIMATIONS:
#===============================================================================
func _do_cut_anim() -> void:
	var c_time: float = chop_time / chop_cycles / 2.0
	var tween: Tween = create_tween()
	tween.tween_property(knife, "transform", pos_start, 0.75)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
			
	for i in range(chop_cycles):
		var t_form: Transform3D = pos_start.interpolate_with(pos_end, float(i) 
				/ float(chop_cycles))
		t_form = t_form.rotated_local(Vector3.RIGHT, chop_rot)
		var rot : Vector3 = t_form.basis.get_euler()
		var pos: Vector3 = t_form.origin + Vector3(0.0, chop_height, 0.0)
		tween.tween_property(knife, "position", pos, c_time)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(knife, "rotation", rot, c_time)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_OUT)
				
		t_form = pos_start.interpolate_with(pos_end, float(i) 
				/ float(chop_cycles))
		pos = t_form.origin
		rot = t_form.basis.get_euler()
		tween.tween_property(knife, "position", pos, c_time)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(knife, "rotation", rot, c_time)\
				.set_trans(Tween.TRANS_QUAD)\
				.set_ease(Tween.EASE_IN)
	
	var pos2: Vector3 = pos_end.origin + Vector3(0.0, chop_height, 0.0)
	tween.tween_property(knife, "position", pos2, 0.2)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	tween.tween_property(knife, "transform", pos_idle, 0.75)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
	return


#===============================================================================
#	OPERATIONS:
#===============================================================================
func cut(_p: Player) -> void:
	#if not _ingredient:
	#	print("There's nothing to cut.")
	#	return
	_do_cut_anim()
	return

## Adds a food item to the microwave:
func add_food(p: Player) -> void:
	if _ingredient:
		print("Chopping board already has a food item.")
		return
	_ingredient = p.give_ingredient()
	if not _ingredient:
		return
	_ingredient.physically_move(self, self.global_basis * food_slot.position)
	_ingredient.basis = food_slot.basis.scaled(_ingredient.scale)
	return

## Removes a food item from the microwave:
func remove_food(p: Player) -> void:
	if not _ingredient:
		print("Chopping board has no food item.")
		return
	if p.take_ingredient(_ingredient):
		_ingredient = null
	return


#===============================================================================
#	EOF:
#===============================================================================
