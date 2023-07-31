extends PathFollow2D

signal finished

var time_to_finish: float = 1.0
var rotation_speed: float = TAU

@onready var sprite := $AnimatedSprite2D

func _ready():
	sprite.rotation = randf_range(0.0, TAU)
	var tween := create_tween()
	tween.tween_property(self, "progress_ratio", 1.0, time_to_finish)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.rotation += rotation_speed * delta
	if progress_ratio >= 1.0:
		finished.emit()
		queue_free()
