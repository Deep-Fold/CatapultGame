extends Node

signal upgraded
signal change_money

#why is the money var here? idk
var money = 0

var upgrades = {
	#there were gonna be more cats, but I got too lazy to add them.
	"cats": [
		{"unlocked": true, "price": 0, "value": preload("res://Game/World/Cats/Olin/Olin.tscn")},
		{"unlocked": false, "price": 50, "value": preload("res://Game/World/Cats/Olin/Olin.tscn")},
		{"unlocked": false, "price": 100, "value": preload("res://Game/World/Cats/Olin/Olin.tscn")},
		{"unlocked": false, "price": 200, "value": preload("res://Game/World/Cats/Olin/Olin.tscn")},
		{"unlocked": false, "price": 300, "value": preload("res://Game/World/Cats/Olin/Olin.tscn")}
	],
	"milk_spawn_chance": [
		{"unlocked":true, "price": 0, "value": 0.0015},
		{"unlocked":false,"price": 225, "value": 0.0025},
		{"unlocked":false,"price": 350, "value": 0.0035},
		{"unlocked":false,"price": 450, "value": 0.0045}
	],
	"money_spawn_chance": [
		{"unlocked":true, "price": 0, "value": 0.03},
		{"unlocked":false,"price": 175, "value": 0.05},
		{"unlocked":false,"price": 350, "value": 0.07},
		{"unlocked":false,"price": 600, "value": 0.09}
	],
	"trampoline_strength": [
		{"unlocked":true, "price": 0, "value": 1.1},
		{"unlocked":false,"price": 150, "value": 1.2},
		{"unlocked":false,"price": 300, "value": 1.3},
		{"unlocked":false,"price": 550, "value": 1.4}
	],
	"catapult_height": [
		{"unlocked":true, "price": 0, "value": 135},
		{"unlocked":false,"price": 75, "value": 127},
		{"unlocked":false,"price": 175, "value": 120},
		{"unlocked":false,"price": 275, "value": 115}
	],
	"catapult_strength": [
		{"unlocked":true, "price": 0, "value": 1.1},
		{"unlocked":false,"price": 250, "value": 1.35},
		{"unlocked":false,"price": 400, "value": 1.75},
		{"unlocked":false,"price": 650, "value": 2.0}
	],
	"magnet_strength": [
		{"unlocked":true, "price": 0, "value": 1.0},
		{"unlocked":false,"price": 50, "value": 2.0},
		{"unlocked":false,"price": 175, "value": 3.0},
		{"unlocked":false,"price": 400, "value": 5.0}
	]
}

func get_money():
	return money

func add_money(m):
	money += m
	emit_signal("change_money", money)

func buy_upgrade(upgr):
	if can_unlock_next_upgrade(upgr):
		var next = get_next_upgrade(upgr)
		money -= next.price
		next.unlocked = true
		emit_signal("upgraded")
		emit_signal("change_money", money)

func can_unlock_next_upgrade(upgr):
	var next = get_next_upgrade(upgr)
	if next != null:
		return money >= next.price
	return false

func get_unlocked_count(upgr):
	var upgrade = upgrades[upgr]
	var count = 0
	for u in upgrade:
		if u.unlocked:
			count += 1
	return count

func get_next_upgrade(upgr):
	var upgrade = upgrades[upgr]
	for u in upgrade:
		if !u.unlocked:
			return u

func get_upgrade_value(upgr):
	var upgrade = upgrades[upgr]
	for i in range(upgrade.size()-1, -1,-1):
		if upgrade[i].unlocked:
			return upgrade[i].value

func reset():
	money = 0
	for k in upgrades.keys():
		for i in upgrades[k].size():
			if i != 0:
				upgrades[k][i].unlocked = false
			
