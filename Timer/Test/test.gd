extends MeshInstance3D

@onready var alarm: Alarm = $Alarm
@onready var label: Label3D = $Label3D

func _ready() -> void:
	alarm.set_time(5)
	#test_func()
	return

func _process(_delta: float) -> void:
	label.text = alarm.get_time_str()
	if alarm.is_active:
		label.modulate = Color.RED
	else:
		label.modulate = Color.WHITE
	return

func test_func() -> void:
	await get_tree().create_timer(4).timeout
	alarm.set_time(3)
	return
