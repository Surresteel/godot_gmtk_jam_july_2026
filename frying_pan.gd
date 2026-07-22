extends Node3D

class_name FryingPan

@onready var label: Label3D = $Label3D

var current_ingridient
var active: bool = false

@onready var cooldown_timer: Timer = $"Cooldown Timer"
@onready var timer: Timer = $"Precision Timer"

@export_range(0, 1, 0.01) var precision_position: float = 0.5 #as a fraction
@export_range(0, 0.5, 0.01) var grace_amount: float = 0.1       #as a fraction

var lower_range: float
var upper_range: float

var cooldown: bool = false

func _ready() -> void:
	calc_range()

func _process(_delta: float) -> void:
	if not timer.is_stopped():
		if timer.time_left >= lower_range and timer.time_left <= upper_range:
			label.modulate = Color.GREEN
		else:
			label.modulate = Color.RED
		label.text = ("%.2f" % timer.time_left + " | Cooldown: " + str(cooldown))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and not cooldown:
			var time_left = timer.time_left
			if time_left >= lower_range and time_left <= upper_range:
				reset()
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
	
	print(lower_range, " - ", upper_range)

func reset() -> void:
	timer.stop()
	await get_tree().create_timer(1.0).timeout
	
	precision_position = randf_range(0.1,0.9)
	
	timer.start(randi_range(1,5))
	calc_range()

func _on_cooldown_timer_timeout() -> void:
	cooldown = false
