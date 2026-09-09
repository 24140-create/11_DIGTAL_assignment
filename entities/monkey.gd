extends Node2D

var barrel_scene: PackedScene = preload("res://entities/barrel.tscn")
@export var spawn_interval: float = 3.0

var spawn_timer: Timer

func _ready() -> void:
	# Set up a timer to spawn barrels automatically
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_timer_timeout)
	add_child(spawn_timer)

func spawn_barrel() -> void:
	if barrel_scene == null:
		print("Error: Could not load barrel scene!")
		return
		
	# Instance the barrel and set position
	var new_barrel = barrel_scene.instantiate() as RigidBody2D
	new_barrel.global_position = global_position
	
	# Add the barrel to the main scene tree root so it rolls freely
	get_tree().current_scene.add_child(new_barrel)

func _on_timer_timeout() -> void:
	spawn_barrel()
