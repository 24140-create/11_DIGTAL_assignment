extends Node2D

@export var barrel_scene: PackedScene

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if barrel_scene:
		var barrel = barrel_scene.instantiate()
		barrel.global_position = global_position
		get_parent().add_child(barrel)
