extends CharacterBody2D

# =====================================================================
#  PLAYER  --  VERSION 2
#  Attach this to your Player node.
#  Adds a 2 second invincibility window after respawning so you don't
#  lose every life to the same cluster of barrels.
# =====================================================================

# ---------- movement settings ----------
@export var speed := 120.0
@export var jump_velocity := -320.0
@export var gravity := 900.0

# ---------- lives / death ----------
@export var max_lives := 3
@export var respawn_delay := 1.0
@export var invincible_time := 2.0

var lives := 3
var start_pos := Vector2.ZERO
var is_dead := false
var invincible := false


func _ready() -> void:
	lives = max_lives
	start_pos = global_position
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

	# Mercy period so the next barrel doesn't instantly kill you again.
	invincible = true
	_flash()
	await get_tree().create_timer(invincible_time).timeout
	invincible = false
	print("[PLAYER] Invincibility over")


# Blinks whichever sprite node the player has. Harmless if there is none.
func _flash() -> void:
	var sprite := get_node_or_null("Sprite2D")
	if sprite == null:
		sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		return

	var blinks := int(invincible_time / 0.2)
	for i in blinks:
		if not invincible:
			break
		sprite.modulate.a = 0.3
		await get_tree().create_timer(0.1).timeout
		sprite.modulate.a = 1.0
		await get_tree().create_timer(0.1).timeout

	sprite.modulate.a = 1.0
