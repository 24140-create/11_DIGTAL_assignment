extends CharacterBody2D

@export var barrel_scene: PackedScene

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		throw_barrel()

func throw_barrel():
	var barrel = barrel_scene.instantiate()

	barrel.global_position = global_position
	
	get_parent().add_child(barrel)
