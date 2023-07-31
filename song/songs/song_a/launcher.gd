extends Node2D

@export var ball: PackedScene

@onready var path: Path2D = $Path2D

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		spawn_ball(3.0)

func spawn_ball(time: float):
	var new_ball = ball.instantiate()
	new_ball.time_to_finish = time
	path.add_child(new_ball)
