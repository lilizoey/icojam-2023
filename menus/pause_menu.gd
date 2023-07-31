extends PanelContainer

signal unpaused
signal paused
signal restart

@onready var main_pause: Control = $MainPause
@onready var settings: Control = $Settings

var is_paused := false

func _on_settings__return():
	settings.visible = false
	main_pause.visible = true

func _on_return_pressed():
	toggle_paused()

func _on_settings_pressed():
	main_pause.visible = false
	settings.visible = true

func _on_exit_to_level_select_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		toggle_paused()

func toggle_paused():
	if is_paused:
		unpaused.emit()
		main_pause.visible = true
		settings.visible = false
		visible = false
		is_paused = false
	else:
		paused.emit()
		visible = true
		is_paused = true

func _on_restart_pressed():
	restart.emit()
	toggle_paused()
