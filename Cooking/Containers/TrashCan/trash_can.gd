extends Node3D

@onready var interactable: Interactable = $Interactable

var trash: Array[Ingredient]

func _ready() -> void:
	interactable.pressed.connect(trashed)
	interactable.released.connect(take_out)


func trashed(player: Player) -> void:
	if player.hand == null:
		return
	var new_trash: Ingredient = player.give_ingredient()
	trash.append(new_trash)
	new_trash.physically_move(self,Vector3(0,0.1,0) * trash.size())

func take_out(player:Player) -> void:
	if trash.is_empty():
		return
	var rubbish: Ingredient = trash.get(trash.size()-1)
	if rubbish != null and player.take_ingredient(rubbish):
		trash.erase(rubbish)
