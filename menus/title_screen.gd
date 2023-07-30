extends HBoxContainer

signal settings
signal play

func _on_settings_pressed():
	settings.emit()


func _on_play_pressed():
	play.emit()
