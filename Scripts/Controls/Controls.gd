extends Node

onready var CONSTANTS = $"/root/Constants"

# Input controller - if the player presses a button and input is currently being accepted, and it's not too soon after the last
# input, this node will emit a signal.

const TIMELIMIT = 0.25
var wait = 0
var accepting_input = true
var last_clicked_tile : Vector2
var this_frame_click

signal ui_left_just_pressed
signal ui_right_just_pressed
signal ui_up_just_pressed
signal ui_down_just_pressed
signal ui_leftclick_just_pressed

func _ready():
	pass

func _process(delta):
	
	if wait < TIMELIMIT:
		wait += delta
	
	if accepting_input:
		process_input()
		wait = 0

func is_accepting_input():
	return accepting_input

func stop_input():
	accepting_input = false

func accept_input():
	accepting_input = true

func process_input():
	
	# eventually these signals can reference data loaded from a config file, allowing for remappable buttons
	
	if Input.is_action_just_pressed("ui_left"):
		emit_signal("ui_left_just_pressed")
	
	if Input.is_action_just_pressed("ui_right"):
		emit_signal("ui_right_just_pressed")
	
	if Input.is_action_just_pressed("ui_up"):
		emit_signal("ui_up_just_pressed")
	
	if Input.is_action_just_pressed("ui_down"):
		emit_signal("ui_down_just_pressed")
	
	if Input.is_action_just_pressed("ui_leftclick"):
		if wait > TIMELIMIT:
			this_frame_click = get_mouse_click_cell()
		emit_signal("ui_leftclick_just_pressed")
		last_clicked_tile = convert_mouseover_to_cell()

func get_this_frame_click():
	return this_frame_click

func get_mouseover_cell():
	return convert_mouseover_to_cell()

func get_mouse_click_cell():
		return get_last_clicked_tile()

func get_last_clicked_tile():
	return last_clicked_tile

func convert_mouseover_to_cell():
	# converts mouse click coordinates to tile coordinates (takes into account panned camera)
	var mouse_pos = get_viewport().get_mouse_position()
	var camera_loc = $"../Battle_Camera".get_camera_location()
	
	var mouse_vector = (camera_loc + mouse_pos) / CONSTANTS.TILEMAP_CELL_SIZE
	
	var mouse_x : int
	mouse_x = mouse_vector.x + camera_loc.x
	var mouse_y : int
	mouse_y = mouse_vector.y + camera_loc.y
	
	return Vector2(mouse_x, mouse_y)