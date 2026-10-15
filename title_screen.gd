extends Node

# Shows once per play session. Press Enter or Space to start.
static var already_shown := false

var layer: CanvasLayer


func _ready() -> void:
	if already_shown:
		queue_free()
		return
	already_shown = true

	process_mode = Node.PROCESS_MODE_ALWAYS   # keep working while the game is paused
	get_tree().paused = true

	layer = CanvasLayer.new()
	layer.layer = 50
	add_child(layer)

	var bg := ColorRect.new()
	bg.color = Color("#0a0818")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)

	var title := _make_label("Neon Climber", 72, Color("#4de3ff"), -60)
	var prompt := _make_label("Press ENTER to start", 32, Color("#ff4fd8"), 60)
	_make_label("Arrows to move  -  Space to jump  -  Reach the monkey!", 22, Color.WHITE, 130)

	# Pulsing title and blinking prompt
	var t := create_tween().set_loops()
	t.tween_property(title, "modulate:a", 0.6, 1.0)
	t.tween_property(title, "modulate:a", 1.0, 1.0)
	var b := create_tween().set_loops()
	b.tween_property(prompt, "modulate:a", 0.2, 0.5)
	b.tween_property(prompt, "modulate:a", 1.0, 0.5)


func _make_label(text: String, size: int, colour: Color, y_offset: float) -> Label:
	var l := Label.new()
	l.text = text
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.offset_top = y_offset
	l.offset_bottom = y_offset
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", colour)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 8)
	layer.add_child(l)
	return l


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().paused = false
		queue_free()
