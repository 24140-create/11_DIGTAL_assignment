extends Node2D

@export var barrel_scene: PackedScene
@export var spawn_interval := 2.5

func _ready() -> void:
	var timer := $Timer
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_barrel)
	timer.start()

func _spawn_barrel() -> void:
	var barrel := barrel_scene.instantiate()
	barrel.global_position = global_position
	get_parent().add_child(barrel)
