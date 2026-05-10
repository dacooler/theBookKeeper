extends CharacterBody3D

@onready var waypoints: Node = $Waypoints
@onready var music_player: Node = $"../../MusicPlayer"

var currentWayPoint := -1;
@onready var joe_detect: AudioStreamPlayer3D = $JoeDetect
@onready var joe_ambient: AudioStreamPlayer3D = $JoeAmbient

enum EnemyState {
	IDLE,
	TURNING,
	WALKING,
	CHASING,
}

var rotationTarget := Vector3.FORWARD;
var chasingTarget: Node3D = null;
var movementTarget := position;
var snapshotPosition := Vector3.ZERO;

var state := EnemyState.IDLE;
var stateTimer := 0.0;

var rng := RandomNumberGenerator.new()
func _process(delta):
	stateTimer -= delta;
	match state:
		EnemyState.IDLE:
			_process_idle();
		EnemyState.TURNING:
			_process_turning();
		EnemyState.WALKING:
			_process_walking();
		EnemyState.CHASING:
			_process_chasing();

	if (state == EnemyState.WALKING or state == EnemyState.CHASING) and stateTimer < 0:
		var distance = position.distance_to(snapshotPosition);
		if (distance < 0.1):
			_start_ideling();
		snapshotPosition = Vector3(position);
		stateTimer = 1;

func _process_idle():
	if (rng.randi_range(0, 10000)) == 1:
		joe_ambient.play()
	movementTarget = position;
	if (stateTimer < 0):
		_start_turning();

func _process_turning():
	var angleDiff := (transform.basis * Vector3.BACK).angle_to(rotationTarget);
	if (angleDiff < .1):
		_start_walking();

	rotationTarget.y = 0;
	if (rotationTarget.length() < 0.1):
		_start_ideling();

func _process_walking():
	if (position.distance_to(movementTarget) < 0.1):
		_start_ideling();

func _process_chasing():
	const CHASING_RANGE := 14.0;
	if (position.distance_to(chasingTarget.position) > CHASING_RANGE):
		_start_ideling();
		music_player.lowIntense();
		return;

	rotationTarget = chasingTarget.position - position;
	movementTarget = chasingTarget.position;

func _start_ideling():
	state = EnemyState.IDLE;
	stateTimer = 2.0;
	music_player.lowIntense();

func _start_turning():
	while true:
		var points := waypoints.get_children();
		currentWayPoint = (currentWayPoint + 1) % points.size();
		movementTarget = points[currentWayPoint].position;
		if (movementTarget.distance_to(position) > 0.1):
			break;
	rotationTarget = (movementTarget - position);
	state = EnemyState.TURNING;

func _start_walking():
	state = EnemyState.WALKING;
	snapshotPosition = position;
	stateTimer = 1.0;

func _start_chasing(body):
	chasingTarget = body;
	joe_detect.play()
	music_player.highIntense();
	state = EnemyState.CHASING;
	snapshotPosition = position;
	stateTimer = 1.0;

func _handle_collision(body):
	if body.is_in_group("player") && state == EnemyState.CHASING:
		body.kill();
		_start_ideling();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	const SPEED := 2.0;
	const ROTATION_SPEED := 2.0;
	const CHASING_SPEED_MULTIPLIER := 2.0;

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i);
		_handle_collision(collision.get_collider());

	var speed = SPEED;
	var rotation_speed = ROTATION_SPEED;
	if (state == EnemyState.CHASING):
		speed *= CHASING_SPEED_MULTIPLIER;
		rotation_speed *= CHASING_SPEED_MULTIPLIER;

	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = (movementTarget - position).normalized();
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	var rotationAngle = rotationTarget.signed_angle_to(basis * Vector3.FORWARD, Vector3.UP);
	rotate(Vector3.UP, sign(rotationAngle) * rotation_speed * delta);

	if (state == EnemyState.CHASING or state == EnemyState.WALKING):
		move_and_slide()
