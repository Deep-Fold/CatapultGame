extends Node2D

signal launch_cat

onready var upgrades = get_tree().root.get_node("/root/UnlockedUpgrades")
onready var mousestate = get_tree().root.get_node("/root/MouseControl")
onready var line = $Line2D
onready var tween = $Tween
onready var pullbox = $PullStartBox

enum STATES {IDLE, PULLED,CAT_PULLED,RELEASED}
var state = STATES.IDLE
var max_length = 35


func _ready():
	upgrades.connect("upgraded", self, "check_upgrades")

func check_upgrades():
	position.y = upgrades.get_upgrade_value("catapult_height")
	max_length = 140-line.global_position.y

func _on_PullStartBox_input_event(_viewport, event, _shape_idx):
	if state == STATES.IDLE:
		if event is InputEventMouseMotion && mousestate.is_cat_grab():
			_pull_cat()
		
		if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
			if event.pressed && mousestate.is_idle():
				_pull()

func set_center_string(pos):
	line.points[1] = pos
	pullbox.position = pos + line.position

func _input(event):
	if event is InputEventScreenTouch && mousestate.is_catapult():
		call_deferred("_release")

func _physics_process(_delta):
	if Input.is_action_just_released("mouse_left") && mousestate.is_catapult():
		if (state == STATES.PULLED || state == STATES.CAT_PULLED):
			_release()
	
	if state == STATES.PULLED || state == STATES.CAT_PULLED:
		_pull_line()

func _pull_line():
	var pull_pos = get_global_mouse_position() - global_position - line.position
	var length = pull_pos.length()
	if length > max_length:
		pull_pos = pull_pos.normalized()*max_length

	line.points[1] = pull_pos
	pullbox.position = pull_pos + line.position
	
	if state == STATES.CAT_PULLED:
		mousestate.get_held_cat().global_position = pull_pos + position + line.position

func set_state_idle():
	state = STATES.IDLE
	mousestate.set_state_idle()

func _release():
	if state == STATES.CAT_PULLED:
		_launch_cat()
	
	state = STATES.RELEASED
	#tween.interpolate_method(self, "set_center_string", line.points[1], Vector2.ZERO, 0.05,Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_method(self, "set_center_string", line.points[1], Vector2.ZERO, 0.2,Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_callback(self, 0.2, "set_state_idle")
	tween.start()
	$AudioStreamPlayer2D.play()
	#pullbox.position = Vector2(0,-34)

func _launch_cat():
	mousestate.set_state_flying()
	var launch_vec = line.points[1]
	emit_signal("launch_cat", launch_vec)

func _pull_cat():
	mousestate.set_state_catapult()
	state = STATES.CAT_PULLED
	mousestate.get_held_cat().set_state_seated()

func _pull():
	mousestate.set_state_catapult()
	state = STATES.PULLED
