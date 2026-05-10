extends Area3D

var startY := position.y;
var time := 0.0;

const textures = [
	preload("res://assets/kvitto1.png"),
	preload("res://assets/kvitto2.png"),
	preload("res://assets/kvitto3.png"),
	preload("res://assets/kvitto4.png")
]
@onready var mesh: MeshInstance3D = $MeshInstance3D;

func _ready():
	var mat := StandardMaterial3D.new();
	mat.albedo_texture = textures.pick_random();
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = mat;
	await get_tree().create_timer(60.0).timeout;
	queue_free();

func _on_body_entered(body):
	if body.is_in_group("player"):
		queue_free();
		body.collect_recipt(mesh.get_active_material(0));

func _process(delta: float):
	time += delta;

	const BOBBINESS := 0.3;
	position.y = startY + BOBBINESS + sin(time * 2) * BOBBINESS;

	rotate(Vector3.UP, delta);
