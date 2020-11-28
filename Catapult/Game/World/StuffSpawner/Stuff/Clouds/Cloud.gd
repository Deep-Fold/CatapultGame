extends Node2D

var motion = Vector2(10,0)

func _ready():
	$Particles2D.process_material = $Particles2D.process_material.duplicate()
	$AnimatedSprite.frame = randi()%2

func _physics_process(delta):
	position += motion * delta
	if position.x < 0:
		motion.x = abs(motion.x)
	if position.x > 100:
		motion.x = -abs(motion.x)

func _on_VisibilityEnabler2D_screen_exited():
	queue_free()

func hit(v):
	$AnimationPlayer.play("shake")
	$Particles2D.process_material.initial_velocity = abs(v.y*0.3)
	$Particles2D.emitting = true
	$AudioStreamPlayer2D.play()
