extends "res://Game/World/StuffSpawner/Stuff/BaseStuff.gd"

enum STATES {IDLE, MAGNETIZED, PICKED_UP}
var state = STATES.IDLE
var magnetized_to = null

func set_sound(s):
	$AudioStreamPlayer2D.stream.audio_stream = s

func _on_pickup():
	state = STATES.PICKED_UP

func set_texture(tex):
	$Sprite.texture = tex

func _physics_process(delta):
	if state == STATES.MAGNETIZED && magnetized_to != null:
		position += (magnetized_to.position - position).normalized()*100.0*delta

func magnetized(to):
	if state != STATES.PICKED_UP:
		magnetized_to = to
		state = STATES.MAGNETIZED

func demagnetized():
	state = STATES.IDLE
