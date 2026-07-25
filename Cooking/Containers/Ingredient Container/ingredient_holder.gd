extends IngredientContainer

class_name IngredientGiver


@export var ingredient_to_give: Ingredient

func _ready() -> void:
	interactable.pressed.connect(put_in)
	interactable.released.connect(take_out)


func put_in(player: Player) -> void:
	if player.hand == null:
		return
	ingredient = player.give_ingredient()

func take_out(player:Player) -> void:
	player.take_ingredient(ingredient_to_give)
