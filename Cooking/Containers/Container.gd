extends Node3D

class_name IngredientContainer

@onready var interactable: Interactable = $Interactable

var ingredient: Ingredient

func _ready() -> void:
	interactable.pressed.connect(put_in)
	interactable.released.connect(take_out)


func put_in(player: Player) -> void:
	if player.hand == null:
		return
	ingredient = player.give_ingredient()
	ingredient.physically_move(self)

func take_out(player:Player) -> void:
	if player.take_ingredient(ingredient):
		ingredient = null
