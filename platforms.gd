extends Node2D

# ---------- night / neon theme (matches the sky) ----------
@export var body_colour := Color("#241540")    # dark purple
@export var stripe_colour := Color("#34205c")  # lighter purple lines
@export var edge_colour := Color("#0a0818")    # near-black outline
@export var neon_colour := Color("#4de3ff")    # cyan glow on top
@export var dot_colour := Color("#ff4fd8")     # pink lights

@export var top_thickness := 10.0     # neon strip height
@export var outline := 4.0
@export var stripe_gap := 24.0        # space between stripes
@export var dot_gap := 48.0           # space between pink lights
@export var glow_size := 14.0         # how far the glow spreads


func _ready() -> void:
	var shapes := find_children("*", "CollisionShape2D", true, false)
	for node in shapes:
		var cs := node as CollisionShape2D
		if cs.shape is RectangleShape2D:
			_decorate(cs, cs.shape.size)


func _decorate(cs: CollisionShape2D, size: Vector2) -> void:
	var half := size / 2.0
	var top_left := -half

	# Soft neon glow around the platform (pulses)
	for i in 3:
		var grow := glow_size * float(i + 1) / 3.0
		var glow_col := neon_colour
		glow_col.a = 0.10
		var g := _add_rect(cs, top_left - Vector2(grow, grow), size + Vector2(grow, grow) * 2.0, glow_col)
		_pulse(g)

	# Outline
	_add_rect(cs, top_left - Vector2(outline, outline), size + Vector2(outline, outline) * 2.0, edge_colour)

	# Body
	_add_rect(cs, top_left, size, body_colour)

	# Stripes down the body
	var y := top_thickness + stripe_gap
	while y < size.y - 2.0:
		_add_rect(cs, top_left + Vector2(0, y), Vector2(size.x, 2.0), stripe_colour)
		y += stripe_gap

	# Pink lights along the middle
	var dot_y := size.y * 0.55
	var x := dot_gap * 0.5
	while x < size.x - 4.0:
		_add_rect(cs, top_left + Vector2(x, dot_y), Vector2(6, 6), dot_colour)
		x += dot_gap

	# Neon top edge with a bright highlight line
	_add_rect(cs, top_left, Vector2(size.x, top_thickness), neon_colour.darkened(0.35))
	_add_rect(cs, top_left, Vector2(size.x, top_thickness * 0.4), neon_colour.lightened(0.4))


func _add_rect(parent: Node, pos: Vector2, size: Vector2, colour: Color) -> ColorRect:
	var r := ColorRect.new()
	r.position = pos
	r.size = size
	r.color = colour
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


func _pulse(rect: ColorRect) -> void:
	var tween := create_tween().set_loops()
	var t := randf_range(1.0, 1.8)
	tween.tween_property(rect, "modulate:a", 0.3, t)
	tween.tween_property(rect, "modulate:a", 1.0, t)
