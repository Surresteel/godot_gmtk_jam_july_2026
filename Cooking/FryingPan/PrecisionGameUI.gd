extends Control

@onready var base: ColorRect = $base
@onready var good: ColorRect = $base/Good
@onready var current_position: ColorRect = $base/Current_Position

@onready var base_size = base.size.x #UI number to get the good stuff


func set_current_position(timer: Timer) -> void:
	current_position.position.x = (timer.time_left / timer.wait_time) * (base_size - current_position.size.x)

func set_up_precision_zone(grace_amount: float, precision_position: float) -> void:
	good.size.x = grace_amount * 2 * base_size - (current_position.size.x / 2)
	
	good.position.x = base_size * precision_position - (good.size.x / 2)
