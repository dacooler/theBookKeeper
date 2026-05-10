extends Area3D

@onready var enemy: CharacterBody3D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body.is_in_group("player"):
		var space := get_world_3d().direct_space_state;
		var query := PhysicsRayQueryParameters3D.create(
			global_position,
			body.global_position
		);
		var result := space.intersect_ray(query);
		print("hello walllll");
		if result and result.collider == body:
			print("hello there");
			enemy._start_chasing(body);
