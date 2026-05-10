extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const mouse_sensitivity = 0.002

var yaw = 0.0
var pitch = 0.
var receipts := 0;
var acceleration := Vector3.ZERO;
@onready var book_receipt: AudioStreamPlayer = $BookReceipt
@onready var book_dash: AudioStreamPlayer = $BookDash

@onready var camera = $Camera3D
@onready var folder: MeshInstance3D = $folder
@onready var rip_player: AudioStreamPlayer = $"../MusicPlayer/RipPlayer"
@onready var clamp_player: AudioStreamPlayer = $"../MusicPlayer/ClampPlayer"
const RECEIPT_FOR_FOLDER = preload("res://assets/receipt_for_folder.tscn")
var receipts_in_folder: Array[Node3D] = [];

func collect_recipt():
	receipts += 1;
	var receipt: Node3D = RECEIPT_FOR_FOLDER.instantiate();
	folder.add_child(receipt);
	clamp_player.play()
	receipts_in_folder.append(receipt);

	var rng := RandomNumberGenerator.new();
	if (rng.randi_range(0, 3) == 1):
		book_receipt.play()
	receipt.position.y += .01 * receipts_in_folder.size();
	receipt.position.x += rng.randf_range(-0.7, 0.9);
	receipt.position.z += rng.randf_range(-0.3, 0.3);

func kill():
	print_debug("Lost!");
	# Lose game
	get_tree().change_scene_to_file("res://game_over.tscn");
	return;

func use_recipt():
	rip_player.play()
	var rng := RandomNumberGenerator.new()
	if (rng.randi_range(0, 3) == 1):
		book_dash.play()
	receipts -= 1;
	if receipts < 0:
		print_debug("Lost!");
		# Lose game
		get_tree().change_scene_to_file("res://game_over.tscn");
		return;
	receipts_in_folder.pop_back().queue_free();

func _ready():
	# Capture the mouse for first-person control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	acceleration = Vector3.ZERO;

	if not is_on_floor():
		acceleration += Vector3.UP * get_gravity();

	# Don't Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		acceleration += direction * SPEED;

	if Input.is_action_just_pressed(&"crouch") && receipts > 0:
		const DASH_SPEED := 50;
		use_recipt();
		velocity += transform.basis * Vector3.FORWARD * DASH_SPEED;

	velocity += acceleration * delta;
	move_and_slide()

	const DECAY_SPEED = -3;
	velocity.x *= exp(DECAY_SPEED * delta);
	velocity.z *= exp(DECAY_SPEED * delta);
