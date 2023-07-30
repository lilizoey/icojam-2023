extends Button

const TUTORIAL_SCENE: PackedScene = preload("res://debug_scene.tscn")

func _ready():
	pressed.connect(on_pressed)

func on_pressed():
	get_tree().change_scene_to_packed(TUTORIAL_SCENE)
