#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node3D
class_name Ticket


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# STATICS:
const NA_C := IngredientData.COOK.NA
const NA_D := IngredientData.DONENESS.NA
const NA_P := IngredientData.PREP.NA
#const MAX_ORDER_ITEMS: int = 5
const MAX_ORDER_ITEMS: int = 5
static var order_number: int = 1

# INNER CLASSES:
class OrderItem:
	var item: String
	var prep: IngredientData.PREP
	var donness: IngredientData.DONENESS
	var cook: IngredientData.COOK

class Order:
	var items: Array[OrderItem]

@onready var label: Label3D = $TicketMesh/OrderText
@export var ingredient_amount: int
@export var ingredient_list: Array[IngredientData]
var _ingredient_list_ready: Array[IngredientData]

# Order:
var ticket_order: Order = null

# INTERACTIONS:
@onready var inter_pickup: Interactable = $Pickup


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	ingredient_amount = randi_range(1, MAX_ORDER_ITEMS)
	generate_dish()
	inter_pickup.pressed.connect(pick_up)
	return


#===============================================================================
#	PICKUP:
#===============================================================================
func pick_up(p: Player) -> void:
	if not p:
		return
	p.pickup_ticket(self)
	#self.reparent(p)
	return


#===============================================================================
#	FUNCTIONS:
#===============================================================================
func add_ingredient(arr: Array[IngredientData]) -> bool:
	assert(not arr.is_empty())
	var idx: int = randi() % arr.size()
	var current_ingredient : IngredientData = arr[idx]
	_ingredient_list_ready.append(current_ingredient)
	arr.remove_at(idx)
	return true


func _generate_ticket() -> void:
	if _ingredient_list_ready.is_empty():
		return
	ticket_order = Order.new()
	label.text = ""
	for i in _ingredient_list_ready:
		assert(not i.cook.is_empty()
				and not i.prep.is_empty())
		
		var cook = i.cook.pick_random()
		var cook_raw: bool = cook == IngredientData.COOK.RAW
		var done = i.DONENESS.values().pick_random()
		if cook_raw:
			done = IngredientData.DONENESS.RAW
		elif done == IngredientData.DONENESS.RAW:
			done = (done + 1) % i.DONENESS.size()
		var prep = i.prep.pick_random()
		
		var cook_key = "" if cook == NA_C else i.COOK.find_key(cook)
		var done_key = "" if done == NA_D or done == IngredientData.DONENESS.RAW else i.DONENESS.find_key(done)
		var prep_key = "" if prep == NA_P else i.PREP.find_key(prep)
		
		var order_item := OrderItem.new()
		order_item.item = i.name
		order_item.cook = cook
		order_item.donness = done
		order_item.prep = prep
		ticket_order.items.append(order_item)
		
		var done_space: String = "" if done == NA_D or done == IngredientData.DONENESS.RAW else " "
		label.text += ("- " + cook_key + " " + i.name + " " + done_key \
				+ done_space + prep_key + "\n").to_lower()
	
	label.text += "\n" + "Order Number" \
	+ " " + str(order_number)
	order_number += 1
	ingredient_amount = randi_range(1, MAX_ORDER_ITEMS)
	
	return


func generate_dish() -> void:
	var temp: Array[IngredientData] = ingredient_list.duplicate()
	_ingredient_list_ready.clear()
	ingredient_amount = mini(ingredient_amount, ingredient_list.size())
	for i in range(ingredient_amount):
		add_ingredient(temp)
	_generate_ticket()
	return


func get_order() -> Order:
	return ticket_order


#func _unhandled_input(event: InputEvent) -> void:
#	if event is not InputEventMouseButton:
#		return
#	event = event as InputEventMouseButton
#	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
#		generate_dish()
#	return


#===============================================================================
#	EOF:
#===============================================================================
