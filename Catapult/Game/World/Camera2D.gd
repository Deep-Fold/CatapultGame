extends Camera2D

signal track_object_fallen
signal change_height
signal cat_falling

enum STATES {IDLE, TRACKING}
var state = STATES.IDLE
var track_object = null
var lowest_y = 75

func track(object):
	state = STATES.TRACKING
	track_object = object
	lowest_y = 75

func go_idle():
	state = STATES.IDLE

func reset():
	lowest_y = 75
	track_object = null
	position.y = 75

func _physics_process(_delta):
	if state == STATES.TRACKING:
		if track_object.position.y > lowest_y && lowest_y < -200:
			emit_signal("cat_falling")
		
		lowest_y = min(lowest_y, track_object.position.y)
		position.y = lowest_y
		emit_signal("change_height", position.y)
		
		if track_object.position.y - lowest_y > 100:
			emit_signal("track_object_fallen")
