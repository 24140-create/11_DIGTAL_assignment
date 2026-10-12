extends CharacterBody2D

# =====================================================================
#  PLAYER  (updated - now reports its collision layer on startup)
#  Attach this to your Player node (must be a CharacterBody2D).
#
#  If you already have movement code you like, keep yours and copy
#  ONLY the sections marked "LIVES / DEATH", plus the print line in
#  _ready() and the is_dead check at the top of _physics_process.
# =====================================================================

# ---------- movement settings ----------
@export var speed := 120.0
@export var jump_velocity := -320.0
@export var gravity := 900.0

# ---------- LIVES / DEATH ----------
var lives := 3
var start_pos := Vector2.ZERO
var is_dead := false


func _ready() -> void:
	# Remembers wherever you placed the player in the editor.
	start_pos = global_position

	print("[PLAYER] Ready. Start position: ", start_pos)

	# This number tells you which Mask box to tick on the barrel Hitbox:
	#     1  -> tick box 1
	#     2  -> tick box 2
	#     4  -> tick box 3
	#     8  -> tick box 4
	#     0  -> PROBLEM: the player is on no layer at all, tick box 1
	#           under the Player's Collision > Layer
	print("[PLAYER] collision_layer value = ", collision_layer)


func _physics_process(delta: float) -> void:
	# LIVES / DEATH -- freeze the player while dead
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * speed

	move_and_slide()


# ---------- LIVES / DEATH ----------
# The barrel calls this when it touches the player.
# The name must be exactly "die" -- the barrel looks for it by name.
func die() -> void:
	if is_dead:
		return  # stops two barrels eating two lives on the same frame

	is_dead = true
	lives -= 1
	velocity = Vector2.ZERO
	print("[PLAYER] Died. Lives left: ", lives)

	if lives <= 0:
		print("[PLAYER] GAME OVER - reloading scene")
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene()
		return

	await get_tree().create_timer(1.0).timeout
	global_position = start_pos
	velocity = Vector2.ZERO
	is_dead = false
	print("[PLAYER] Respawned at ", start_pos)
