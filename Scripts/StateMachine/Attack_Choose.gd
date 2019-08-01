extends Node

onready var unit_manager = $"../../UnitManager"
onready var target_reticule_scene = preload("res://Scenes/Interface/Attack_Target.tscn")
onready var CONSTANTS = $"/root/Constants"
onready var controls = $"../../Controls"

# Player has chosen the "Attack" option, but not yet confirmed which target they want to attack.
# This state handles the target selection.

# ---------------------------------------------------------------
# IN THIS STATE:
# Get the position for the unit attacking
# find out how many target options the unit has (Ideally not just melee targets)
# create a texture button for each unit (positioned over them) and connect the signal to the unit it sits over.
# when the texture button is clicked, emit the relevent signal and return the 'Attack_Animation' state
#	pass the data of the [unit_attacking, unit_defending] to the next state
# allow the user to cancel back to the Unit_Awaiting_Orders state if they instead right click.
# ---------------------------------------------------------------

var unit
var neighbours_NESW
var unit_neighbours
var mouse_tile = null
var unit_clicked

func enter(host, data):
	
	# data = [unit, neighbours_NESW] - from Unit_Awaiting_Orders
	
	unit = data[0]
	neighbours_NESW = data[1]
	
	mouse_tile = null
	
	unit_neighbours = []
	
	for i in range (neighbours_NESW.size()+1):
		var direction : Vector2 = Vector2(0,0)
		
		if i == 0:
			continue
		if i == 1:
			# NORTH
			direction = Vector2(0,-1)
		if i == 2:
			# EAST
			direction = Vector2(1,0)
		if i == 3:
			# SOUTH
			direction = Vector2(0,1)
		if i == 4:
			# WEST
			direction = Vector2(-1,0)
		
		if neighbours_NESW[i-1]:
			unit_neighbours.append(unit_manager.get_unit_at_coordinate(unit.get_tile_position() + direction))
	
	for unit_neighbour in unit_neighbours:
		var target_reticule = target_reticule_scene.instance()
		target_reticule.set_position(unit_neighbour.position)
		target_reticule.set_size(CONSTANTS.TILEMAP_CELL_SIZE_VECTOR)
		target_reticule.connect("button_up", self, "on_target_select")
		add_child(target_reticule)
	
	for child in get_children():
		child.set_size(CONSTANTS.TILEMAP_CELL_SIZE_VECTOR)
	return

func exit(host):
	
	if get_child(0):
		for child in get_children():
			child.queue_free()
	
	return [unit, unit_clicked]

func update(host, delta):
	
	if mouse_tile:
		unit_clicked = unit_manager.get_unit_at_coordinate(controls.convert_mouseover_to_cell())
		return 'Attack'
	
	if Input.is_action_just_pressed("ui_rightclick"):
		for child in get_children():
			child.queue_free()
		unit.reset_turn()
		unit_clicked = unit_manager.get_unit_at_coordinate(controls.convert_mouseover_to_cell())
		return 'Unit_Awaiting_Orders'
	return

func on_target_select():
	mouse_tile = controls.convert_mouseover_to_cell()