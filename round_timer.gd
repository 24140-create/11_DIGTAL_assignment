extends Node2D

@onready var round_timer = $RoundTimer
@onready var timer_label = $CanvasLayer/TimerLabel

func _ready() -> void:
	round_timer.start()

func _process(_delta: float) -> void:
	timer_label.text = "Time: " + str(ceil(round_timer.time_left))

func _on_round_timer_timeout() -> void:
	timer_label.text = "TIME UP!"
	print("Round finished!")
