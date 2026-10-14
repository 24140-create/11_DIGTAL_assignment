

extends CharacterBody2D

# =====================================================================
#  BARREL  --  VERSION 5
#  Attach this to the root node of barrel.tscn.
#
#  This version does NOT rely on the Area2D hitbox working.
#  It finds the player itself and measures the distance between them.
#  The Area2D is still used as a backup if it happens to work.
# =====================================================================

@export var speed := 80.0
@export var gravity := 900.0
@export var hit_distance := 24.0   # how close counts as a hit

var direction := 1
var player: Node2D = null
var closest_seen := 99999.0
var report_timer := 0.0


func _ready() -> void:
	print("### BARREL VERSION 5 ###")
	floor_snap_length = 8.0

	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)

	# Find the player: any node in the scene with a die() function.
	player = _find_player(get_tree().current_scene)
	if player == null:
		push_error("BARREL: could not find any node with a die() function!")
	else:
		print("###   found player: ", player.name, " ###")

	# Backup: use the Area2D too, if there is one.
	if has_node("Hitbox"):
		var hitbox: Area2D = $Hitbox
		hitbox.collision_layer = 0
		hitbox.collision_mask = 0xFFFFFFFF
		hitbox.monitoring = true
		hitbox.body_entered.connect(_on_hitbox_body_entered)


func _find_player(node: Node) -> Node2D:
	if node != self and node is Node2D and node.has_method("die"):
		return node
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null


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

	_check_player(delta)


func _check_player(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var d := global_position.distance_to(player.global_position)

	if d < closest_seen:
		closest_seen = d

	# Every 2 seconds, report the closest this barrel has ever come.
	report_timer += delta
	if report_timer >= 2.0:
		report_timer = 0.0
		print("[dist] barrel at ", global_position.round(),
			" player at ", player.global_position.round(),
			" | closest so far: ", snappedf(closest_seen, 0.1))

	if d <= hit_distance:
		print("### BARREL HIT THE PLAYER (distance ", snappedf(d, 0.1), ") ###")
		player.die()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body == self or not body.has_method("die"):
		return
	print("### BARREL HIT THE PLAYER (via Area2D) ###")
	body.die()
