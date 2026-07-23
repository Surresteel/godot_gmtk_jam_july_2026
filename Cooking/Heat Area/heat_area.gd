extends Area3D

class_name HeatArea


@onready var cook_timer: Timer = $Timer

@export var heat_level: float = 1.0

var current_ingridient

signal increase_cook_level


func cook_ingridient() -> void:
	#cook_timer.start(current_ingridient.time_to_cook)
	pass

func _on_timer_timeout() -> void:
	increase_cook_level.emit()
