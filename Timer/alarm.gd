#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Alarm
extends AudioStreamPlayer3D

#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# CONSTANTS:
var HOUR_S: float = 3_600.0

# SIGNALS:
signal timeout()

# EXPORT VARS:
@export var alarm_sound: AudioStream = null
@export var alarm_tick_sound: AudioStream = null
@export var alarm_duration: float = 1.0

# PRIVATE VARS:
var _time_tally: float = 0.0
var _time_last: float = 0.0
var _time_remaining: float = 0.0

# STATE
var is_set: bool = false
var is_active: bool = false


#===============================================================================
#	CALLBACKS:
#===============================================================================
# Initialise node:
func _ready() -> void:
	self.stream = alarm_tick_sound
	return

# Process node:
func _physics_process(delta: float) -> void:
	# Early exit if alarm isn't set:
	if not is_set:
		return
	
	# Update timer:
	_time_tally += delta
	_time_remaining -= (_time_tally - _time_last)
	_time_last = _time_tally
	
	# Trigger alarm when timer hits zero:
	if is_set and _time_remaining <= 0:
		_trigger_alarm()
	
	return


#===============================================================================
#	ALARM:
#===============================================================================
# Triggers the alarm:
func _trigger_alarm() -> void:
	is_set = false
	is_active = true
	self.stop()
	self.stream = alarm_sound
	self.play()
	timeout.emit()
	
	await get_tree().create_timer(alarm_duration).timeout
	if not is_set:
		self.stop()
	is_active = false
	return


#===============================================================================
#	INTERFACE:
#===============================================================================
## Gets the time of the timer in seconds:
func get_time() -> float:
	return maxf(0.0, float(_time_remaining) / 1_000.0)

## Gets the time of the timer as a string (format: MM:SS)
func get_time_str() -> String:
	if _time_remaining <= 0.0:
		return "00:00"
	@warning_ignore("integer_division")
	var mins := int(_time_remaining + 1) / 60
	var secs := int(_time_remaining + 1) % 60
	return ("%02d:%02d" % [mins, secs])

## Sets the time of the timer in seconds:
func set_time(t: float) -> void:
	t = clampf(t, 0, HOUR_S)
	_time_tally = 0.0
	_time_last = 0.0
	_time_remaining = t
	is_set = true
	is_active = false
	self.stop()
	self.stream = alarm_tick_sound
	self.play(0.0)
	return

func add_time(t: float) -> void:
	if not is_set:
		set_time(t)
		return
	t = clampf(t, 0, HOUR_S - _time_remaining)
	_time_remaining += t
	return

func reset() -> void:
	is_set = false
	is_active = false
	_time_tally = 0.0
	_time_last = 0.0
	_time_remaining = 0.0
	self.stop()
	return


#===============================================================================
#	EOF:
#===============================================================================
