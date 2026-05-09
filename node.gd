extends Node

@onready var music = $AudioStreamPlayer
@onready var intense = $AudioStreamPlayer2

# Called when the node enters the scene tree for the first time.

func highIntense():
	intense.volume_db = 0
	music.volume_db = -80
	
func lowIntense():
	intense.volume_db = -80
	music.volume_db = 0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
