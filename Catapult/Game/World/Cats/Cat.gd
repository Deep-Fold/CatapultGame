extends Node2D

signal change_milk
signal landed
const max_milk = 100.0

onready var upgrades = get_tree().root.get_node("/root/UnlockedUpgrades")
onready var mousestate = get_tree().root.get_node("/root/MouseControl")
onready var animation = $AnimatedSprite
onready var launch_particles = $LaunchParticles
onready var magnet_shape = $MagnetArea/CollisionShape2D
enum STATES {NOT_STARTED, IDLE,GRABBED,SEATED,WALKING,REGENERATING,FLYING}
var state = STATES.NOT_STARTED

var milk = 100
var motion = Vector2(0,-10)
var walk_motion = Vector2(10,0)
var ground_y = 140

func start():
	state = STATES.IDLE
	$SwitchIdleWalkTimer.start()

func _on_MouseClickBox_input_event(_viewport, event, _shape_idx):
	if state == STATES.NOT_STARTED:
		return
	
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		if mousestate.is_idle() && event.pressed:
			if (state == STATES.IDLE || state == STATES.WALKING) && energy_full():
				_grab()
		elif mousestate.is_cat_grab() && state == STATES.GRABBED && !event.pressed:
			_release()

func _physics_process(delta):
	match state:
		STATES.GRABBED:
			global_position = get_global_mouse_position()
			global_position.y = clamp(global_position.y, 0.0, ground_y)
			global_position.x = clamp(global_position.x, 0.0, 100)
		STATES.FLYING:
			fly(delta)
		STATES.REGENERATING:
			milk += 30.0 * delta
			if milk>max_milk:
				milk = max_milk
				state = STATES.IDLE
		STATES.WALKING:
			position += walk_motion * delta
			animation.flip_h = walk_motion.x > 0
			if position.x < 0:
				walk_motion.x = abs(walk_motion.x)
			elif position.x > 100:
				walk_motion.x = -abs(walk_motion.x)

func fly(delta):
	position += motion * delta
			
	if position.x <= 0:
		motion.x = abs(motion.x)
	elif position.x >= 100:
		motion.x = -abs(motion.x)
	
	motion.y += 100.0 * delta
	motion.x = lerp(motion.x, 0.0, 0.3*delta)#*= 0.99
	motion.y = min(motion.y, 100.0)
	
	animation.flip_h = motion.x < 0
	
	if motion.length() < 300:
		$Label.visible = false
	
	if motion.length() < 200:
		launch_particles.emitting = false
	else:
		launch_particles.emitting = true
		var scl = clamp((-motion.y/200.0)-1.0, 0.0, 1.0)
		launch_particles.process_material.scale = scl
	
	if position.y > ground_y:
		_land()

func _land():
	emit_signal("landed")
	animation.play("drinking")
	state = STATES.REGENERATING
	position.y = ground_y

func launch(m):
	motion = m
	state = STATES.FLYING
	animation.play("shooting")
	$Label.visible = true
	$Label.rect_size.x = 0
	magnet_shape.shape.radius = 10.0 * upgrades.get_upgrade_value("magnet_strength")

func set_state_seated():
	state = STATES.SEATED
	animation.play("seated")

func energy_full():
	return true

func _grab():
	state = STATES.GRABBED
	animation.play("grabbed")
	mousestate.set_state_cat_grab()
	mousestate.set_held_cat(self)

func _release():
	motion = Vector2.ZERO
	state = STATES.FLYING
	#motion.y = 100.0
	mousestate.set_state_idle()

func get_milk():
	return milk

func remove_milk(m):
	milk = max(0.0, milk-m)

func _on_BounceArea_area_entered(area):
	var p = area.get_parent()
	# we wont allow cat to get boosted if going in at high speed
	if p.is_in_group("trampoline") && motion.y>-5:
		var bounce_angle = p.get_normal().angle()+PI*0.5
		
		motion = Vector2(0,-300).rotated(bounce_angle) * p.get_strength()
		# only upwards motion
		motion.y = -abs(motion.y)
		p.bounced()
	elif p.is_in_group("brick"):
		if motion.length() < 300:
			motion.y *= 0.2
			motion.x *= 0.3
		p.pickup()
		upgrades.add_money(p.get_worth())
	elif p.is_in_group("cloud") && motion.length() < 300:
		p.hit(motion)
		motion.y *= 0.7
	elif p.is_in_group("booster") &&  motion.length() < 500:
		p.caught(self)
#	elif p.is_in_group("bumper"):
#		if motion.length() > 250:
#			p.destroy()
#		else:
#			var normal = (global_position-p.global_position)
#			motion = normal * 20.0;
#			p.bounced()
	

func _on_CollectionArea_area_entered(area):
	var p = area.get_parent()
	# we wont allow cat to get boosted if going in at high speed
	if p.is_in_group("fish"):
		upgrades.add_money(p.get_worth())
		p.pickup()
	elif p.is_in_group("milkbowl"):
		milk = min(100, milk+20)
		p.pickup()
		emit_signal("change_milk", milk)

func add_money(m):
	upgrades.add_money(m)
	
func _on_MagnetArea_area_entered(area):
	var p = area.get_parent()
	if p.is_in_group("fish"):
		p.magnetized(self)


func _on_MagnetArea_area_exited(area):
	var p = area.get_parent()
	if p.is_in_group("fish"):
		p.demagnetized()


func _on_SwitchIdleWalkTimer_timeout():
	$SwitchIdleWalkTimer.wait_time = rand_range(0.5, 10.0)
	$SwitchIdleWalkTimer.start()
	
	if state == STATES.WALKING:
		state = STATES.IDLE
		animation.play("idle")
	elif state == STATES.IDLE:
		state = STATES.WALKING
		animation.play("walking")
		walk_motion.x *= sign(rand_range(-1,1))
