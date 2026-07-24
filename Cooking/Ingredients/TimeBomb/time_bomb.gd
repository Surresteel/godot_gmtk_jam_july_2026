extends Ingredient

@onready var alarm: Alarm = $Alarm
@onready var label: Label3D = $mesh/Label3D
@onready var pickup_interactable: Interactable = $PickupArea
@onready var focus_interactable: Interactable = $Focus

@export var time_to_die: float = 300

@onready var wires: Wires = $Wires

signal lock_camera(state)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	alarm.set_time(time_to_die)
	
	alarm.timeout.connect(explode)
	
	pickup_interactable.pressed.connect(pickup)
	focus_interactable.released.connect(unfocus)
	
	wires.defused.connect(defuse)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	label.text = alarm.get_time_str()

func physically_move(new_parent: Node3D, Offset: Vector3 = Vector3.ZERO) -> void:
	if new_parent.get_parent() is Player:
		reparent(new_parent)
		position = Vector3(-0.145,0.1,-0.1) #overwrite the player placing in hand to place in middle of screen
		rotation_degrees = Vector3(90,0,0)
	else:
		unfocus(null)
		super.physically_move(new_parent,Offset)
		rotation_degrees = Vector3(0,0,0)

func cook(amount: float, _even_cook: bool) -> void:
	alarm.add_time(-amount)
	print(-amount)

func pickup(player: Player) ->void:
	if player.take_ingredient(self):
		if !wires.defused.is_connected(player.give_ingredient):
			wires.defused.connect(player.give_ingredient)
			lock_camera.connect(player.lock_camera)
		return
	if player.hand == self:
		pickup_interactable.toggle(false)
		var center: Vector2 = get_viewport().get_visible_rect().size / 2
		Input.warp_mouse(center)
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		wires.enable(true)
		lock_camera.emit(true)
		var tween = create_tween()
		tween.tween_property(player.camera,"rotation_degrees",Vector3(0,0,0), 0.5).set_trans(Tween.TRANS_ELASTIC)
	

func unfocus(_player: Player) -> void:
	pickup_interactable.toggle(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	wires.enable(false)
	lock_camera.emit(false)

func defuse() -> void:
	unfocus(null)
	pickup_interactable.toggle(false)
	focus_interactable.toggle(false)
	
	reparent(get_tree().root)
	var tween = create_tween()
	tween.tween_property(self, "scale",Vector3(0.01,0.01,0.01),3).set_trans(Tween.TRANS_SPRING)
	tween.set_parallel().tween_property(self,"rotation_degrees",Vector3(90,6969,0),3).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	
	destroy_me.emit()
	queue_free()
	

func explode() -> void:
	print("boom")
	destroy_me.emit()
	queue_free()
