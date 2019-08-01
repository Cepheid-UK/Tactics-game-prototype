extends Node

# default state for a player if they are not doing anything that requires a state. Other states revert to this.

onready var controls = $"../../Controls"
onready var unit_manager = $"../../UnitManager"
onready var turn_manager = $"../../TurnManager"

var fight_ended : bool = false
var turn_ended : bool = false
var active_team : int

func enter(host, data):
	#turn_ended = is_turn_ended()
	#fight_ended = is_fight_finished()
	return

func exit(host):
	# send the location of the clicked tile to the next state
	return controls.get_last_clicked_tile()

func update(host, delta):
	
	if fight_ended:
		return 'End_Fight'
	
	if turn_ended:
		return 'End_Turn'
	
	if controls.is_accepting_input():
		if Input.is_action_just_released("ui_leftclick"):
			var unit = unit_manager.get_unit_at_coordinate(controls.get_last_clicked_tile())
			if unit and unit.get_team() == turn_manager.get_active_team():
				if !unit.turn_taken():
					return 'Unit_Selected'

func _on_animation_finished(anim_name):
	return