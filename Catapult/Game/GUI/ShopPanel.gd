extends Panel

onready var shopbutton = get_parent().get_node("ShopButton")
onready var money = get_parent().get_node("Money")

func _ready():
	$Shop.connect("close", self, "_on_shop_close")

func _on_ShopButton_pressed():
	visible = true
	$Shop.update_shop()
	shopbutton.visible = false
	money.visible = false

func _on_shop_close():
	visible = false
	shopbutton.visible = true
	money.visible = true

func _on_World_show_milk_bar():
	shopbutton.visible = false

func _on_World_hide_milk_bar():
	shopbutton.visible = true
