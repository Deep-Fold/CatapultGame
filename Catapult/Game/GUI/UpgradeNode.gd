extends VBoxContainer

signal pressed

var upgrade_code = ""
onready var checkboxes = $Panel/HBoxContainer
onready var check_texture = preload("res://Game/GUI/upgrade-checked.png")
onready var uncheck_texture = preload("res://Game/GUI/upgrade-unchecked.png")

func set_unlocked_count(count):
	var index = 0
	for c in checkboxes.get_children():
		if index < count:
			c.texture = check_texture
		else:
			c.texture = uncheck_texture
		index +=1

func set_can_buy(can_buy):
	$Panel/Button.disabled = !can_buy

func set_price(p):
	if p>0:
		$Panel/Button.text = "x"+String(p)
	else:
		$Panel/Button.text = ""
		$Panel/Button.disabled = true
		

func set_upgrade_code(c):
	upgrade_code = c

func _on_Button_pressed():
	emit_signal("pressed", upgrade_code)
	$AudioStreamPlayer.play()
