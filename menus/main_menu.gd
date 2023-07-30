extends Control

@onready var active_screen: Control = $TitleScreen

func change_screen(screen: Control):
	active_screen.visible = false
	active_screen = screen
	active_screen.visible = true


func _on_settings__return():
	change_screen($TitleScreen)

func _on_title_screen_settings():
	change_screen($Settings)

func _on_title_screen_play():
	change_screen($LevelSelect)

func _on_level_select__return():
	change_screen($TitleScreen)
