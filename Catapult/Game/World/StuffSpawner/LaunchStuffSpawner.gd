extends Node2D

onready var upgrades = get_tree().root.get_node("/root/UnlockedUpgrades")
onready var milk_bowl = preload("res://Game/World/StuffSpawner/Stuff/MilkBowl/MilkBowl.tscn")
onready var money_fish = preload("res://Game/World/StuffSpawner/Stuff/MoneyFish/MoneyFish.tscn")
onready var money_worth_3 = preload("res://Game/GUI/fish2.png")
onready var money_worth_5 = preload("res://Game/GUI/fish1.png")
onready var sound_worth_3 = preload("res://Game/World/StuffSpawner/Stuff/MoneyFish/fish1.wav")
onready var sound_worth_5 = preload("res://Game/World/StuffSpawner/Stuff/MoneyFish/fish3.wav")
onready var bumper = preload("res://Game/World/StuffSpawner/Stuff/Bumper/Bumper.tscn")
onready var brick = preload("res://Game/World/StuffSpawner/Stuff/Brick/Brick.tscn")
onready var cloud = preload("res://Game/World/StuffSpawner/Stuff/Clouds/Cloud.tscn")
onready var booster = preload("res://Game/World/StuffSpawner/Stuff/Booster/Booster.tscn")

const screen_height = 150
const screen_width = 100
const moon_height = 15000.0
enum STATES {IDLE, ACTIVE}
var state = STATES.IDLE

var previous_height = screen_height*.5
var money_chance = 0
var milk_chance = 0

var height_since_cloud_spawn = 0
var height_since_brick_spawn = 0
var height_since_booster_spawn = 0

func go_active():
	state = STATES.ACTIVE
	money_chance = upgrades.get_upgrade_value("money_spawn_chance")
	milk_chance = upgrades.get_upgrade_value("milk_spawn_chance")

func go_idle():
	state = STATES.IDLE
	for c in get_children():
		c.queue_free()

func _random_stuff_position(height_diff = 0):
	return Vector2(rand_range(5.0, screen_height-5.0), -screen_height - rand_range(0.0, height_diff))

func _on_Camera2D_change_height(h):

	if state == STATES.ACTIVE:
		var height_normal = -h/moon_height
		
		var diff = h-previous_height
		previous_height = h
		height_since_brick_spawn += abs(diff)
		height_since_cloud_spawn += abs(diff)
		height_since_booster_spawn += abs(diff)
		for i in int(ceil(abs(diff))):
			if rand_range(0.0, 1.0) < money_chance:
				call_deferred("_spawn_money",diff,h)
			if rand_range(0.0, 1.0) < milk_chance:
				call_deferred("_spawn_milk", diff, h)
		
		if h < -200 && height_since_booster_spawn > 200 && rand_range(0.0, 1.0) < 0.01:
			_spawn_booster(h)
		
		if h < -800 && height_since_cloud_spawn > 100 && rand_range(0.0, 1.0) < (0.01 + height_normal*0.03):
			_spawn_cloud(h)
		
		if  h < -1500 && height_since_brick_spawn > 500 && rand_range(0.0, 1.0) < (0.01 + height_normal*0.03):
			_spawn_brick_group(h)
			#_spawn_bumper_group(h, randi()%2+3)

func _spawn_booster(height):
	height_since_booster_spawn = 0
	var b = booster.instance()
	b.position = Vector2(0,height)-Vector2(0,200)+_random_stuff_position()
	add_child(b)

func _spawn_cloud(height):
	height_since_cloud_spawn = 0
	var c = cloud.instance()
	c.position = Vector2(0,height)-Vector2(0,200)+_random_stuff_position()
	add_child(c)


func _spawn_milk(diff, height):
	var pos = Vector2(0,height)+_random_stuff_position(diff)
	var m = milk_bowl.instance()
	m.position = pos
	add_child(m)

func _spawn_brick_group(height):
	height_since_brick_spawn = 0
	if rand_range(0.0, 1.0) > 0.5:
		_spawn_closed_brick_group(height)
	else:
		_spawn_open_brick_group(height)

func _spawn_open_brick_group(height):
	for y in randi()%2+1:
		for x in 3:
			var b = brick.instance()
			b.position = Vector2(40*x, height + 7*y) + Vector2(20*y, -200)
			add_child(b)

func _spawn_closed_brick_group(height):
	for x in 5:
		var b = brick.instance()
		b.position = Vector2(20*x, height -200)
		add_child(b)

func _spawn_bumper_group(height, amount):
	var center_pos = Vector2(rand_range(10.0, screen_width-10.0),height-200)
	var distance = rand_range(10.0, 30.0)
	for i in amount:
		var divider =float(i+1)/float(amount)
		var pos = center_pos + Vector2(distance,0).rotated((PI)/divider)
		var b = bumper.instance()
		b.position = pos
		add_child(b)

func _spawn_money(diff, height):
	var pos = Vector2(0,height)+_random_stuff_position(diff)
	var m = money_fish.instance()
	m.position = pos
	
	if (rand_range(0.0,1.0) < -height/8000.0):
		m.set_worth(3)
		m.set_texture(money_worth_3)
		m.set_sound(sound_worth_3)
	if (rand_range(0.0,1.0) < -height/25000.0):
		m.set_worth(5)
		m.set_texture(money_worth_5)
		m.set_sound(sound_worth_5)
	
	add_child(m)
