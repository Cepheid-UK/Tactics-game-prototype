extends Node

# Creates the units from the level data. Units become children of this node, and are tracked in the team_list by their team id

var Unit_scene = preload("res://Scenes/Entities/Unit.tscn")
onready var CONSTANTS = $"/root/Constants"
onready var level_data_string = str("res://Scripts/Level_Data/" + str(CONSTANTS.CURRENT_LEVEL) + ".gd")
onready var controls = $"../Controls"
var level_class 
var level_instance
var team_list : Dictionary = {}
var selected_unit


func _ready():
	level_class = load(level_data_string)
	level_instance = level_class.new()
	assert(level_instance.get_script() == level_class)
	
	init_units(CONSTANTS.CURRENT_LEVEL)
	

func init_units(current_level):
	var team_data = level_instance.get_teams()
	
	# teams are 1 = red, 2 = blue, 3 = yellow, 4 = green
	
	var index = 1
	for team_positions in team_data:
		
		var team = []
		
		var number_on_team = 1
		
		for unit_position in team_positions:
			# create individual units and add them as children to this node
			var new_unit = Unit_scene.instance()
			new_unit.set_position(unit_position * CONSTANTS.TILEMAP_CELL_SIZE_VECTOR)
			new_unit.set_team(index)
			new_unit.name = str(new_unit.get_team_colour(index)[1]) + str(number_on_team) # give nodes names e.g. 'red1', 'blue2'
			new_unit.get_child(2).connect("pressed", self, "on_unit_clicked")
			team.append(new_unit)
			add_child(new_unit)
			number_on_team += 1
			pass
		team_list[index] = team
		index += 1
		pass
	pass

func get_unit_at_coordinate(coord : Vector2):
	# if theres a unit at the coordinate, returns the unit, else returns false
	var children = get_children()
	for unit_node in get_children():
		if unit_node.get_tile_position() == coord:
			return unit_node
	return false

func get_unit_positions():
	var unit_positions_array = []
	for team in team_list.values():
		for unit in team:
			unit_positions_array.append(unit.get_tile_position())
	return unit_positions_array

func get_team_list():
	return team_list

func set_selected_unit(unit):
	selected_unit = unit

func is_unit_selected():
	return selected_unit

func on_unit_clicked():
	var mouseover = controls.get_mouseover_cell()
	
	var children = get_children()
	for child in children:
		if child.get_tile_position() == mouseover and child.is_alive():
			selected_unit = child
	pass