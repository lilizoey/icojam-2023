extends Node

signal music_changed(new_db: float)
signal hit_sound_changed(new_db: float)

var music_volume: float = 100.0
var hit_sound_volume: float = 100.0

func music_volume_db() -> float:
	var frac := (music_volume / 100.0) * 60.0
	return -frac

func hit_sound_volume_db() -> float:
	var frac := (hit_sound_volume / 100.0) * 60.0
	return -frac

func set_music_volume(volume: float):
	music_volume = volume
	music_changed.emit(music_volume_db())

func set_hit_sound_volume(volume: float):
	hit_sound_volume = volume
	hit_sound_changed.emit(hit_sound_volume_db())
