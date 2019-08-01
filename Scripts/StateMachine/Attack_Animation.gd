extends Node

# This state handles the animation and the logic for a unit attacking another unit.

func enter(host, data):
	print(data)
	return

func exit(host):
	return

func update(host, delta):
	
	if Input.is_action_just_pressed("ui_rightclick"):
		return 'Idle'
	
	return