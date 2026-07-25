#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Toaster
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# MESHES:
@onready var _mesh_dial: MeshInstance3D = $Toaster/Knob
@onready var _mesh_lever_l: MeshInstance3D = $"Toaster/Toast Lever 2"
@onready var _mesh_lever_r: MeshInstance3D = $"Toaster/Toast Lever"
var _lever_positions: Dictionary[Node3D, Vector3]

# INTERACTABLES:
@onready var _int_dial: Interactable = $IntKnob
@onready var _int_lever_l: Interactable = $IntLL
@onready var _int_lever_r: Interactable = $IntLR
@onready var _int_slot_FL: Interactable = $ToastSlotFL
@onready var _int_slot_FR: Interactable = $ToastSlotFR
@onready var _int_slot_RL: Interactable = $ToastSlotRL
@onready var _int_slot_RR: Interactable = $ToastSlotRR
var is_listening: bool = false

# ANIMATION AND SOUND:
const DIAL_ROT_MAX: float = deg_to_rad(180.0)
const DIAL_ROT_SCALE: float = 0.01
@onready var light: AreaLight3D = $Light
@onready var hum: AudioStreamPlayer3D = $Hum
var _dial_rot_amount: float = 0.0
var _toast_down_offset := Vector3(0.0, -0.05, 0.0)

# HEATING:
var HEAT_TIME_MAX: float = 120.0
var HEAT_TIME_MIN: float = 5.0
@onready var _heat_area_l: HeatArea = $HeatAreaL
@onready var _heat_area_r: HeatArea = $HeatAreaR
var slots: Dictionary[Node3D, bool]
var slot_sides: Dictionary[Node3D, bool]
var _ingredients: Dictionary[Node3D, Ingredient]
var heat_time: float = HEAT_TIME_MIN

# ALARMS:
@onready var alarm_l: Alarm = $AlarmL
@onready var alarm_r: Alarm = $AlarmR



#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	light.visible = false
	hum.volume_db = -80.0
	
	_lever_positions[_mesh_lever_l] = _mesh_lever_l.position
	_lever_positions[_mesh_lever_r] = _mesh_lever_r.position
	
	slots[_int_slot_FL] = false
	slots[_int_slot_RL] = false
	slots[_int_slot_FR] = false
	slots[_int_slot_RR] = false
	slot_sides[_int_slot_FL] = false
	slot_sides[_int_slot_RL] = false
	slot_sides[_int_slot_FR] = true
	slot_sides[_int_slot_RR] = true
	
	_int_slot_FL.pressed.connect(add_food.bind(_int_slot_FL))
	_int_slot_FR.pressed.connect(add_food.bind(_int_slot_FR))
	_int_slot_RL.pressed.connect(add_food.bind(_int_slot_RL))
	_int_slot_RR.pressed.connect(add_food.bind(_int_slot_RR))
	_int_slot_FL.released.connect(remove_food.bind(_int_slot_FL))
	_int_slot_FR.released.connect(remove_food.bind(_int_slot_FR))
	_int_slot_RL.released.connect(remove_food.bind(_int_slot_RL))
	_int_slot_RR.released.connect(remove_food.bind(_int_slot_RR))
	
	_int_dial.pressed.connect(func(_p: Player): is_listening = true)
	_int_dial.released.connect(func(_p: Player): is_listening = false)
	
	_int_lever_l.pressed.connect(start_cooking.bind(false))
	_int_lever_r.pressed.connect(start_cooking.bind(true))
	
	alarm_l.timeout.connect(stop_cooking.bind(null, false))
	alarm_r.timeout.connect(stop_cooking.bind(null, true))
	return

func _process(_delta: float) -> void:
	_mesh_dial.rotation.z = _dial_rot_amount
	if is_listening:
		var span: float = HEAT_TIME_MAX - HEAT_TIME_MIN
		heat_time = HEAT_TIME_MIN + ((_dial_rot_amount / DIAL_ROT_MAX) * span)
	return

func _unhandled_input(event: InputEvent) -> void:
	if not is_listening:
		return
	
	if event is InputEventMouseMotion:
		_dial_rot_amount += event.relative.x * DIAL_ROT_SCALE
		_dial_rot_amount = clampf(_dial_rot_amount, 0.0, DIAL_ROT_MAX)
	
	return

#===============================================================================
#	ANIMATIONS:
#===============================================================================
func _toast_up(side: bool) -> void:
	var _ings: Array[Ingredient]
	if side:
		if _ingredients.has(_int_slot_FR):
			_ings.append(_ingredients[_int_slot_FR])
		if _ingredients.has(_int_slot_RR):
			_ings.append(_ingredients[_int_slot_RR])
	else:
		if _ingredients.has(_int_slot_FL):
			_ings.append(_ingredients[_int_slot_FL])
		if _ingredients.has(_int_slot_RL):
			_ings.append(_ingredients[_int_slot_RL])
	for toast in _ings:
		if not toast:
			continue
		var tween = create_tween()
		tween.tween_property(toast, "position", Vector3.ZERO, 0.75)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)

