extends HSlider

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	drag_started.connect(on_drag_start)
	drag_ended.connect(on_drag_end)
	value_changed.connect(on_value_changed)

func on_value_changed(value: float):
	Config.set_music_volume(value)

func on_drag_start():
	player.play()

func on_drag_end(_value_changed: bool):
	player.stop()
