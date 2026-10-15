extends CharacterBody2D

# PLAYER -- VERSION 8 (look upgrade: neon outline, glow aura, motion trail)

@export var speed := 120.0
@export var jump_velocity := -320.0
@export var gravity := 900.0
@export var fall_limit := 1000.0

@export var max_lives := 3
@export var respawn_delay := 0.5
@export var invincible_time := 2.0
@export var game_over_time := 3.0

@export var hit_colour := Color(1.0, 0.2, 0.2)
@export var dust_colour := Color("#4de3ff")
@export var particle_size := 6.0

# ---------- look settings ----------
@export var neon_colour := Color("#4de3ff")   # outline, glow and trail colour
@export var outline_width := 1.5              # outline thickness in sprite pixels
@export var glow_size := 2.0                  # glow size, raise if it looks small
@export var glow_strength := 0.45             # 0 = no glow, 1 = very bright
@export var trail_on := true
@export var trail_gap := 0.05                 # seconds between trail copies

var lives := 3
var start_pos := Vector2.ZERO
var is_dead := false
var invincible := false
var was_on_floor := true
var trail_timer := 0.0

var sprite: CanvasItem = null
var sprite_node: Node2D = null
var base_scale := Vector2.ONE
var glow: Sprite2D = null
var game_over_label: Label = null
@onready var death_sound = $DeathSound


func _ready() -> void:
	lives = max_lives
	start_pos = global_position

	sprite = get_node_or_null("Sprite2D")
	if sprite == null:
		sprite = get_node_or_null("AnimatedSprite2D")
	if sprite != null:
		sprite_node = sprite as Node2D
		base_scale = sprite_node.scale
		_make_outline()
		_make_glow()

	_make_game_over_label()
	print("[PLAYER] Ready at ", start_pos, " with ", lives, " lives")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		_squash(Vector2(0.75, 1.3))
		_burst(global_position, dust_colour, 8, 80.0)

	var dir := Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * speed

	if dir != 0 and sprite != null:
		sprite.set("flip_h", dir < 0)

	move_and_slide()

	if is_on_floor() and not was_on_floor:
		_squash(Vector2(1.3, 0.75))
		_burst(global_position, dust_colour, 8, 80.0)
	was_on_floor = is_on_floor()

	# Motion trail while moving or in the air
	trail_timer -= delta
	if trail_on and trail_timer <= 0.0 and (abs(velocity.x) > 10.0 or not is_on_floor()):
		_spawn_ghost()
		trail_timer = trail_gap

	if global_position.y > fall_limit:
		if invincible:
			global_position = start_pos
			velocity = Vector2.ZERO
		else:
			die()


func die() -> void:
	if is_dead or invincible:
		return

	is_dead = true
	lives -= 1
	velocity = Vector2.ZERO

	death_sound.play()
	_set_colour(hit_colour)
	_burst(global_position, hit_colour, 24, 220.0)
	_squash(Vector2(1.5, 0.5))

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


# ---------- neon outline (shader) ----------
func _make_outline() -> void:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform vec4 outline_color : source_color = vec4(0.3, 0.89, 1.0, 1.0);
uniform float width = 1.5;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec2 s = TEXTURE_PIXEL_SIZE * width;
	float a = 0.0;
	a += texture(TEXTURE, UV + vec2(s.x, 0.0)).a;
	a += texture(TEXTURE, UV - vec2(s.x, 0.0)).a;
	a += texture(TEXTURE, UV + vec2(0.0, s.y)).a;
	a += texture(TEXTURE, UV - vec2(0.0, s.y)).a;
	float o = clamp(a, 0.0, 1.0) * (1.0 - c.a);
	COLOR = vec4(mix(COLOR.rgb, outline_color.rgb, o), max(COLOR.a, o * outline_color.a));
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("outline_color", neon_colour)
	mat.set_shader_parameter("width", outline_width)
	sprite.material = mat


# ---------- glow aura behind the player ----------
func _make_glow() -> void:
	var gradient := Gradient.new()
	var glow_col := neon_colour
	glow_col.a = glow_strength
	gradient.set_color(0, glow_col)
	var clear := neon_colour
	clear.a = 0.0
	gradient.set_color(1, clear)

	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 128
	tex.height = 128

	glow = Sprite2D.new()
	glow.texture = tex
	glow.z_index = -1
	glow.position = sprite_node.position
	glow.scale = Vector2(glow_size, glow_size)
	var add := CanvasItemMaterial.new()
	add.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = add
	add_child(glow)

	# Gentle pulse
	var tween := create_tween().set_loops()
	tween.tween_property(glow, "scale", Vector2(glow_size * 1.2, glow_size * 1.2), 0.9)
	tween.tween_property(glow, "scale", Vector2(glow_size, glow_size), 0.9)


# ---------- motion trail ----------
func _get_current_texture() -> Texture2D:
	if sprite is Sprite2D:
		return (sprite as Sprite2D).texture
	if sprite is AnimatedSprite2D:
		var a := sprite as AnimatedSprite2D
		if a.sprite_frames != null:
			return a.sprite_frames.get_frame_texture(a.animation, a.frame)
	return null


func _spawn_ghost() -> void:
	if sprite_node == null:
		return
	var tex := _get_current_texture()
	if tex == null:
		return

	var ghost := Sprite2D.new()
	ghost.texture = tex
	ghost.global_position = sprite_node.global_position
	ghost.scale = sprite_node.global_scale
	ghost.flip_h = bool(sprite.get("flip_h"))
	ghost.modulate = Color(neon_colour.r, neon_colour.g, neon_colour.b, 0.45)
	ghost.z_index = -1
	get_parent().add_child(ghost)

	var tween := create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tween.tween_callback(ghost.queue_free)


# ---------- squash and stretch ----------
func _squash(factor: Vector2) -> void:
	if sprite_node == null:
		return
	sprite_node.scale = base_scale * factor
	var tween := create_tween()
	tween.tween_property(sprite_node, "scale", base_scale, 0.15)


# ---------- particle burst ----------
func _burst(pos: Vector2, colour: Color, amount: int, power: float) -> void:
	var p := CPUParticles2D.new()
	p.global_position = pos
	p.emitting = true
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = 0.5
	p.direction = Vector2(0, -1)
	p.spread = 150.0
	p.initial_velocity_min = power * 0.4
	p.initial_velocity_max = power
	p.gravity = Vector2(0, 400)
	p.scale_amount_min = particle_size * 0.6
	p.scale_amount_max = particle_size
	p.color = colour
	get_parent().add_child(p)
	get_tree().create_timer(1.0).timeout.connect(p.queue_free)


# ---------- game over ----------
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
