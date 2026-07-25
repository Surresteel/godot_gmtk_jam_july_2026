extends Node
class_name ResourceMaker

@export var scenes: Array[PackedScene]

func _ready() -> void:
	create_resources()

func create_resources():
	for i in scenes:
		
		var new: IngredientMetaData = IngredientMetaData.new()
		
		new.scene = i
		var temp = i.instantiate() as Ingredient
		var temp_data = temp.data
		new.data = temp_data
		temp.queue_free()
		
		var error = ResourceSaver.save(new,"res://Cooking/Containers/GENERATED RESOURCES/" + str(new.data.name) + " MetaData.tres")
		if error == OK:
			print("Done")
		else:
			print("Error")
