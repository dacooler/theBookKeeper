extends Area3D

func _on_body_entered(body: Node3D):
	print_debug("JDSAJD")
	if body.is_in_group("throw"):
		var rigidBody: RigidBody3D = body;
		var direction = (body.position - position).normalized();
		direction.y = 0.5;
		rigidBody.linear_velocity += direction * 10;
		print_debug("hallD")
