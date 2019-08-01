extends Node

# This state creates a menu for the player to select what order they want their unit to do, Wait, Attack, etc.
# the state must know what state it was last in, to know if it needs to revert a move or not when leaving.

onready var order_list_scene = preload("res://Scenes/Interface/DefaultOrdersList.tscn")
onready var attack_button_scene = preload("res://Scenes/Interface/OrderList-Attack.tscn")
onready var unit_manager = $"../../UnitManager"
onready var state_machine = $"../StateMachine"

var neighbours_NESW
var unit
var order_list

var pathed_from

var button_wait
var button_attack

func enter(host, data):
	
	button_attack = null
	
	if host.get_previous_state() == 'Unit_Selected':
		# player didnt move the unit
		unit = data[1]
		pathed_from = unit.get_tile_position()
	elif host.get_previous_state() == 'Attack_Choose':
		# player cancelled when choosing a target to attack
		pass
	else:
		# player moved the unit and is attacking
		unit = data[0]
		pathed_from = data[1]
	
	var current_team = unit.get_team()
	
	neighbours_NESW = [false,false,false,false] # North, East, South, West
	
	order_list = order_list_scene.instance()
	order_list.set_position(set_button_location())
	button_wait = order_list.get_child(0).get_child(0)
	
	add_child(order_list)
	neighbours_NESW = get_enemy_neighbours_of(current_team)
	
	var checked
	
	for element in neighbours_NESW:
		
		if checked:
			continue
		
		checked = false
		
		if element:
			order_list.get_child(0).add_child(attack_button_scene.instance())
			button_attack = order_list.get_child(0).get_child(1)
			checked = true
	return

func exit(host):
	
	for order in order_list.get_child(0).get_children():
		order.queue_free()
	
	order_list.queue_free()
	order_list = null
	
	return [unit, neighbours_NESW]

func update(host, delta):
	
	
	
	if button_wait.is_pressed():
		# WAIT
		unit.take_turn()
		return 'Idle'
	
	if button_attack and button_attack.is_pressed():
		# ATTACK
		unit.take_turn()
		return 'Attack_Choose'
	
	if Input.is_action_just_pressed("ui_rightclick"):
		unit.move(pathed_from)
		return 'Idle'
	return

func set_button_location():
	return Vector2(unit.position.x + 35, unit.position.y + 20)

func get_enemy_neighbours_of(current_team):
	
	var unit_position = unit.get_tile_position()
	var neighbours = [false, false, false, false]
	
	var unit_north = unit_manager.get_unit_at_coordinate(unit_position + Vector2(0,-1))
	var unit_east = unit_manager.get_unit_at_coordinate(unit_position + Vector2(1,0))
	var unit_south = unit_manager.get_unit_at_coordinate(unit_position + Vector2(0,1))
	var unit_west = unit_manager.get_unit_at_coordinate(unit_position + Vector2(-1,0))
	
	if unit_north and unit_north.get_team() != current_team:
		neighbours[0] = true
	if unit_east and unit_east.get_team() != current_team:
		neighbours[1] = true
	if unit_south and unit_south.get_team() != current_team:
		neighbours[2] = true
	if unit_west and unit_west.get_team() != current_team:
		neighbours[3] = true
	
	return neighbours