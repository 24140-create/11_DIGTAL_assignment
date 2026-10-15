extends CharacterBody2D

# =====================================================================
#  PLAYER  --  VERSION 6
#  New in this version:
#    - flashing GAME OVER text when you lose your last life
# =====================================================================

# ---------- movement settings ----------
@export var speed := 120.0
@export var jump_velocity := -320.0
@export var gravity := 900.0

# ---------- falling ----------
@export var fall_limit := 1000.0

# ---------- lives / death ----------
@export var max_lives := 3
@export var respawn_delay := 0.5
@export var invincible_time := 2.0
@export var game_over_time := 3.0    # how long GAME OVER flashes before restart

# ---------- colours ----------
@export var hit_colour := Color(1.0, 0.2, 0.2)

var lives := 3
var start_pos := Vector2.ZERO
var is_dead := false
var invincible := false

var sprite: CanvasItem = null
var game_over_label: Label = null
@onready var death_sound = $DeathSound


func _ready() -> void:
	lives = max_lives
	start_pos = global_position

	sprite = get_node_or_null("Sprite2D")
	if sprite == null:
		sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		push_warning("PLAYER: no Sprite2D or AnimatedSprite2D found - the red flash will not show.")

	_make_game_over_label()
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

	# Fell off the map
	if global_position.y > fall_limit:
		if invincible:
			global_position = start_pos
			velocity = Vector2.ZERO
		else:
			die()


# The barrel calls this. Name must stay exactly "die".
func die() -> void:
	if is_dead or invincible:
		return

	is_dead = true
	lives -= 1
	velocity = Vector2.ZERO

	death_sound.play()
	_set_colour(hit_colour)

	print("[PLAYER] Died. Lives left: ", lives)

	if lives <= 0:
		print("[PLAYER] GAME OVER")
		await _show_game_over()
		get_tree().reload_current_scene()
		return

	await get_tree().create_timer(respawn_delay).timeout

	global_position = start_pos
	velocity = Vector2.ZERO
	is_dead = false

	invincible = true
	_flash_red()
	await get_tree().create_timer(invincible_time).timeout
	invincible = false
	_set_colour(Color.WHITE)
	print("[PLAYER] Invincibility over")


# Builds the GAME OVER text, hidden until you run out of lives.
func _make_game_over_label() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)

	game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.visible = false
	game_over_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.add_theme_font_size_override("font_size", 64)
	game_over_label.add_theme_color_override("font_color", Color.RED)
	game_over_label.add_theme_color_override("font_outline_color", Color.BLACK)
	game_over_label.add_theme_constant_override("outline_size", 10)
	layer.add_child(game_over_label)


# Flashes GAME OVER on and off for game_over_time seconds.
func _show_game_over() -> void:
	var round_timer = get_parent().get_node_or_null("RoundTimer")
	if round_timer != null:
		round_timer.paused = true

	game_over_label.visible = true
	var elapsed := 0.0
	while elapsed < game_over_time:
		await get_tree().create_timer(0.3).timeout
		game_over_label.visible = not game_over_label.visible
		elapsed += 0.3


func _set_colour(c: Color) -> void:
	if sprite != null:
		sprite.modulate = c


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