func _toast_down(side: bool) -> void:
	var _ings: Array[Ingredient]
	if side:
		if _ingredients.has(_int_slot_FR):
			_ings.append(_ingredients[_int_slot_FR])
		if _ingredients.has(_int_slot_RR):
			_ings.append(_ingredients[_int_slot_RR])
	else:
		if _ingredients.has(_int_slot_FL):
			_ings.append(_ingredients[_int_slot_FL])
		if _ingredients.has(_int_slot_RL):
			_ings.append(_ingredients[_int_slot_RL])
	for toast in _ings:
		if not toast:
			continue
		var tween = create_tween()
		tween.tween_property(toast, "position", _toast_down_offset, 0.25)\
				.set_trans(Tween.TRANS_QUAD)
	return

func _lever_down(lever: Node3D) -> void:
	assert(lever, "lever is null")
	var pos := _lever_positions[lever] + Vector3(0.0, -0.01, 0.0)
	var tween = create_tween()
	tween.tween_property(lever, "position", pos, 0.25)\
			.set_trans(Tween.TRANS_QUAD)
	return
	
func _lever_up(lever: Node3D) -> void:
	assert(lever, "lever is null")
	var tween = create_tween()
	tween.tween_property(lever, "position", _lever_positions[lever], 0.25)\
			.set_trans(Tween.TRANS_QUAD)
	return


#===============================================================================
#	OPERATIONS:
#===============================================================================
## Adds a food item to the microwave:
func add_food(p: Player, slot: Node3D) -> void:
	assert(slot, "Slot doesn't exist.")
	if slot_sides[slot] and _heat_area_r.is_cooking:
		print("Right side is cooking; cannot add food.")
		return
	if not slot_sides[slot] and _heat_area_l.is_cooking:
		print("Left side is cooking; cannot add food.")
		return
	if _ingredients.has(slot):
		print("Toaster slot already has a food item.")
		return
	var ing: Ingredient = p.give_ingredient()
	ing.destroy_me.connect(clear_food.bind(slot))
	if not ing:
		print("Player has no ingredient to give.")
		return
	_ingredients[slot] = ing
	if not _ingredients[slot]:
		return
	_ingredients[slot].global_basis = self.global_basis
	_ingredients[slot].physically_move(slot, Vector3.ZERO)
	if slot_sides[slot]:
		_heat_area_r.increase_cook_level.connect(_ingredients[slot].cook)
	else:
		_heat_area_l.increase_cook_level.connect(_ingredients[slot].cook)
	return


func remove_food(p: Player, slot: Node3D) -> void:
	assert(slot, "Slot doesn't exist.")
	if slot_sides[slot] and _heat_area_r.is_cooking:
		print("Right side is cooking; cannot take food.")
		return
	if not slot_sides[slot] and _heat_area_l.is_cooking:
		print("Left side is cooking; cannot take food.")
		return
	if not _ingredients.has(slot):
		print("Toaster slot has no food item.")
		return
	if not _ingredients[slot]:
		_ingredients.erase(slot)
		return
	if p.take_ingredient(_ingredients[slot]):
		if slot_sides[slot]:
			_heat_area_r.increase_cook_level.disconnect(_ingredients[slot].cook)
		else:
			_heat_area_l.increase_cook_level.disconnect(_ingredients[slot].cook)
		_ingredients.erase(slot)
	return


func clear_food(slot: Node3D) -> void:
	if not slot:
		return
	if not _ingredients.has(slot):
		return
	_ingredients.erase(slot)
	return


func start_cooking(_p: Player, side: bool = false) -> void:
	if side and not _heat_area_r.is_cooking:
		_heat_area_r.start_cooking()
		_lever_down(_mesh_lever_r)
		alarm_r.set_time(heat_time)
	elif not side and not _heat_area_l.is_cooking:
		_heat_area_l.start_cooking()
		_lever_down(_mesh_lever_l)
		alarm_l.set_time(heat_time)
	_toast_down(side)
	if hum.playing:
		return
	hum.play()
	light.visible = true
	return


func stop_cooking(_p: Player, side: bool = false) -> void:
	if side and _heat_area_r.is_cooking:
		_heat_area_r.stop_cooking()
		_lever_up(_mesh_lever_r)
	elif not side and _heat_area_l.is_cooking:
		_heat_area_l.stop_cooking()
		_lever_up(_mesh_lever_l)
	_toast_up(side)
	if _heat_area_l.is_cooking or _heat_area_r.is_cooking:
		return
	hum.stop()
	light.visible = false
	return

#===============================================================================
#	EOF:
#===============================================================================
