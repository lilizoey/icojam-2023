extends Node

signal music_changed(new_db: float)
signal hit_sound_changed(new_db: float)
signal metronome_changed(new_db: float)
signal hit_marker_changed(new_db: float)

const MINIMUM_DB: float = 40.0

@onready var music_bus: int = AudioServer.get_bus_index("Music")
@onready var hit_sound_bus: int = AudioServer.get_bus_index("Hit Sound")
@onready var metronome_bus: int = AudioServer.get_bus_index("Metronome")
@onready var hit_marker_bus: int = AudioServer.get_bus_index("Hit Marker")

var music_volume: float = 100.0
var hit_sound_volume: float = 100.0
var metronome_volume: float = 100.0
var hit_marker_volume: float = 100.0

func music_volume_db() -> float:
	var frac := MINIMUM_DB - (music_volume / 100.0) * MINIMUM_DB
	return -frac

func hit_sound_volume_db() -> float:
	var frac := MINIMUM_DB - (hit_sound_volume / 100.0) * MINIMUM_DB
	return -frac

func metronome_volume_db() -> float:
	var frac := MINIMUM_DB - (metronome_volume / 100.0) * MINIMUM_DB
	return -frac

func hit_marker_volume_db() -> float:
	var frac := MINIMUM_DB - (hit_marker_volume / 100.0) * MINIMUM_DB
	return -frac

func set_music_volume(volume: float):
	music_volume = volume
	music_changed.emit(music_volume_db())
	AudioServer.set_bus_volume_db(music_bus, music_volume_db())
	AudioServer.set_bus_mute(music_bus, music_volume_db() <= -MINIMUM_DB + 0.001)

func set_hit_sound_volume(volume: float):
	hit_sound_volume = volume
	hit_sound_changed.emit(hit_sound_volume_db())
	AudioServer.set_bus_volume_db(hit_sound_bus, hit_sound_volume_db())
	AudioServer.set_bus_mute(hit_sound_bus, hit_sound_volume_db() <= -MINIMUM_DB + 0.001)

func set_metronome_volume(volume: float):
	metronome_volume = volume
	metronome_changed.emit(metronome_volume_db())
	AudioServer.set_bus_volume_db(metronome_bus, metronome_volume_db())
	AudioServer.set_bus_mute(metronome_bus, metronome_volume_db() <= -MINIMUM_DB + 0.001)

func set_hit_marker_volume(volume: float):
	hit_marker_volume = volume
	hit_marker_changed.emit(hit_marker_volume_db())
	AudioServer.set_bus_volume_db(hit_marker_bus, hit_marker_volume_db())
	AudioServer.set_bus_mute(hit_marker_bus, hit_marker_volume_db() <= -MINIMUM_DB + 0.001)
