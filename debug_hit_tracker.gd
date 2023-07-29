extends Node2D

@onready var player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $ColorRect/Label

func hit(accuracy: Constants.FullAccuracy):
	match Constants.accuracy_from_full(accuracy):
		Constants.Accuracy.Miss:
			player.play("miss")
		Constants.Accuracy.Ok:
			player.play("hit_ok")
		Constants.Accuracy.Good:
			player.play("hit_good")
		Constants.Accuracy.Perfect:
			player.play("hit_perfect")

func miss():
	player.play("miss")

func pressed():
	player.play("pressed")
