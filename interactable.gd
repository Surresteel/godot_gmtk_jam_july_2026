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


#===============================================================================
#	FUNCTIONS - INTERACTABLE:
#===============================================================================
# Activates the interactable:
func activate() -> void:
	pressed.emit()

# Deactivates the interactable:
func deactivate() -> void:
	released.emit()

# Toggles whether the interactable is interactable:
func toggle(value: bool) -> void:
	assert(collider, "Interactable doesn't have a collision shape.")
	collider.set_deferred("disabled", !value)


#===============================================================================
#	EOF:
#===============================================================================
