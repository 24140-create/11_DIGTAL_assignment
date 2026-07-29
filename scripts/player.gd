extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const CLIMB_SPEED = 100.0

# Get standard gravity from project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variables to track ladder state
var is_on_ladder = false
var is_climbing = false

func _physics_process(delta):
	# --- LADDER CLIMBING LOGIC ---
	if is_on_ladder:
		var up_down_direction = Input.get_axis("ui_up", "ui_down")
		
		# Start climbing if the player presses up or down while on a ladder
		if up_down_direction != 0:
			is_climbing = true
			
		if is_climbing:
			velocity.y = up_down_direction * CLIMB_SPEED
			velocity.x = 0 # Prevent moving left/right while climbing
			move_and_slide()
			return # Skip the rest of the physics (like gravity) while climbing

	# --- STANDARD PLATFORMER LOGIC ---
	# Reset climbing state if we aren't using the ladder
	is_climbing = false
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Left/Right Movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# --- SIGNALS FOR LADDERS ---
# These functions will be called when the player touches a ladder
func _on_ladder_entered():
	is_on_ladder = true

func _on_ladder_exited():
	is_on_ladder = false
	is_climbing = false
