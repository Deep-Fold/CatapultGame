extends Label


func _ready():
	get_tree().root.get_node("/root/UnlockedUpgrades").connect("change_money", self, "_on_change_money")

func _on_change_money(m):
	text = String(m)
