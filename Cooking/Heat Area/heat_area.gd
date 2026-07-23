extends Area3D

class_name HeatArea


@onready var cook_timer: Timer = $Timer

@export var heat_level: float = 1.0

signal increase_cook_level(amount: int) 										##Signal Emitted when the current ingridient has been cooked for its appointed time


func start_cooking() -> void:
	#var cook_time = current_ingridient.get_cook_time(heat_level)
	#cook_timer.start(cook_time)
	pass

func stop_cooking() -> void:
	cook_timer.stop()

func _on_timer_timeout() -> void:
	increase_cook_level.emit(1)
