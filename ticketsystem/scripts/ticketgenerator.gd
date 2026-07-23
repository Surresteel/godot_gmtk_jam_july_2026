extends Node3D

@onready var label: Label3D = $Label3D
@export var ingredient_amount: int
@export var ingredient_list: Array[ingredient]
var ingredients: Array[ingredient]
var ingredient_list_ready: Array[ingredient]

func _ready() -> void:
	
	for i in ingredient_list:
		ingredient_list_ready.append(i)
	
func _process(_delta: float) -> void:
	pass

func add_ingredient():
	
	var current_ingredient : ingredient = ingredient_list.pick_random()
	
	if not ingredients.has(current_ingredient):
		ingredients.append(current_ingredient)
		ingredient_list.erase(current_ingredient)
		
func dish():
	
	ingredient_list = ingredient_list_ready.duplicate()
	print(ingredient_list.size())
	
	if ingredient_amount <= ingredient_list.size():
		for i in range(0, ingredient_amount):
			add_ingredient()
			
	ticket()

func ticket():
	
	if not ingredients.is_empty():
		
		for i in ingredients:
			
			var cook_value = ""
			if not i.cook.is_empty():
				cook_value = i.COOK.find_key(i.cook.pick_random())
			
			var doneness_value = ""
			if not i.doneness.is_empty():
				doneness_value =i.DONENESS.find_key(i.doneness.pick_random())
			
			var prep_value = ""
			if not i.prep.is_empty():	
				prep_value = i.PREP.find_key(i.prep.pick_random())
			
				label.text = cook_value + " " \
				+ i.name + " " + doneness_value \
				+ " " + prep_value	
				
func _unhandled_input(event: InputEvent) -> void:
	
	if event is not InputEventMouseButton:
		return
	event = event as InputEventMouseButton

	if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		dish()
