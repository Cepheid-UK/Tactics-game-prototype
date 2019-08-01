extends Node2D

# this class is for doing a floodfill calculation where you need to track the parent of a tile.

# Floodfill is implemented here with breadth first search and each time a new node is added to the queue,
# the parent it came from is stored in this object. Then when calculating if a tile is reachable,
# the algorithm can get the recursive parents

class_name Floodnode

var parent : Floodnode

func _init(pos,par = null):
	position = pos
	parent = par

func set_parent(par):
	parent = par

func get_parent():
	return parent

func set_position(pos):
	position = pos

func get_position():
	return position

func has_parent():
	if parent:
		return true
	else:
		return false