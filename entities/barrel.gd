extends CharacterBody2D

# =====================================================================
#  BARREL  --  VERSION 3
#  Attach this to the root node of barrel.tscn (a CharacterBody2D).
#
#  Required child nodes (exact names, capital letters matter):
#    Sprite2D                    - optional
#    CollisionShape2D            - CircleShape2D, the physical body
#    VisibleOnScreenNotifier2D   - deletes the barrel when it leaves view
#    Hitbox                      - an Area2D, with its own CollisionShape2D
# =====================================================================

@export var speed := 80.0
@export var gravity := 900.0

var direction := 1


func _ready() -> void:
	print("### BARREL SCRIPT VERSION 3 IS RUNNING ###")

	floor_snap_length = 8.0  # keeps the barrel glued to slopes

	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
		# The floor normal tells us which way is downhill.
		var n := get_floor_normal()
		if absf(n.x) > 0.01:
			direction = 1 if n.x > 0.0 else -1
	else:
		velocity.y += gravity * delta

	velocity.x = speed * direction
	move_and_slide()

	if is_on_wall():
		direction *= -1

	# Rolling animation (skipped if there is no Sprite2D child)
	if has_node("Sprite2D"):
		$Sprite2D.rotation += velocity.x * delta * 0.08


# ---------------------------------------------------------------------
#  Runs when a physics body enters the Hitbox area.
#  Anything without a die() function is ignored silently.
# ---------------------------------------------------------------------
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == self:
		return

	if not body.has_method("die"):
		return  # another barrel, or scenery -- not the player

	print("### BARREL HIT THE PLAYER ###")
	body.die()
