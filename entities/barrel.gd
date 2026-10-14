extends CharacterBody2D

# =====================================================================
#  BARREL  --  VERSION 7
#  Attach this to the root node of barrel.tscn.
#
#  Two independent ways of catching the player, so one failing does
#  not mean no hits:
#
#    1. physical collision  - whatever move_and_slide() bumped into
#    2. shape overlap       - the Hitbox Area2D, sized automatically
#                             to sit OUTSIDE the barrel's own body
#
#  Whichever notices first wins. The player ignores repeat calls.
# =====================================================================

@export var speed := 80.0
@export var gravity := 900.0

# How far past the barrel's own body the hitbox reaches.
# Bigger = more forgiving hits. Smaller = stricter.
@export var hitbox_margin := 10.0

@export var show_debug := true

var direction := 1
var hitbox: Area2D = null
var body_radius := 12.0
var debug_timer := 0.0


func _ready() -> void:
	print("### BARREL VERSION 7 ###")
	floor_snap_length = 8.0

	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

	body_radius = _measure_own_body()
	_setup_hitbox()


# Works out how big the barrel's physical shape is, so the hitbox
# can be made bigger than it.
func _measure_own_body() -> float:
	var shape_node: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if shape_node == null or shape_node.shape == null:
		return 12.0

	var s := shape_node.shape
	if s is CircleShape2D:
		return s.radius
	if s is RectangleShape2D:
		return maxf(s.size.x, s.size.y) * 0.5
	if s is CapsuleShape2D:
		return maxf(s.radius, s.height * 0.5)
	return 12.0


func _setup_hitbox() -> void:
	hitbox = get_node_or_null("Hitbox")
	if hitbox == null:
		push_error("BARREL: no child Area2D named 'Hitbox'! Only physical collision will work.")
		return

	hitbox.collision_layer = 0
	hitbox.collision_mask = 0xFFFFFFFF
	hitbox.monitoring = true
	hitbox.position = Vector2.ZERO   # keep it centred on the barrel

	var shape_node: CollisionShape2D = hitbox.get_node_or_null("CollisionShape2D")
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		shape_node.name = "CollisionShape2D"
		hitbox.add_child(shape_node)

	var circle := CircleShape2D.new()
	circle.radius = body_radius + hitbox_margin
	shape_node.shape = circle
	shape_node.position = Vector2.ZERO
	shape_node.disabled = false

	print("###   barrel body radius ", snappedf(body_radius, 0.1),
		" -> hitbox radius ", snappedf(circle.radius, 0.1), " ###")


func _physics_process(delta: float) -> void:
	if is_on_floor():
		velocity.y = 0.0
		var n := get_floor_normal()
		if absf(n.x) > 0.01:
			direction = 1 if n.x > 0.0 else -1
	else:
		velocity.y += gravity * delta

	velocity.x = speed * direction
	move_and_slide()

	if is_on_wall():
		direction *= -1

	if has_node("Sprite2D"):
		$Sprite2D.rotation += velocity.x * delta * 0.08

	# --- method 1: whatever we physically bumped into ---
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		var other := col.get_collider()
		if other != null and other != self and other.has_method("die"):
			print("### HIT (physical collision) ###")
			other.die()
			return

	# --- method 2: shape overlap ---
	if hitbox != null:
		for other in hitbox.get_overlapping_bodies():
			if other != self and other.has_method("die"):
				print("### HIT (shape overlap) ###")
				other.die()
				return

	if show_debug:
		_report(delta)


# Prints how close the nearest overlap is getting, so a near-miss
# is distinguishable from nothing happening at all.
func _report(delta: float) -> void:
	debug_timer += delta
	if debug_timer < 2.0:
		return
	debug_timer = 0.0

	var n_bodies := 0
	if hitbox != null:
		n_bodies = hitbox.get_overlapping_bodies().size()

	print("[chk] overlapping bodies: ", n_bodies,
		" | slide collisions: ", get_slide_collision_count(),
		" | hitbox radius: ", snappedf(body_radius + hitbox_margin, 0.1))
