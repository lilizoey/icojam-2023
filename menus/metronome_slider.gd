extends HSlider

func _on_drag_started():
	$AudioStreamPlayer.play()

func _on_drag_ended(_value_changed):
	$AudioStreamPlayer.stop()

func _on_value_changed(value):
		Config.set_metronome_volume(value)
