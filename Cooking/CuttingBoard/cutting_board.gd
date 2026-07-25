extends Node3D

class_name CuttingBoard

@onready var prep_station: PrepStation = $Prep_Station
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.pressed.connect(prep_ingredient)
	interactable.released.connect(cycle_ingredient)

func prep_ingredient(player: Player) -> void:
	var ingredient: Ingredient = player.hand
	if ingredient:
		prep_station.prep(ingredient)

func cycle_ingredient(_player: Player) -> void:
	prep_station.cycle_prep_type()
