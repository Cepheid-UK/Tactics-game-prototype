extends Node

# FINITE STATE MACHINE

# The responsibility of this class is to define what states exist and to handle the changing of states when instructed
# by the current state to change. All states exit and enter with a data variable, this data contains information that
# the state needs to do it's job and is unpacked in the enter() method, and passed on from the exit() method.

# if the update function returns a string, e.g. "Idle" or "Unit_Selected" that will be the new state
# if it returns null, it continues to act on the same state

var state = null
var last_state = null

var states = {}

func _ready():
	
	# creates a dictionary of all the states, using the children of this node
	# using the name of the node as a key, and the node reference as a value like {name : node}
	# e.g. {'Idle' : $"Idle"}
	
	var children = get_children()
	for node in children:
		states[node.name] = node
	
	# initiate as 'Idle'
	state = states['Idle']
	print('State initiated as: ' + str(state.name))

func _process(delta):
	
	var state_name = state.update(self, delta)
	if state_name:
		change_state(state_name)

func get_previous_state():
	return last_state

func get_state_list():
	return states

func change_state(new_state):
	
	if state:
		last_state = states[state.name].name
	
	var passed_data = state.exit(self)
	
	state = states[new_state]
	print("changed state to: " + str(state.name))
	
	state.enter(self, passed_data)
