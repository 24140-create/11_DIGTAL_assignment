extends Node2D

#in charge of keeping score and spawning the enemies

@onready var enemy_prefab =("res://prefabs/barrel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemy_timer_timeout() -> void:
	var enemy = enemy_prefab.instantiate()
	#position it
	var random_y = randi_range(55,65)
	enemy.position = Vector2(785,random_y)
	add_child(enemy)
