extends Node2D

# =====================================================================
#  BARREL SPAWNER
#  Attach this to a Node2D placed at the TOP of your level.
#  It needs one child node: a Timer (default settings are fine).
#
#  IMPORTANT: after attaching the script, select the node and drag
#  barrel.tscn into the "Barrel Scene" slot in the Inspector.
#  Nothing spawns if that slot is empty.
# =====================================================================

@export var barrel_scene: PackedScene
@export var spawn_interval := 2.5

@onready var timer: Timer = $Timer


func _ready() -> void:
	if barrel_scene == null:
		push_error("BarrelSpawner: no barrel scene assigned in the Inspector!")
		return

	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.timeout.connect(_spawn_barrel)
	timer.start()

	print("[SPAWNER] Ready. Spawning every ", spawn_interval, " seconds")


func _spawn_barrel() -> void:
	var barrel := barrel_scene.instantiate()
	# Added to the LEVEL, not to the spawner itself.
	get_parent().add_child(barrel)
	barrel.global_position = global_position


# If you ever see an error about "flushing queries", replace the two
# lines above with these instead:
#
#   get_parent().add_child.call_deferred(barrel)
#   barrel.global_position = global_position
