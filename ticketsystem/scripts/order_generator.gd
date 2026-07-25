extends Node3D

@onready var timer: Timer = $Timer

func _ready() -> void:
	pass
	
func generate_order():
	
	timer.is_stopped()
