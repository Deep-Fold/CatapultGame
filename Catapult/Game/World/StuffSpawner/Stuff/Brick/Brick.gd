extends "res://Game/World/StuffSpawner/Stuff/BaseStuff.gd"


func _on_pickup():
	$Particles2D.emitting = true
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
