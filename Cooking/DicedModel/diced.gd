extends Node3D

@onready var icosphere: MeshInstance3D = $Icosphere

func change_albedo(color: Color) -> void:
	icosphere.mesh.surface_get_material(0).albedo_color = color
