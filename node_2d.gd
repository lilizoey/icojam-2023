extends Node2D

func _on_song_player_hit(action, note, index, accuracy):
	match action:
		Song.Action.A:
			$DebugHitTrackerA.hit(accuracy)
			$HitA.play()
		Song.Action.B:
			$DebugHitTrackerB.hit(accuracy)
			$HitB.play()

func _on_song_player_miss(action, note, index, early_late):
	match action:
		Song.Action.A:
			$DebugHitTrackerA.miss()
		Song.Action.B:
			$DebugHitTrackerB.miss()

func _on_song_player_pressed(action):
	match action:
		Song.Action.A:
			$DebugHitTrackerA.pressed()
		Song.Action.B:
			$DebugHitTrackerB.pressed()

func _on_song_player_note(action, beat_fraction):
	match action:
		Song.Action.A:
			$BeatPlayerA.play("note")
		Song.Action.B:
			$BeatPlayerB.play("note")

func _on_song_player_rest(action, beat_fraction):
	match action:
		Song.Action.A:
			$BeatPlayerA.play("rest")
		Song.Action.B:
			$BeatPlayerB.play("rest")

func _on_pause_menu_paused():
	$SongPlayer.pause()

func _on_pause_menu_unpaused():
	$SongPlayer.unpause()
