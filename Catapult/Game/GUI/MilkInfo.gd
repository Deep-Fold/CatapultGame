extends Control

onready var texture_progress = $TextureProgress


func _on_World_update_milk(m):
	texture_progress.value = m

func _on_World_show_milk_bar():
	visible = true

func _on_World_hide_milk_bar():
	visible = false
