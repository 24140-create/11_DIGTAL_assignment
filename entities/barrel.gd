extends CharacterBody2D

var speed = 150.0
var gravity = 1000.0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = -speed 
	
	move_and_slide()
