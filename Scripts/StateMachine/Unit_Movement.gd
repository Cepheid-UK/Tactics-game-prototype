extends Node

onready var controls = $"../../Controls"

var clicked_location : Vector2
var unit
var timer : float
var path_start : Vector2
var path_end : Vector2

func enter(host, data):
	
	clicked_location = data[0]
	unit = data[1]
	
	controls.stop_input()
	
	timer = 0
	
	path_start = unit.get_tile_position()
	path_end = clicked_location
	
	return

func exit(host):
	controls.accept_input()
	return [unit, path_start]

func update(host, delta):
	timer += delta
	# simulate movement animation for now
	if timer > 0.25:
		if path_start and path_end:
			unit.move(path_end)
			return 'Unit_Awaiting_Orders'
	return