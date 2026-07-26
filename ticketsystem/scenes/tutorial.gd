extends Ticket


func _ready() -> void:
	var text = label.text
	ingredient_amount = randi_range(1, MAX_ORDER_ITEMS)
	generate_dish()
	inter_pickup.pressed.connect(pick_up)
	label.text = text
	return
