extends CharacterBody3D

var direction := Vector3(1, 0, 0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.start()
	# Replace with function body.
	timer.timeout.connect(_on_timer_timeout)
	
var rng = RandomNumberGenerator.new()
func _on_timer_timeout() -> void:
	if (rng.randi_range(0, 10)) > 8:
		direction = Vector3(0,0,0)
	else:
		rotate_y(rng.randf() * 360)
		direction = (transform.basis * Vector3(0, 0, 1)).normalized()
const SPEED = 2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
