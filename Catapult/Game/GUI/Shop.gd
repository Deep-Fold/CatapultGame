extends VBoxContainer

signal close

onready var upgrades = get_tree().root.get_node("/root/UnlockedUpgrades")
onready var cats = $Row4/Cats
onready var milkpower = $Row/MilkPower
onready var milkspawn = $Row/MilkSpawn
onready var moneyspawn = $Row2/FishSpawn
onready var magnet = $Row2/Magnet
onready var catapultsize = $Row3/CatapultSize
onready var catapultpower = $Row3/CatapultPower
onready var money = $HBoxContainer/MoneyLabel

func _ready():
	update_shop()

func update_shop():
	money.text = "     x"+String(upgrades.get_money())
	
	set_node_stats(cats, "cats")
	set_node_stats(milkpower, "trampoline_strength")
	set_node_stats(milkspawn, "milk_spawn_chance")
	set_node_stats(moneyspawn, "money_spawn_chance")
	set_node_stats(magnet, "magnet_strength")
	set_node_stats(catapultsize, "catapult_height")
	set_node_stats(catapultpower, "catapult_strength")

func set_node_stats(node, upgr):
	node.set_unlocked_count(upgrades.get_unlocked_count(upgr))
	node.set_can_buy(upgrades.can_unlock_next_upgrade(upgr))
	var next = upgrades.get_next_upgrade(upgr)
	if next != null:
		node.set_price(next.price)
	else:
		node.set_price(0)
	node.set_upgrade_code(upgr)
	
	if !node.is_connected("pressed", self, "on_upgrade_pressed"):
		node.connect("pressed", self, "on_upgrade_pressed")

func on_upgrade_pressed(upgr):
	upgrades.buy_upgrade(upgr)
	update_shop()


func _on_BackButton_pressed():
	emit_signal("close")
