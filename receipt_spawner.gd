extends Node3D;

const RECIEPT = preload("res://assets/reciept.tscn");
var reciepts: Array[Node3D] = [];
const SPAWN_DELAY := 3.0;
var spawn_timer := SPAWN_DELAY;

func _ready() -> void:
	for child in get_children():
		var reciept := RECIEPT.instantiate();
		reciept.position = child.position;
		reciepts.append(reciept);
		add_sibling(reciept);

func _process(delta: float):
	spawn_timer -= delta;
	if spawn_timer < 0:
		var reciept := RECIEPT.instantiate();
		reciept.position = get_children().pick_random().position;
		add_sibling(reciept);
		spawn_timer = SPAWN_DELAY;
