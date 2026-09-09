extends CharacterBody2D

@export var speed := 80.0
@export var gravity := 900.0

var direction := 1
var was_on_floor := true

func _ready() -> void:
	floor_snap_length = 8.0  # keeps it stuck to slopes instead of bouncing
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
		var n := get_floor_normal()
		if absf(n.x) > 0.01:
			direction = signi(roundi(signf(n.x)))  # or just: direction = -1 if n.x < 0 else 1
	else:
		velocity.y += gravity * delta

	velocity.x = speed * direction
	move_and_slide()

	if is_on_wall():
		direction *= -1

	$Sprite2D.rotation += velocity.x * delta * 0.08
