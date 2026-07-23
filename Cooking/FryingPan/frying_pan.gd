extends Node3D

class_name FryingPan


@onready var precision_minigame_ui: Control = $CanvasLayer/precision_minigame_ui

var active: bool = false

@onready var cooldown_timer: Timer = $"Cooldown Timer"
@onready var timer: Timer = $"Precision Timer"

@onready var heat_area: HeatArea = $HeatArea

@export_range(0.1, 0.9, 0.01) var precision_position: float = 0.5 ##as a fraction
@export_range(0, 0.5, 0.01) var grace_amount: float = 0.1         ##as a fraction

var lower_range: float
var upper_range: float

var cooldown: bool = false

signal successful_flip


func _ready() -> void:
	calc_range()
	precision_minigame_ui.set_up_precision_zone(grace_amount, precision_position)

func _process(_delta: float) -> void:
	if not active:
		return
	
	if not timer.is_stopped():
		precision_minigame_ui.set_current_position(timer)

func _input(event: InputEvent) -> void:
	if not active:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == 1 and not cooldown:
			var time_left = timer.time_left
			if time_left >= lower_range and time_left <= upper_range:
				reset(1)
				successful_flip.emit()
			else:
				cooldown = true
				cooldown_timer.start()

func calc_range() -> void:
	var timer_amount: float = timer.wait_time
	lower_range = timer_amount * precision_position - timer_amount * grace_amount
	upper_range = timer_amount * precision_position + timer_amount * grace_amount
	if lower_range < 0:
		upper_range += lower_range
		lower_range += lower_range
	if upper_range > timer_amount:
		var diff: float = upper_range - timer_amount
		lower_range -= diff
		upper_range -= diff
	
	#print(precision_position," | ", lower_range, " - ", upper_range)

func reset(speed: float) -> void:
	timer.stop()
	await get_tree().create_timer(1.0).timeout
	
	precision_position = randf_range(0.1,0.7)
	timer.start(speed)
	calc_range()
	
	precision_minigame_ui.set_up_precision_zone(grace_amount, precision_position)

func _on_cooldown_timer_timeout() -> void:
	cooldown = false

func _on_precision_timer_timeout() -> void:
	reset(1)

func activate() -> void:
	if active:
		return
	active = true
	precision_minigame_ui.visible = true
	reset(1)

func deactivate() -> void:
	active = false
	precision_minigame_ui.visible = false
