extends Node

onready var unit_manager = $"../UnitManager"
var active_team : int
var number_of_teams : int = 4

func _ready():
	active_team = 1
	pass

func get_active_team():
	return active_team

func next_active_team():
	
	if active_team == 1:
		active_team = 2
		return active_team
	active_team = 1
	return active_team
	

func _process(delta):
	pass