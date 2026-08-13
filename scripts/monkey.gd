extends CharacterBody2D

var barrel_scene = preload("res://entities/barrel.tscn")

func _ready():
	throw_barrel()

func throw_barrel():
	var barrel = barrel_scene.instantiate()
	get_parent().add_child(barrel)
	barrel.global_position = global_position + Vector2(0, -50)
