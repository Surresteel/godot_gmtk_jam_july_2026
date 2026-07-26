extends Node3D

@onready var music_player: AudioStreamPlayer = %MusicPlayer

func _ready() -> void:
	music_player.play()
	return
