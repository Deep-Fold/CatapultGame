extends Node2D

export (int) var worth = 1

func set_worth(w):
	worth = w

func get_worth():
	return worth

func pickup():
	$DespawnTimer.start()
	$Label.visible = true
	$Label.text ="+"+String(worth)
	$Sprite.visible = false
	$Tween.interpolate_property($Label, "rect_position", $Label.rect_position, $Label.rect_position-Vector2(0,10), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	_on_pickup()
	$AudioStreamPlayer2D.play()

func _on_pickup():
	pass

func _on_DespawnTimer_timeout():
	queue_free()


func _on_VisibilityEnabler2D_screen_exited():
	queue_free()
