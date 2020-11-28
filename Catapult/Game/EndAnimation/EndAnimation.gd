extends Control

signal play_again

func _ready():
	$AnimationPlayer.play("default")

func set_launches(amount):
	$ColorRect/LaunchText.text = String(amount) + " launches"


func _on_Button_pressed():
	emit_signal("play_again")
