extends Area3D

class_name HeatArea


@onready var cook_timer: Timer = $Timer

@export var heat_level: float = 1.0

var current_ingridient

signal increase_cook_level(amount: int)


func start_cooking() -> void:
	#cook_timer.start(current_ingridient.time_to_cook)
	pass

func stop_cooking() -> void:
	cook_timer.stop()
	current_ingridient = null

func _on_timer_timeout() -> void:
	increase_cook_level.emit(1)
