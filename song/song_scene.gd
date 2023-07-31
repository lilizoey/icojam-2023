extends Node2D

@export var default_a_effect: SongEffect
@export var default_b_effect: SongEffect

@export var custom_a_effects: Dictionary
@export var custom_b_effects: Dictionary

func _ready():
	default_a_effect.set_player(self)
	default_b_effect.set_player(self)
	
	for effect in custom_a_effects.values():
		effect.set_player(self)
	for effect in custom_b_effects.values():
		effect.set_player(self)
	
	$SongPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pause_menu_paused():
	$SongPlayer.pause()

func _on_pause_menu_unpaused():
	$SongPlayer.unpause()

func _on_pause_menu_restart():
	$SongPlayer.restart()
	$SongPlayer.play()

func _on_song_player_hit(action, note, index, accuracy):
	match action:
		Song.Action.A:
			if custom_a_effects.has(index) and custom_a_effects[index].hit(note, index, accuracy, default_a_effect.player):
				pass
			else:
				default_a_effect.hit(note, index, accuracy, null)
		Song.Action.B:
			if custom_b_effects.has(index) and custom_b_effects[index].hit(note, index, accuracy, default_b_effect.player):
				pass
			else:
				default_b_effect.hit(note, index, accuracy, null)

func _on_song_player_miss(action, note, index, early_late):
	match action:
		Song.Action.A:
			if custom_a_effects.has(index) and custom_a_effects[index].miss(note, index, early_late, default_a_effect.player):
				pass
			else:
				default_a_effect.miss(note, index, early_late, null)
		Song.Action.B:
			if custom_b_effects.has(index) and custom_b_effects[index].miss(note, index, early_late, default_b_effect.player):
				pass
			else:
				default_b_effect.miss(note, index, early_late, null)

func _on_song_player_note(action, index, beat_fraction):
	match action:
		Song.Action.A:
			if custom_a_effects.has(index) and custom_a_effects[index].note(beat_fraction, default_a_effect.player):
				pass
			else:
				default_a_effect.note(beat_fraction, null)
		Song.Action.B:
			if custom_b_effects.has(index) and custom_b_effects[index].note(beat_fraction, default_b_effect.player):
				pass
			else:
				default_b_effect.note(beat_fraction, null)

func _on_song_player_pressed(action):
	match action:
		Song.Action.A:
			default_a_effect.pressed(null)
		Song.Action.B:
			default_b_effect.pressed(null)

func _on_song_player_rest(action, index, beat_fraction):
	match action:
		Song.Action.A:
			if custom_a_effects.has(index) and custom_a_effects[index].rest(beat_fraction, default_a_effect.player):
				pass
			else:
				default_a_effect.rest(beat_fraction, null)
		Song.Action.B:
			if custom_b_effects.has(index) and custom_b_effects[index].rest(beat_fraction, default_b_effect.player):
				pass
			else:
				default_b_effect.rest(beat_fraction, null)

func _on_song_player_finished():
	$CanvasLayer/ScoreScreen.display($SongPlayer.hit_data)
