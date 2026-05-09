extends CharacterBody3D

enum EnemyState {
	IDLE,
	TURNING,
	WALKING,
	CHASING,
}

var direction := Vector3.FORWARD;
var rotationTarget := Vector3.FORWARD;
var movementTarget := Vector3.ZERO;
var chasingTarget: Node3D = null;

var state := EnemyState.IDLE;
var stateTimer := 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

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

func _process_idle():
	direction = Vector3.ZERO;
	if (stateTimer < 0):
		_start_turning_in_random_direction();

func _process_turning():
	var angleDiff := (transform.basis * Vector3.BACK).angle_to(rotationTarget);
	if (angleDiff < .1):
		_start_walking();

func _process_walking():
	if (stateTimer < 0):
		_start_ideling();

func _process_chasing():
	const CHASING_RANGE := 10.0;
	if (position.distance_to(chasingTarget.position) > CHASING_RANGE):
		_start_ideling();
		return;

	rotationTarget = chasingTarget.position - position;
	direction = rotationTarget.normalized();

func _start_ideling():
	state = EnemyState.IDLE;
	stateTimer = 2;

func _start_turning_in_random_direction():
	var rotationAngle := rng.randf() * TAU;
	rotationTarget = Vector3.FORWARD.rotated(Vector3.UP, rotationAngle);
	state = EnemyState.TURNING;

func _start_walking():
	direction = (transform.basis * Vector3(0, 0, 1)).normalized();
	stateTimer = 3;
	state = EnemyState.WALKING;

func _start_chasing(body):
	chasingTarget = body;
	state = EnemyState.CHASING;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	const SPEED := 2.0;
	const ROTATION_SPEED := 2.0;
	const CHASING_SPEED_MULTIPLIER := 2.0;

	var speed = SPEED;
	var rotation_speed = ROTATION_SPEED;
	if (state == EnemyState.CHASING):
		speed *= CHASING_SPEED_MULTIPLIER;
		rotation_speed *= CHASING_SPEED_MULTIPLIER;

	if not is_on_floor():
		velocity += get_gravity() * delta

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	var rotationAngle = rotationTarget.signed_angle_to(basis * Vector3.FORWARD, Vector3.UP);
	rotate(Vector3.UP, sign(rotationAngle) * rotation_speed * delta);

	move_and_slide()
