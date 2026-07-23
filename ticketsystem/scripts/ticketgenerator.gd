extends Node3D

@export var ingredient_amount: int
@export var ingredient_list: Array[ingredient]
var ingredients: Array[ingredient]

func _ready() -> void:
	
	dish()
	
func _process(_delta: float) -> void:
	pass

func add_ingredient():
	
	var current_ingredient : ingredient = ingredient_list.get(randi_range(0,
	 ingredient_list.size() - 1))
	
	if not ingredients.has(current_ingredient):
		ingredients.append(current_ingredient)
		ingredient_list.erase(current_ingredient)
		
func dish():
	
	if ingredient_amount <= ingredient_list.size():
		for i in range(0, ingredient_amount):
			add_ingredient()
	
		if not ingredients.is_empty():
			for i in ingredients:
				print(i.name)
				if not i.cook.is_empty():
					print(i.COOK.find_key(i.cook.pick_random()))
				if not i.doneness.is_empty():
					print(i.DONENESS.find_key(i.doneness.pick_random()))
				if not i.prep.is_empty():
					print(i.PREP.find_key(i.prep.pick_random()))
