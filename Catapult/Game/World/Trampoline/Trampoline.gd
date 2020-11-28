extends Node2D

onready var line = $Line2D
onready var outline = $Line2D2
onready var shape = $Area2D/CollisionShape2D
onready var upgrades = get_tree().root.get_node("/root/UnlockedUpgrades")
onready var particles = $Particles2D

func set_length(vec):
	line.points[1] = vec
	outline.points[1] = vec
	shape.shape.b = vec

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func get_normal():
	var n1 = Vector2(-line.points[1].y, line.points[1].x)
	var n2 = Vector2(line.points[1].y, -line.points[1].x)
	
	# there are 2 normals, we are only interested in the one pointing up
	if n1.y <0:
		return n1.normalized()
	return n2.normalized()

func get_strength():
	return clamp(line.points[1].length() / 20.0, 0.1, 1.0) * upgrades.get_upgrade_value("trampoline_strength")

func _on_bounce():
	$AudioStreamPlayer2D.play()
	$DespawnTimer.start()
	line.visible = false
	shape.disabled = true
	particles.amount = ceil(line.points[1].length()*.4)+1
	particles.process_material.emission_box_extents.x = line.points[1].length()*.5
	particles.rotation = get_normal().angle()+PI*.5
	particles.position = .5 * line.points[1]
	particles.emitting = true

func bounced():
	call_deferred("_on_bounce")


func _on_DespawnTimer_timeout():
	queue_free()
