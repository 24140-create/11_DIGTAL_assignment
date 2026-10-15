extends Node2D



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
	
	get_parent().add_child(barrel)
	barrel.global_position = global_position 
