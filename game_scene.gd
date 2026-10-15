extends Node2D

@export var music: AudioStream          # drag your song in here (Inspector)
@export var music_volume_db := -8.0     # lower = quieter

@onready var round_timer = $RoundTimer
@onready var timer_label = $CanvasLayer/TimerLabel
@onready var player = $Player
@onready var camera = $Camera2D

var lives_label: Label = null
var last_lives := -1
var music_player: AudioStreamPlayer = null
var music_fading := false


func _ready() -> void:
	round_timer.start()
	_make_background()
	_style_timer()
	_make_lives_label()
	_start_music()


func _process(_delta: float) -> void:
	timer_label.text = "Time: " + str(ceil(round_timer.time_left))

	# Update lives and shake the screen when one is lost
	if player != null and "lives" in player:
		if player.lives != last_lives:
			if last_lives != -1 and player.lives < last_lives:
				_shake_screen()
			last_lives = player.lives
			lives_label.text = "Lives: " + str(max(player.lives, 0))
			if player.lives <= 0:
				_fade_out_music()


func _on_round_timer_timeout() -> void:
	timer_label.text = "TIME UP!"
	print("Round finished!")
	_fade_out_music()


# ---------- music ----------
func _start_music() -> void:
	if music == null:
		print("No music set - click the Game node and drag a song into 'Music' in the Inspector.")
		return

	# Make the song loop (works for mp3 and ogg)
	if "loop" in music:
		music.loop = true

	music_player = AudioStreamPlayer.new()
	music_player.stream = music
	music_player.volume_db = music_volume_db
	add_child(music_player)
	music_player.play()


func _fade_out_music() -> void:
	if music_player == null or music_fading:
		return
	music_fading = true
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -40.0, 1.5)
	tween.tween_callback(music_player.stop)


# ---------- background: gradient sky + twinkling stars ----------
func _make_background() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -10
	add_child(layer)

	var gradient := Gradient.new()
	gradient.set_color(0, Color("#0f1b3d"))   # top
	gradient.set_color(1, Color("#2d1b4e"))   # bottom

	var tex := GradientTexture2D.new()
	tex.gradient = gradient
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0, 1)

	var sky := TextureRect.new()
	sky.texture = tex
	sky.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sky.stretch_mode = TextureRect.STRETCH_SCALE
	sky.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(sky)

	# Stars
	var size := get_viewport().get_visible_rect().size
	for i in 50:
		var star := ColorRect.new()
		var s := randf_range(2.0, 4.0)
		star.size = Vector2(s, s)
		star.position = Vector2(randf() * size.x, randf() * size.y)
		star.color = Color(1, 1, 0.85, randf_range(0.4, 1.0))
		layer.add_child(star)

		var tween := create_tween().set_loops()
		var t := randf_range(0.8, 2.0)
		tween.tween_property(star, "modulate:a", 0.15, t)
		tween.tween_property(star, "modulate:a", 1.0, t)


# ---------- timer text ----------
func _style_timer() -> void:
	timer_label.position = Vector2(16, 12)
	timer_label.add_theme_font_size_override("font_size", 28)
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	timer_label.add_theme_constant_override("outline_size", 6)


# ---------- lives counter (top right) ----------
func _make_lives_label() -> void:
	lives_label = Label.new()
	lives_label.text = "Lives: 3"

	lives_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	lives_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lives_label.offset_right = -16
	lives_label.offset_top = 12

	lives_label.add_theme_font_size_override("font_size", 28)
	lives_label.add_theme_color_override("font_color", Color("#ff5555"))
	lives_label.add_theme_color_override("font_outline_color", Color.BLACK)
	lives_label.add_theme_constant_override("outline_size", 6)
	$CanvasLayer.add_child(lives_label)


# ---------- screen shake ----------
func _shake_screen() -> void:
	if camera == null:
		return
	var tween := create_tween()
	for i in 6:
		var offset := Vector2(randf_range(-12, 12), randf_range(-12, 12))
		tween.tween_property(camera, "offset", offset, 0.04)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.04)
