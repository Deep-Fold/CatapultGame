extends Node2D

func bounced():
	$AnimationPlayer.play("activate")

func destroy():
	queue_free()
