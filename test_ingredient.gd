extends Ingredient

@onready var label_3d: Label3D = $Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label_3d.text = "Cook: " + str(IngredientData.COOK.find_key(cook_type)) +"\nDone: " + str(IngredientData.DONENESS.find_key(doneness_type)) + "\nPrep: " + str(IngredientData.PREP.find_key(prep_type))
