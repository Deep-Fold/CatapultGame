extends Node2D

func pickup():
	$DespawnTimer.start()
	$AudioStreamPlayer2D.play()
	visible = false
	$Area2D.queue_free()

func _on_DespawnTimer_timeout():
	queue_free()
