extends CharacterBody2D

# =====================================================================
#  BARREL
#  Attach this to the root node of barrel.tscn (a CharacterBody2D).
#
#  Required child nodes (exact names matter):
#    Sprite2D                    - optional, the script checks first
#    CollisionShape2D            - CircleShape2D, the physical body
#    VisibleOnScreenNotifier2D   - deletes the barrel when it leaves view
#    Hitbox                      - an Area2D, with its own CollisionShape2D
# =====================================================================

@export var speed := 80.0
@export var gravity := 900.0

var direction := 1


func _ready() -> void:
	floor_snap_length = 8.0  # keeps the barrel glued to slopes

	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)

	print("[BARREL] Spawned at ", global_position)


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

	# Rolling animation (skipped if you have no Sprite2D child)
	if has_node("Sprite2D"):
		$Sprite2D.rotation += velocity.x * delta * 0.08


# ---------------------------------------------------------------------
#  This runs when ANY physics body enters the Hitbox area.
#  Watch the Output panel at the bottom of the Godot editor:
#
#    - Nothing prints when you touch a barrel?
#        -> collision layer/mask problem, or the Hitbox's
#           CollisionShape2D has no shape resource assigned.
#
#    - "no die() function" prints?
#        -> your player script is missing die(), or it's spelled
#           differently, or the script isn't attached to the player.
# ---------------------------------------------------------------------
func _on_hitbox_body_entered(body: Node2D) -> void:
	print("[BARREL] Hitbox touched: ", body.name)

	if body.has_method("die"):
		body.die()
	else:
		print("[BARREL]   ...but ", body.name, " has no die() function")
