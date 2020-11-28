extends Node

var has_done_launch_tutorial = false
var has_done_trampoline_tutorial = false
var has_done_shop_tutorial = false
var launches = 0
var reached_moon = false

var sound = true
var music = true

onready var sound_enabled = preload("res://Game/GUI/audio-on.png")
onready var sound_disabled = preload("res://Game/GUI/audio-off.png")
onready var music_enabled = preload("res://Game/GUI/music-on.png")
onready var music_disabled = preload("res://Game/GUI/music-off.png")

var sound_bus
var music_bus

func _ready():
	# this seed has no meaning, dont convert it to anything
	seed(636174)
	sound_bus = AudioServer.get_bus_index("sound")
	music_bus = AudioServer.get_bus_index("music")

func _on_World_show_trampoline_tutorial():
	if has_done_trampoline_tutorial:
		return
	has_done_trampoline_tutorial = true
	$UI/Tutorial/DragTrampoline.visible = true
	Engine.time_scale = 0.0

func _on_World_show_launch_tutorial():
	if has_done_launch_tutorial:
		return
	has_done_launch_tutorial = true
	$UI/Tutorial/DragCat.visible = true
	$UI/Control.visible = true


func _on_World_madetrampoline():
	$UI/Tutorial/DragTrampoline.visible = false
	Engine.time_scale = 1.0

func _on_World_launched():
	launches += 1
	$UI/Tutorial/DragCat.visible = false


func _on_World_reached_moon():
	if reached_moon:
		return
	reached_moon = true
	$CanvasLayer/EndAnimation.set_launches(launches)
	$CanvasLayer/EndAnimation.visible = true
	$EndAnimation.play("fade")
	get_tree().root.get_node("/root/UnlockedUpgrades").reset()
	$ResetWorld.start()

func _on_EndAnimation_play_again():
	launches = 0
	reached_moon = false
	$EndAnimation.play_backwards("fade")
	$UI/Control/Money.text = "0"

func _on_ResetWorld_timeout():
	$GameLayer/World.reset()


func _on_World_show_shop_tutorial():
	if has_done_shop_tutorial:
		return
	has_done_shop_tutorial = true
	$UI/Tutorial/Shop.visible = true


func _on_ShopButton_pressed():
	$UI/Tutorial/Shop.visible = false


func _on_AudioToggle_pressed():
	if(sound):
		AudioServer.set_bus_volume_db(sound_bus, -80)
		$UI/AudioToggle.icon = sound_disabled
	else:
		AudioServer.set_bus_volume_db(sound_bus, 0)
		$UI/AudioToggle.icon = sound_enabled
	sound = !sound

func _on_MusicToggle_pressed():
	if(music):
		AudioServer.set_bus_volume_db(music_bus, -80)
		$UI/MusicToggle.icon = music_disabled
	else:
		AudioServer.set_bus_volume_db(music_bus, 0)
		$UI/MusicToggle.icon = music_enabled
	music = !music
