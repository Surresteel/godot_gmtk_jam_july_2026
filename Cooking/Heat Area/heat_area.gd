extends Area3D

class_name HeatArea


@onready var _cook_timer: Timer = $Timer

@export var heat_level: float = 0.1 ##Increases an ingridients cook_level by this, every half a second

signal increase_cook_level(amount: float) 										##Signal Emitted when the current ingridient has been cooked for its appointed time


func start_cooking(current_ingridient) -> void:
	_cook_timer.start()

func stop_cooking() -> void:
	_cook_timer.stop()

func _on_timer_timeout() -> void:
	increase_cook_level.emit(heat_level)
