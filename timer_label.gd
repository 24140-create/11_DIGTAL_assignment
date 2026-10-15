extends Label

var start_time := 60.0
var time_left := 0.0

func _ready():
	time_left = start_time

func _process(delta):
	time_left = max(time_left - delta, 0.0)
	var minutes := int(time_left / 60)
	var seconds := int(time_left) % 60
	text = "%02d:%02d" % [minutes, seconds]
	if time_left <= 0.0:
		print("Time's up!")
