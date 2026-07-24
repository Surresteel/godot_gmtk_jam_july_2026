#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Interactable
extends Area3D

#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
signal pressed()
signal released()
@onready var collider: CollisionShape3D = $Collider

@export var hold: bool = false


#===============================================================================
#	FUNCTIONS - INTERACTABLE:
#===============================================================================
# Activates the interactable:
func activate(player: Player) -> void:
	pressed.emit(player)

# Deactivates the interactable:
func deactivate(player: Player) -> void:
	released.emit(player)

# Toggles whether the interactable is interactable:
func toggle(value: bool) -> void:
	assert(collider, "Interactable doesn't have a collision shape.")
	collider.set_deferred("disabled", !value)


#===============================================================================
#	EOF:
#===============================================================================
