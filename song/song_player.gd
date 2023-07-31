class_name SongPlayer extends Node

signal note(action: Song.Action, index: int, beat_fraction: Fraction)
signal rest(action: Song.Action, index: int, beat_fraction: Fraction)
signal hit(action: Song.Action, note: Note, index: int, accuracy: Constants.FullAccuracy)
signal miss(action: Song.Action, note: Note, index: int, early_late: Constants.EarlyLate)
signal pressed(action: Song.Action, index: int)
signal finished

@export var song: Song
@export var display_debug: bool = false
@export var other_audios: Array[AudioStreamPlayer] = []
@export var video: VideoStreamPlayer

var hit_data := {
	Song.Action.A: {},
	Song.Action.B: {},
}

func _ready():
	song.note.connect(on_song_note)
	song.rest.connect(on_song_rest)
	song.incremented.connect(on_song_incremented)
	song.lost_note.connect(on_song_lost_note)
	song.finished.connect(on_finished)
	$CanvasLayer/DebugMenu.initialize(self)
	if display_debug: 
		$CanvasLayer/DebugMenu.activate()

func play():
	song.play()
	for audio in other_audios:
		audio.play()
	if video:
		video.play()

func get_action_data(action: Song.Action) -> Dictionary:
	return hit_data[action]

func on_song_note(action: Song.Action, index: int, beat_fraction: Fraction):
	note.emit(action, index, beat_fraction)

func on_song_rest(action: Song.Action, index: int, beat_fraction: Fraction):
	rest.emit(action, index, beat_fraction)

func on_song_incremented(action: Song.Action, last_sign: Sign, new_sign: Sign, last_index: int, new_index: int):
	pass

func on_song_lost_note(action: Song.Action, note: Note, index: int):
	var data := get_action_data(action)
	if not data.has(index):
		data[index] = null
		miss.emit(action, note, index, Constants.EarlyLate.Late)

func _unhandled_input(event):
	var action = null
	if event.is_action_pressed("action_a"):
		print("action a")
		action = Song.Action.A
	if event.is_action_pressed("action_b"):
		print("action b")
		action = Song.Action.B
	
	if action != null:
		handle_hit(action, song.hit(action, get_action_data(action).keys()))

func handle_hit(action: Song.Action, current_hit: Actions.Hit):
	if not current_hit.is_hit():
		pressed.emit(action)
		return
	
	print(current_hit)
	var data := get_action_data(action)
	if data.has(current_hit.index):
		pressed.emit(action)
		return
	
	data[current_hit.index] = current_hit
	
	match current_hit.accuracy:
		Constants.FullAccuracy.EarlyMiss:
			miss.emit(action, current_hit.note, current_hit.index, Constants.EarlyLate.Early)
		Constants.FullAccuracy.LateMiss:
			miss.emit(action, current_hit.note, current_hit.index, Constants.EarlyLate.Late)
		_:
			hit.emit(action, current_hit.note, current_hit.index, current_hit.accuracy)

func pause():
	song.stream_paused = true
	for audio in other_audios:
		audio.stream_paused = true
	if video:
		video.paused = true

func unpause():
	song.stream_paused = false
	for audio in other_audios:
		audio.stream_paused = false
	if video:
		video.paused = false

func toggle_pause():
	song.stream_paused = not song.stream_paused
	for audio in other_audios:
		audio.stream_paused = song.stream_paused
	if video:
		video.paused = song.stream_paused

func restart():
	song.reset()
	for audio in other_audios:
		audio.stop()
	hit_data = {
		Song.Action.A: {},
		Song.Action.B: {},
	}

func on_finished():
	finished.emit()
