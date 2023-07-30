extends Button

const LEVEL_1_SCENE: PackedScene = preload("res://song/songs/song_a/song_a_scene.tscn")

func _ready():
	pressed.connect(on_pressed)

func on_pressed():
	get_tree().change_scene_to_packed(LEVEL_1_SCENE)
