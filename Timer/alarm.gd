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

# EXPORT VARS:
@export var alarm_sound: AudioStream = null
@export var alarm_tick_sound: AudioStream = null
@export var alarm_duration: float = 1.0

# PRIVATE VARS:
var _time_remaining: int = 0 # milliseconds
var _ticks_last: int = 0 # milliseconds

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
func _process(_delta: float) -> void:
	# Early exit if alarm isn't set:
	if not is_set:
		return
	
	# Update timer:
	var now: int = Time.get_ticks_msec()
	_time_remaining -= (now - _ticks_last)
	_ticks_last = now
	
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
	
	await get_tree().create_timer(alarm_duration).timeout
	if not is_set:
		self.stop()
	is_active = false
	return


#===============================================================================
#	INTERFACE:
#===============================================================================
## Gets the time of the timer in milliseconds:
func get_time_msec() -> int:
	return maxi(0, _time_remaining)

## Gets the time of the timer in seconds:
func get_time_sec() -> float:
	return maxf(0.0, float(_time_remaining) / 1000)

## Gets the time of the timer as a string (format: MM:SS)
func get_time_str() -> String:
	if _time_remaining < 0:
		return "00:00"
	@warning_ignore("integer_division")
	var mins: int = _time_remaining / 60_000
	@warning_ignore("integer_division")
	var secs: int = (_time_remaining % 60_000) / 1_000
	var time_str: String = str(mins, ":") if mins >= 10 else str("0", mins, ":")
	time_str += str(secs) if secs >= 10 else str(0, secs)
	return time_str

## Sets the time of the timer in seconds:
func set_time_sec(t: float) -> void:
	t = clampf(t, 0, HOUR_S)
	_ticks_last = Time.get_ticks_msec()
	_time_remaining = int(t * 1_000)
	is_set = true
	is_active = false
	self.stop()
	self.stream = alarm_tick_sound
	self.play(0.0)
	return


#===============================================================================
#	EOF:
#===============================================================================
