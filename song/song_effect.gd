class_name SongEffect extends Resource

@export_node_path("AnimationPlayer") var animation_player: NodePath

@export var on_hit_animation: String
@export var on_hit_ok_animation: String
@export var on_hit_good_animation: String
@export var on_hit_perfect_animation: String
@export var on_miss_animation: String
@export var on_pressed_animation: String
@export var on_note_animation: String
@export var on_rest_animation: String

var player: AnimationPlayer = null

func set_player(base: Node):
	if animation_player:
		player = base.get_node(animation_player)

func get_player() -> AnimationPlayer:
	return player

func hit(note: Note, index: int, accuracy: Constants.FullAccuracy, default_player: AnimationPlayer) -> bool:
	var player := get_player()
	if not player:
		player = default_player
	
	var acc := Constants.accuracy_from_full(accuracy)
	
	match acc:
		Constants.Accuracy.Miss:
			if on_miss_animation:
				player.play(on_miss_animation)
				return true
		Constants.Accuracy.Ok:
			if on_hit_ok_animation:
				player.play(on_hit_ok_animation)
				return true
		Constants.Accuracy.Good:
			if on_hit_good_animation:
				player.play(on_hit_good_animation)
				return true
		Constants.Accuracy.Perfect:
			if on_hit_perfect_animation:
				player.play(on_hit_perfect_animation)
				return true
	
	if on_hit_animation:
		player.play(on_hit_animation)
		return true
	
	return false

func miss(note: Note, index: int, early_late: Constants.EarlyLate, default_player: AnimationPlayer) -> bool:
	var player := get_player()
	if not player:
		player = default_player
	if on_miss_animation:
		player.play(on_miss_animation)
		return true
	
	return false

func note(beat_fraction: Fraction, default_player: AnimationPlayer) -> bool:
	var player := get_player()
	if not player:
		player = default_player
	
	if on_note_animation:
		player.play(on_note_animation)
		return true
	
	return false

func rest(beat_fraction: Fraction, default_player: AnimationPlayer) -> bool:
	var player := get_player()
	if not player:
		player = default_player
	print("a")
	if on_rest_animation:
		player.play(on_rest_animation)
		return true
	
	return false

func pressed(default_player: AnimationPlayer) -> bool:
	var player := get_player()
	if not player:
		player = default_player
	
	if on_pressed_animation:
		player.play(on_pressed_animation)
		return true
	
	return false
