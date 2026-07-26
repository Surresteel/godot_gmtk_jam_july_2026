#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Plate
extends AnimatableBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# SIGNALS:
signal order_complete(t: Ticket)
var _has_emitted: bool = false

# TICKET:
@export var ticket_area: Area3D = null
var _ticket: Ticket = null

# FOOD:
@export var food_area: Area3D = null
var _ingredients: Array[Ingredient]
var _order_status: bool = false
const PLATE = preload("uid://dtbw5p0u6cgx6")

# PARTICLES:
const FLASH = preload("uid://bss3pcr33idw8")


#===============================================================================
#	CALLBACK:
#===============================================================================
func _ready() -> void:
	food_area.area_entered.connect(_on_area_entered)
	food_area.area_exited.connect(_on_area_exited)
	ticket_area.area_entered.connect(_on_ticket_entered)
	ticket_area.area_exited.connect(_on_ticket_exited)
	return


func _physics_process(_delta: float) -> void:
	#print(_ingredients.size())
	if _order_status and not _has_emitted and _ticket:
		order_complete.emit(_ticket)
		_has_emitted = true
		var fx: GPUParticles3D = FLASH.instantiate()
		get_tree().current_scene.add_child(fx)
		fx.global_position = self.global_position
		for i in _ingredients:
			if i:
				i.queue_free()
		if _ticket:
			_ticket.queue_free()
		var new : Plate = PLATE.instantiate()
		get_tree().current_scene.add_child(new)
		new.global_transform = global_transform
		self.queue_free()
	return


#===============================================================================
#	AREA TRACKING:
#===============================================================================
func _on_area_entered(a: Area3D) -> void:
	if not a:
		return
	var ing: Ingredient = a.get_parent() as Ingredient
	if not ing:
		return
	if _ingredients.has(ing):
		return
	_ingredients.append(ing)
	_order_status = _check_order()
	return


func _on_area_exited(a: Area3D) -> void:
	if not a:
		return
	var ing: Ingredient = a.get_parent() as Ingredient
	if not ing:
		return
	var idx: int = _ingredients.find(ing)
	if idx == -1:
		return
	_ingredients.remove_at(idx)
	return


func _on_ticket_entered(a: Area3D) -> void:
	if not a or _ticket:
		return
	var tk: Ticket = a.get_parent() as Ticket
	if not tk:
		return
	_ticket = tk
	_order_status = _check_order()
	#print("Has ticket")
	return


func _on_ticket_exited(a: Area3D) -> void:
	if not a or not _ticket:
		return
	var tk: Ticket = a.get_parent() as Ticket
	if not tk:
		return
	if _ticket == tk:
		_ticket = null
	#print("Lost ticket")
	return

#===============================================================================
#	FOOD VERIFICATION:
#===============================================================================
func _check_ingredient(ing: Ingredient, o: Ticket.Order) -> bool:
	if not ing or not o:
		return false
	for i in o.items:
		if i.item != ing.name:
			continue
		if i.cook != ing.cook_type:
			continue
		if i.donness != ing.doneness_type:
			continue
		if i.prep != ing.prep_type:
			continue
		return true
	return false


func _check_order() -> bool:
	if not _ticket:
		return false
	var order: Ticket.Order = _ticket.get_order()
	if order.items.size() != _ingredients.size():
		return false
	for i in _ingredients:
		if not _check_ingredient(i, order):
			return false
	return true


#===============================================================================
#	EOF:
#===============================================================================
