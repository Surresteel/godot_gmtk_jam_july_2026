#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name OrderGenerator
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# PRELOADS:
const TICKET = preload("uid://tygjep58dxwr")

# SIGNALS:
signal new_order()

# ORDER SCHEDULING:
const ORDER_TIME_MAX: float = 60.0
const ORDER_TIME_MIN: float = 180.0
@onready var timer: Timer = $Timer
var _order_inteval: float = 0.0

# TICKET SPAWNING:
const BOARD_WIDTH := Vector2(-0.5, 0.5)
const BOARD_HEIGHT := Vector2(-0.375, 0.375)
const BOARD_OFFSET: float = -0.05


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	timer.one_shot = true
	generate_order()
	_order_inteval = randf_range(ORDER_TIME_MAX, ORDER_TIME_MIN)
	timer.start(_order_inteval)
	timer.timeout.connect(generate_order)
	return

func generate_order():
	var t: Ticket = TICKET.instantiate()
	self.add_child(t)
	t.position = Vector3(randf_range(BOARD_WIDTH.x, BOARD_WIDTH.y),
			randf_range(BOARD_HEIGHT.x, BOARD_HEIGHT.y),
			BOARD_OFFSET)
	
	_order_inteval = randf_range(ORDER_TIME_MAX, ORDER_TIME_MIN)
	timer.start(_order_inteval)
	new_order.emit()
	return
