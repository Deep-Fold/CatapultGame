extends Node2D

signal update_milk
signal hide_milk_bar
signal show_milk_bar
signal show_launch_tutorial
signal show_trampoline_tutorial
signal show_shop_tutorial
signal launched
signal madetrampoline
signal reached_moon

var first_launch = true
onready var upgrades = get_tree().root.get_node("/root/UnlockedUpgrades")
onready var mousestate = get_tree().root.get_node("/root/MouseControl")
onready var camera = $Camera2D
onready var tween = $Tween
onready var moon_sprite = $CanvasLayer/moon
onready var line_drawer = $BounceLineDrawer
onready var stuff_spawner = $LaunchStuffSpawner

const moon_height = 15000.0
var height_achieved = 0.0

func _ready():
	$OpeningAnimation.play("intro")
	$Catapult.connect("launch_cat", self, "_on_catapult_launch_cat")
	camera.connect("track_object_fallen", self, "_on_camera_track_object_fallen")
	_connect_cat_signals()

func _on_catapult_launch_cat(launch_vec):
	emit_signal("launched")
	var cat = mousestate.get_held_cat()
	cat.launch(-launch_vec*10.0*upgrades.get_upgrade_value("catapult_strength"))
	emit_signal("update_milk", cat.get_milk())
	emit_signal("show_milk_bar")
	line_drawer.update_cat_milk(cat.get_milk())
	camera.track(cat)
	line_drawer.go_active()
	stuff_spawner.go_active()
	tween.remove(camera, "reset")
	#$LaunchMusic.play()
	#$CalmMusic.stop()
	if first_launch:
		$LaunchMusic.play()
		first_launch = false
	
	$CalmMusic.volume_db = -80
	$LaunchMusic.volume_db = 0

func _on_camera_track_object_fallen():
	for b in get_tree().get_nodes_in_group("booster"):
		b.queue_free()
	
	_move_cam_down()
	var cat = mousestate.get_held_cat()
	height_achieved = cat.position.y
	cat.position.y = max(cat.position.y, -50)
	$CatFall.play()

func _move_cam_down():
	camera.go_idle()
	tween.interpolate_property(camera, "position:y", camera.position.y, 75.0, 1.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.interpolate_callback(camera, 1.5, "reset")
	tween.interpolate_method(self, "change_moon_size", camera.position.y, 75.0, 1.5, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.start()

func disable_trampolines():
	line_drawer.disable()
	for c in $Trampolines.get_children():
		c.queue_free()

func change_moon_size(height):
	var interpol_val = clamp(-height/moon_height,0.0,1.0)
	moon_sprite.frame = round(lerp(0, 8, interpol_val))
	moon_sprite.position.x = lerp(65, 50, interpol_val)
	moon_sprite.position.y = lerp(29, 75, interpol_val)

func _on_Camera2D_change_height(height):
	change_moon_size(height)
	
	if -height > moon_height:
		_reached_moon()

func _reached_moon():
	emit_signal("reached_moon")
	camera.go_idle()

func _on_BounceLineDrawer_remove_milk(amount):
	var cat = mousestate.get_held_cat()
	cat.remove_milk(amount)
	line_drawer.update_cat_milk(cat.get_milk())

func _on_BounceLineDrawer_visual_change_milk(amount):
	var cat = mousestate.get_held_cat()
	var current_milk = cat.milk - amount
	
	emit_signal("update_milk", current_milk)

func _connect_cat_signals():
	for c in $Cats.get_children():
		if !c.is_connected("landed", self, "_on_cat_land"):
			c.connect("landed", self, "_on_cat_land")
		if !c.is_connected("change_milk", self, "_on_cat_change_milk"):
			c.connect("change_milk", self, "_on_cat_change_milk")

func _on_cat_change_milk(milk):
	line_drawer.update_cat_milk(milk)
	emit_signal("update_milk", milk)

func _on_cat_land():
	_move_cam_down()
	disable_trampolines()
	emit_signal("hide_milk_bar")
	emit_signal("show_shop_tutorial")
	stuff_spawner.go_idle()
	
	#$LaunchMusic.stop()
	#$CalmMusic.play()
	$CalmMusic.volume_db = 0
	$LaunchMusic.volume_db = -80
	
	if !just_reset:
		$HideHeight.start()
		$Control/VBoxContainer/HowFar.text = String(-int(height_achieved))+"m"
		$Control/VBoxContainer/ToGo.text = String(int(moon_height+height_achieved))+"m"
		$Control.visible = true
	else:
		just_reset = false


func _on_HideHeight_timeout():
	$Control.visible = false


func _on_AnimationOver_timeout():
	$Cats/Cat.start()
	emit_signal("show_launch_tutorial")


func _on_BounceLineDrawer_made_trampoline():
	emit_signal("madetrampoline")


func _on_Camera2D_cat_falling():
	emit_signal("show_trampoline_tutorial")

var just_reset = false
func reset():
	$CalmMusic.volume_db = 0
	$LaunchMusic.volume_db = -80
	just_reset = true
	_on_camera_track_object_fallen()
	var cat = mousestate.get_held_cat()
	cat.position.y = 140
	$Catapult.check_upgrades()
	first_launch = true
