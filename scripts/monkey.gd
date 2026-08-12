extends CharacterBody2D

@export var barrel_scene: PackedScence
@export var throw_interval:= 2.0

var can_throw := true

func _ready():
	throw_loop()
	
func throw_loop():
	while true:
		await get_tree().create_timer(throw_interval).timeout
		throw_barrel()

func throw_barrel()
	var barrel = barrel_scene.instantiate()
	barrel.global_position = global_position + vector2(0,-50)
