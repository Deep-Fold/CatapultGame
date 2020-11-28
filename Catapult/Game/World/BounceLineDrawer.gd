extends Node2D

signal remove_milk
signal visual_change_milk
signal made_trampoline

onready var line = $Line2D
onready var outline = $Outline
onready var trampoline = preload("res://Game/World/Trampoline/Trampoline.tscn")
onready var trampoline_holder = get_parent().get_node("Trampolines")

const milk_per_length = 1.0
var current_length = 0

enum STATES {DISABLED, IDLE, DRAWING}
var state = STATES.DISABLED
var draw_point = Vector2()
var camera_height = 0
var screen_height = 150

var cat_current_milk = 100


func go_active():
	state = STATES.IDLE


func disable():
	state = STATES.DISABLED
	line.points[0] = Vector2.ZERO
	line.points[1] = Vector2.ZERO
	outline.points[1] = Vector2.ZERO

func _input(event):
	if event is InputEventScreenTouch:
		if state == STATES.IDLE && event.pressed:
			_start_draw()
		if state == STATES.DRAWING && !event.pressed:
			_stop_draw()

func _start_draw():
	state = STATES.DRAWING
	draw_point = get_global_mouse_position()
	line.global_position = draw_point + Vector2(0,camera_height-.5*screen_height)
	outline.global_position = draw_point + Vector2(0,camera_height-.5*screen_height)
	line.points[1] = Vector2.ZERO
	outline.points[1] = Vector2.ZERO

func _physics_process(_delta):
	match state:
		STATES.IDLE:
			if Input.is_action_just_pressed("mouse_left"):
				_start_draw()
		STATES.DRAWING:
			_draw_trampoline_line()
			if Input.is_action_just_released("mouse_left"):
				_stop_draw()

func _stop_draw():
	state = STATES.IDLE
	_make_trampoline(line.global_position, line.points[1])
	emit_signal("remove_milk", current_length/milk_per_length)

func _draw_trampoline_line():
	if cat_current_milk < 1.0:
		return
	
	line.global_position = draw_point + Vector2(0,camera_height-.5*screen_height)
	outline.global_position = draw_point + Vector2(0,camera_height-.5*screen_height)
	current_length = (get_global_mouse_position() - draw_point).length()
	var actual = (get_global_mouse_position() - draw_point).normalized()
	
	if cat_current_milk < current_length * milk_per_length:
		actual *= cat_current_milk / milk_per_length
		emit_signal("visual_change_milk", cat_current_milk)
	else:
		actual *= current_length
		emit_signal("visual_change_milk", current_length/milk_per_length)
	
	line.points[1] = actual
	outline.points[1] = actual


func _make_trampoline(where, size):
	line.points[0] = Vector2.ZERO
	line.points[1] = Vector2.ZERO
	outline.points[1] = Vector2.ZERO
	var t = trampoline.instance()
	trampoline_holder.add_child(t)
	t.global_position = where
	t.set_length(size)
	emit_signal("made_trampoline")

func _on_Camera2D_change_height(h):
	camera_height = h

func update_cat_milk(m):
	cat_current_milk = m
	
