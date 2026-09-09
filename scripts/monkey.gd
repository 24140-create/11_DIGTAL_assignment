extends CharacterBody2D

@export var barrel_scene: PackedScene

func _ready():
	throw_barrel()

func throw_barrel():
	if barrel_scene == null:
		print("Please assign barrel.tscn in the Inspector!")
		return
		
	var barrel = barrel_scene.instantiate()
	get_parent().add_child(barrel)
	barrel.global_position = global_position + Vector2(54, 775)
