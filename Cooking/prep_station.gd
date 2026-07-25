extends Node3D

class_name PrepStation

@export var show_label: bool = true
@onready var label: Label3D = $Label3D

@export var prep_types: Array[IngredientData.PREP]
var current_prep_index: int = 0


func _ready() -> void:
	label.visible = show_label
	cycle_prep_type()

func cycle_prep_type() -> void:
	current_prep_index = (current_prep_index + 1) % prep_types.size()
	label.text = str(IngredientData.PREP.find_key(get_prep_type()))

func get_prep_type() -> IngredientData.PREP:
	return prep_types[current_prep_index]

func prep(ingredient: Ingredient) -> void:
	if ingredient != null:
		ingredient.prep_ingredient(get_prep_type())
	
