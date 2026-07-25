extends Node3D

class_name HeatArea


@onready var _cook_timer: Timer = $Timer

var is_cooking: bool = false
@export var even_cook: bool = true

##Increases an ingridients cook_level by this every second
@export var heat_level: float = 1 

@export var cook_type: IngredientData.COOK

##Signal Emitted when the current ingridient has been cooked for its appointed time
signal increase_cook_level(amount: float, cooks_evenly: bool)

func _ready() -> void:
	heat_level *= _cook_timer.wait_time

func start_cooking() -> void:
	_cook_timer.start()
	is_cooking = true

func stop_cooking() -> void:
	_cook_timer.stop()
	is_cooking = false

func _on_timer_timeout() -> void:
	increase_cook_level.emit(heat_level, even_cook)
