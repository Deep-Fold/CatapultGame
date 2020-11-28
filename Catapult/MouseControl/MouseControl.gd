extends Node

enum STATES {MENU, IDLE, CAT_GRAB, CATAPULT, FLYING}
var state = STATES.IDLE
var held_cat = null

func set_state_menu():
	state = STATES.MENU

func set_state_idle():
	state = STATES.IDLE

func set_state_catapult():
	state = STATES.CATAPULT

func set_state_flying():
	state = STATES.FLYING

func set_state_cat_grab():
	state = STATES.CAT_GRAB

func set_held_cat(c):
	held_cat = c

func get_held_cat():
	return held_cat

func is_idle():
	return state == STATES.IDLE

func is_catapult():
	return state == STATES.CATAPULT

func is_cat_grab():
	return state == STATES.CAT_GRAB
