extends CharacterBody2D

@export var barrel_scene: PackedScene
@export var win_distance := 0.1 

var won := false
var win_label: Label = null
var player: Node2D = null


func _ready():
	throw_barrel()
	_make_win_label()
	player = get_parent().get_node_or_null("Player")
	print("[MONKEY] ready, player found: ", player != null)


func throw_barrel():
	if barrel_scene == null:
		return

	var barrel = barrel_scene.instantiate()
	get_parent().add_child(barrel)
	barrel.global_position = global_position + Vector2(54, 775)


func _physics_process(_delta: float) -> void:
	if won or player == null:
		return

	
	var target := global_position
	var sprite_node = get_node_or_null("Sprite2D")
	if sprite_node != null:
		target = sprite_node.global_position

	if player.global_position.distance_to(target) < win_distance:
		_win()


func _win() -> void:
	won = true
	player.set_physics_process(false)   # freeze the player

	var round_timer = get_parent().get_node_or_null("RoundTimer")
	var time_taken := 0.0
	if round_timer != null:
		round_timer.paused = true
		time_taken = round_timer.wait_time - round_timer.time_left

	
	var best := 9999.0
	if FileAccess.file_exists("user://best_time.save"):
		var f := FileAccess.open("user://best_time.save", FileAccess.READ)
		best = f.get_float()
	var new_record := time_taken < best
	if new_record:
		best = time_taken
		var w := FileAccess.open("user://best_time.save", FileAccess.WRITE)
		w.store_float(best)

	win_label.text = "YOU WIN!\nTime: %.1fs\nBest: %.1fs" % [time_taken, best]
	if new_record:
		win_label.text += "\nNEW RECORD!"
	win_label.visible = true
	print("Player reached the monkey - you win!")

	await get_tree().create_timer(4.0).timeout
	get_tree().reload_current_scene()


func _make_win_label() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)

	win_label = Label.new()
	win_label.text = "YOU WIN!"
	win_label.visible = false
	win_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 36)
	win_label.add_theme_color_override("font_color", Color.YELLOW)
	win_label.add_theme_color_override("font_outline_color", Color.BLACK)
	win_label.add_theme_constant_override("outline_size", 8)
	layer.add_child(win_label)
