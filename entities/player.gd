extends CharacterBody2D

# =====================================================================
#  PLAYER  --  VERSION 3
#  Attach this to your Player node.
#
#  New in this version:
#    - turns red INSTANTLY on being hit, so there is no dead moment
#      where nothing appears to happen
#    - shorter pause before respawning
#    - flashes red during the invincibility window after respawn
# =====================================================================

# ---------- movement settings ----------
@export var speed := 120.0
@export var jump_velocity := -320.0
@export var gravity := 900.0

# ---------- lives / death ----------
@export var max_lives := 3
@export var respawn_delay := 0.5     # pause after dying, before respawn
@export var invincible_time := 2.0   # mercy period after respawning

# ---------- colours ----------
@export var hit_colour := Color(1.0, 0.2, 0.2)   # red

var lives := 3
var start_pos := Vector2.ZERO
var is_dead := false
var invincible := false

var sprite: CanvasItem = null


func _ready() -> void:
	lives = max_lives
	start_pos = global_position

	# Find whichever sprite node the player has.
	sprite = get_node_or_null("Sprite2D")
	if sprite == null:
		sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		push_warning("PLAYER: no Sprite2D or AnimatedSprite2D found - the red flash will not show.")

	print("[PLAYER] Ready at ", start_pos, " with ", lives, " lives")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * speed

	move_and_slide()


# The barrel calls this. Name must stay exactly "die".
func die() -> void:
	if is_dead or invincible:
		return

	is_dead = true
	lives -= 1
	velocity = Vector2.ZERO

	# INSTANT feedback -- happens on the same frame as the hit,
	# before any waiting, so the hit never feels delayed.
	_set_colour(hit_colour)

	print("[PLAYER] Died. Lives left: ", lives)

	if lives <= 0:
		print("[PLAYER] GAME OVER")
		await get_tree().create_timer(respawn_delay).timeout
		get_tree().reload_current_scene()
		return

	await get_tree().create_timer(respawn_delay).timeout

	global_position = start_pos
	velocity = Vector2.ZERO
	is_dead = false

	# Mercy period, flashing red so you can see it is active.
	invincible = true
	_flash_red()
	await get_tree().create_timer(invincible_time).timeout
	invincible = false
	_set_colour(Color.WHITE)   # back to normal
	print("[PLAYER] Invincibility over")


func _set_colour(c: Color) -> void:
	if sprite != null:
		sprite.modulate = c


# Alternates red / normal for the length of the invincibility window.
func _flash_red() -> void:
	if sprite == null:
		return

	while invincible:
		_set_colour(hit_colour)
		await get_tree().create_timer(0.12).timeout
		if not invincible:
			break
		_set_colour(Color.WHITE)
		await get_tree().create_timer(0.12).timeout

	_set_colour(Color.WHITE)
