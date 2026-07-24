extends Node3D

class_name HeatArea


@onready var _cook_timer: Timer = $Timer

var flip_side: bool = false
var is_cooking: bool = false
@export var even_cook: bool = false

@export var heat_level: float = 0.10 ##Increases an ingridients cook_level by this, 10 times a second

signal increase_cook_level(amount: float,side_a: bool, side_b: bool) 										##Signal Emitted when the current ingridient has been cooked for its appointed time


func start_cooking() -> void:
	_cook_timer.start()
	is_cooking = true

func stop_cooking() -> void:
	_cook_timer.stop()
	is_cooking = false

func _on_timer_timeout() -> void:
	if even_cook:
		increase_cook_level.emit(heat_level/2, true, true)
	else:
		increase_cook_level.emit(heat_level, !flip_side, flip_side)
