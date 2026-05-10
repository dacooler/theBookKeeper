extends Area3D

func _ready():
	await get_tree().create_timer(10.0).timeout
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		queue_free();
		body.collect_recipt();
