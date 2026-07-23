extends Ingredient

@onready var alarm: Alarm = $Alarm
@onready var label: Label3D = $mesh/Label3D
@onready var interactable: Interactable = $Interactable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	alarm.set_time(300)
	
	interactable.pressed.connect(pickup)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = alarm.get_time_str()

func pickup(player: Player) ->void:
	player.take_ingredient(self)
	interactable.toggle(false)
