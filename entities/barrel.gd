extends RigidBody2D

@export var initial_roll_force: float = 150.0

func _ready() -> void:
	# Correct Godot 4 syntax for Continuous Collision Detection
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	
	# Gives the barrel an initial horizontal push to start rolling
	apply_central_impulse(Vector2.RIGHT * initial_roll_force)
	
	# Gives the barrel initial rotational force (spin)
	apply_torque(initial_roll_force * 10.0)

# Optional: Cleans up barrels when they leave the screen to save memory
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
