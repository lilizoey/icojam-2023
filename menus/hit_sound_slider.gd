extends HSlider

func _ready():
	value_changed.connect(on_value_changed)

func on_value_changed(value: float):
	Config.set_hit_sound_volume(value)
