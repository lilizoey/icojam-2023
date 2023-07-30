extends HBoxContainer

signal _return

func _on_return_pressed():
	_return.emit()
