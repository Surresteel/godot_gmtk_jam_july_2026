extends Node3D

@onready var label: Label3D = $Order
@export var ingredient_amount: int
@export var ingredient_list: Array[ingredient]

var ingredient_list_ready: Array[ingredient]
var order_number: int = 1

func add_ingredient(arr: Array[ingredient]) -> bool:
	assert(not arr.is_empty())
	var idx: int = randi() % arr.size()
	var current_ingredient : ingredient = arr[idx]
	ingredient_list_ready.append(current_ingredient)
	arr.remove_at(idx)
	return true


func dish():
	var temp: Array[ingredient] = ingredient_list.duplicate()
	ingredient_list_ready.clear()
	ingredient_amount = mini(ingredient_amount, ingredient_list.size())
	for i in range(ingredient_amount):
		add_ingredient(temp)
	ticket()
	return


func ticket():
	if ingredient_list_ready.is_empty():
		return
	
	label.text = ""
	
	
	for i in ingredient_list_ready:
		var cook_value = "" if i.cook.is_empty() \
				else i.COOK.find_key(i.cook.pick_random())
		var doneness_value = "" if i.doneness.is_empty() \
				else i.DONENESS.find_key(i.doneness.pick_random())
		var prep_value = "" if i.prep.is_empty() \
				else i.PREP.find_key(i.prep.pick_random())
	
		label.text += (cook_value + " " \
		+ i.name + " " + doneness_value \
		+ " " + prep_value + "\n").to_lower()
	
	label.text += "\n" + "\n" + "Order Number" \
	+ " " + str(order_number)
	order_number += 1
	ingredient_amount = randi_range(1, 33)
	
	label.line_spacing = remap(ingredient_amount, 0, 33, 30, -5)
	label.font_size = remap(ingredient_amount, 0, 33, 54, 21)
	
	var t = clamp(ingredient_amount / 33, 0, 1)
	label.font_size = lerp(54.0, 21.0, pow(t, 2.2))
	
	return


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	event = event as InputEventMouseButton
	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		dish()
	return
