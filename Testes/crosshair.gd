extends CenterContainer

class_name Crosshair

@export var radius: float = 1.0
@export var color: Color = Color.WHITE
var crosshair: Vector2

func _ready() -> void:
	
	
	queue_redraw()
	
	


func _draw() -> void:
	var x = get_viewport_rect().size.x/2
	var y = get_viewport_rect().size.y/2
	crosshair = Vector2(x,y)
	
	draw_circle(crosshair, radius, color)
