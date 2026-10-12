extends Node2D

# =====================================================================
#  BARREL SPAWNER  --  no Inspector setup needed
#  Attach this to a Node2D placed at the TOP of your level,
#  where you want barrels to appear.
#  It needs one child node: a Timer (default settings are fine).
#
#  ---------------------------------------------------------------
#  IMPORTANT: check the path on the next line matches your project.
#
#  To get the exact path: right-click barrel.tscn in the FileSystem
#  panel (bottom left of Godot) and choose "Copy Path", then paste
#  it between the quotes below.
#
#  If barrel.tscn sits in a folder called "scenes", the line would
#  instead read:   preload("res://scenes/barrel.tscn")
#  ---------------------------------------------------------------
# =====================================================================

const BARREL_SCENE := preload("res://barrel.tscn")

@export var spawn_interval := 2.5

@onready var timer: Timer = $Timer


func _ready() -> void:
	print("### SPAWNER VERSION 2 RUNNING. Spawner is at ", global_position, " ###")

	timer.wait_time = spawn_interval
	timer.one_shot = false
	timer.timeout.connect(_spawn_barrel)
	timer.start()


func _spawn_barrel() -> void:
	var barrel := BARREL_SCENE.instantiate()
	# Added to the LEVEL, not to the spawner itself.
	get_parent().add_child(barrel)
	barrel.global_position = global_position
#   get_parent().add_child.call_deferred(barrel)
#   barrel.global_position = global_position
