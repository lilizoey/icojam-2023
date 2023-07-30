extends HSlider

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	value_changed.connect(on_value_changed)

func on_value_changed(value: float):
	Config.set_hit_sound_volume(value)
	
	if not player.playing:
		$AudioStreamPlayer.play()
