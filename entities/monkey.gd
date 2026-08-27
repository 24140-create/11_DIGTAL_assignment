extends CharacterBody2D

@export var barrel_scene: PackedScene

func _input(event):
	if event.is_action_pressed("ui_accept"):
		throw_barrel()

func throw_barrel():
	var barrel = barrel_scene.instantiate()
	get_parent().add_child(barrel)
	barrel.global_position = global_position + Vector2(50, 0)
