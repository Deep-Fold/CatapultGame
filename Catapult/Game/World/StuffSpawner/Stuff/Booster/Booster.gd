extends "res://Game/World/StuffSpawner/Stuff/BaseStuff.gd"

enum states {IDLE, CAUGHT}
var state = states.IDLE
var catch_speed = Vector2.ZERO
var caught_cat = null

func caught(cat):
	state = states.CAUGHT
	catch_speed = cat.motion
	caught_cat = cat
	cat.motion = Vector2.ZERO
	$BoostTimer.start()
	$AddMoney.start()
	$AnimatedSprite.play("charge")
	$AudioStreamPlayer2D.play()

func _physics_process(_delta):
	if state == states.CAUGHT && caught_cat != null:
		caught_cat.position = position

func _on_BoostTimer_timeout():
	state = states.IDLE
	var new_motion = catch_speed.normalized()
	new_motion.y = -1
	new_motion *= 400
	caught_cat.motion = new_motion
	caught_cat = null
	$Launch.play()
	$AnimatedSprite.play("idle")


func _on_AddMoney_timeout():
	if state == states.CAUGHT && caught_cat != null:
		caught_cat.add_money(1)
		$AddMoney.start()
		var l = $Label.duplicate()
		l.text = "+ 1"
		l.visible = true
		add_child(l)
		var start_pos = l.rect_position + Vector2(rand_range(-15, 5),rand_range(-5, 5))
		$Tween.interpolate_property(l, "rect_position", start_pos, start_pos-Vector2(0,10), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
