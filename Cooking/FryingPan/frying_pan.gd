extends Node3D

class_name FryingPan


@onready var precision_minigame_ui: Control = $CanvasLayer/precision_minigame_ui

@onready var interactable: Interactable = $Interactable

var active: bool = false
var flipping: bool = false

@onready var cooldown_timer: Timer = $"Cooldown Timer"
@onready var timer: Timer = $"Precision Timer"

@onready var heat_area: HeatArea = $HeatArea

var current_ingredient: Ingredient

@export_range(0.1, 0.9, 0.01) var precision_position: float = 0.5 ##as a fraction
@export_range(0, 0.5, 0.01) var grace_amount: float = 0.1         ##as a fraction

var lower_range: float
var upper_range: float

var cooldown: bool = false

signal successful_flip


func _ready() -> void:
	_calc_range()
	precision_minigame_ui.set_up_precision_zone(grace_amount, precision_position)
	
	interactable.pressed.connect(_activate)
	interactable.released.connect(_deactivate)

func _process(_delta: float) -> void:
	if not active:
		return
	
	if not timer.is_stopped():
		precision_minigame_ui.set_current_position(timer)

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			_flip()

func _flip() -> void:
	var time_left = timer.time_left
	if time_left >= lower_range and time_left <= upper_range:
		successful_flip.emit()
		timer.stop()
		
		heat_area.flip_side = !heat_area.flip_side
		flip_tween(180)
		_stop_flipping()
	elif not timer.is_stopped():
		cooldown = true
		cooldown_timer.start()

func _calc_range() -> void:
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

func _reset(speed: float) -> void:
	timer.stop()
	await get_tree().create_timer(0.5).timeout
	
	precision_position = randf_range(0.1,0.7)
	timer.start(speed)
	_calc_range()
	
	precision_minigame_ui.set_up_precision_zone(grace_amount, precision_position)

func _on_cooldown_timer_timeout() -> void:
	cooldown = false

func _on_precision_timer_timeout() -> void:
	flip_tween(360)
	_stop_flipping()

func _activate(player: Player) -> void:
	if active:
		if not flipping:
			_start_flipping()
		return
	
	current_ingredient = player.give_ingredient()
	current_ingredient.physically_move(self,Vector3(0,0.01,0))
	active = true
	heat_area.increase_cook_level.connect(current_ingredient.cook)
	heat_area.start_cooking()

func _deactivate(player: Player) -> void:
	if flipping:
		_stop_flipping()
		return
	
	if player.take_ingredient(current_ingredient):
		heat_area.increase_cook_level.disconnect(current_ingredient.cook)
		heat_area.stop_cooking()
		current_ingredient = null
		active = false

func _start_flipping() -> void:
	flipping = true
	precision_minigame_ui.visible = true
	_reset(1)

func _stop_flipping() -> void:
	timer.stop()
	await get_tree().create_timer(0.5).timeout
	
	precision_minigame_ui.visible = false
	flipping = false

func flip_tween(flip_amount: float) -> void:
	var time: float = 0.9
	
	var tween = create_tween()
	tween.tween_property(current_ingredient,"rotation_degrees",\
			current_ingredient.rotation_degrees + Vector3(flip_amount,0,0), time).set_trans(Tween.TRANS_LINEAR)
	
	tween.parallel().tween_property(current_ingredient,"position",\
			current_ingredient.position + Vector3(0,0.2,0), time/2 + 0.05).set_trans(\
			Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(current_ingredient,"position",current_ingredient.position, time/2 + 0.05).set_trans(\
			Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(time/2 + 0.05)
