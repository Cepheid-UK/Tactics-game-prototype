extends Node

onready var terrain_tiles = $"../../../TerrainTiles"
onready var unit_manager = $"../../../UnitManager"
onready var map_size = terrain_tiles.get_used_rect().end
var astar = AStar.new()
var obstacles
var path_start_pos
var path_end_pos
var unit

func _ready():
	obstacles = terrain_tiles.get_obstacles()

func pathfind(from, to):
	
	unit = unit_manager.get_unit_at_coordinate(from)
	
	path_start_pos = from
	path_end_pos = to
	
	var max_potential_moves = []
	
	var nodes = flood_fill_from(from,unit.get_move_budget())
	
	for node in nodes:
		max_potential_moves.append(node.position)
	a_star_connect_walkable_tiles(a_star_walkable_tiles(max_potential_moves))
	
	var path = calculate_path()
	path.remove(0)
	
	return path

# determines all the tiles that are walkable, is passed all the tiles from the floodfill BFS as possible tiles.
# A* requires indexes of tiles, and this function calls the calculation then assigns the indexes to all the acceptable tiles.
func a_star_walkable_tiles(movement_tiles):
	
	astar.clear()
	var points_array = []
	
	if movement_tiles:
		for tile in movement_tiles:
			if obstacles.has(tile) and tile != unit.get_tile_position():
				continue
			var tile_index = calculate_point_index(tile)
			astar.add_point(tile_index,Vector3(tile.x, tile.y, 0.0))
			points_array.append(tile)
	else:
		return
	
	return points_array

# calculates all the indexes of the tiles as required for A*
func calculate_point_index(point):
	return point.x + map_size.x * point.y

# creates connections between nodes, using manhattan geometry, also checks none of the tiles are out of bounds
func a_star_connect_walkable_tiles(movement_tiles):
	for tile in movement_tiles:
		var tile_index = calculate_point_index(tile)
		var points_relative = PoolVector2Array([
			Vector2(tile.x + 1, tile.y),
			Vector2(tile.x - 1, tile.y),
			Vector2(tile.x, tile.y + 1),
			Vector2(tile.x, tile.y - 1)])
		for relative_point in points_relative:
			var point_relative_index = calculate_point_index(relative_point)
			
			if relative_point == tile or is_outside_map_bounds(relative_point):
				continue
			if not astar.has_point(point_relative_index):
				continue
			astar.connect_points(tile_index, point_relative_index, true)

# gets indexes for the start and end tiles, then calls the A* get_point_path() method with those values. returns the resulting path.
# once pathfind() has been done, this is the only methods required to re-calculate a path on the same tiles.
# NOTE: this returns the starting tile also, so path.remove(0) earlier will prevent the starting node from displaying the path.
func calculate_path():
	var start_point_index = calculate_point_index(path_start_pos)
	var end_point_index = calculate_point_index(path_end_pos)
	var point_path = astar.get_point_path(start_point_index, end_point_index)
	return point_path

# Self-explanatory method.
func is_outside_map_bounds(tile):
	return tile.x < 0 or tile.y < 0 or tile.x >= map_size.x or tile.y >= map_size.y

# This recursively checks that nodes have parents then adds them to an array, this is used in the Floodfill BFS.
# The purpose is to determine how many tiles from the starting position to calculate, and therefore limit to the unit's move budget.
func get_ancestors(node):
	
	var ancestors = []
	
	while node.parent:
		node = node.parent
		ancestors.append(node)
	
	return ancestors

# calculates all the neighbours of a tile (within the map bounds) in order North-West-South-East, returns as an array.
func get_node_neighbours(node):
	
	var nodes = []
	var map_limit_x = terrain_tiles.get_used_rect().size.x
	var map_limit_y = terrain_tiles.get_used_rect().size.y
	
	# if statements check if the node is within the map boundaries, this only works for rectangular tilempas
	if node.position.y - 1 >= 0:
		nodes.append(Floodnode.new(Vector2(node.position.x,node.position.y-1),node))
	if node.position.x + 1 < map_limit_x:
		nodes.append(Floodnode.new(Vector2(node.position.x+1,node.position.y),node))
	if node.position.y + 1 < map_limit_y:
		nodes.append(Floodnode.new(Vector2(node.position.x,node.position.y+1),node))
	if node.position.x - 1  >= 0:
		nodes.append(Floodnode.new(Vector2(node.position.x-1,node.position.y),node))
	
	return nodes

# Floodfill BFS, this uses a custom class "Floodnode" to track the number of parents to limit the fill area.
# e.g. if a node has 9 ancestors (get_parent().get_parent().get...), and the move_limit is 8, that node will not be counted.
func flood_fill_from(starting_tile, move_budget):
	
	var start_node = Floodnode.new(starting_tile)
	
	var stack = [] # list containing all nodes to check
	var visited = [] # list containing all nodes checked previously
	var visited_coord = []
	visited.append(start_node)
	
	# start the list with the immediate neighbours
	var neighbour_array = get_node_neighbours(start_node)
	for node in neighbour_array:
		if not obstacles.has(node.position):
			stack.append(node)
	
	# once we have a stack
	while not stack.empty():
		var current_node = stack.front()
		#var current_tile = current_node.get_position()
		
		var neighbours = get_node_neighbours(current_node)
		
		if visited_coord.find_last(current_node.position) == -1:
			
			# CHANGENOTE - line below requires revision
			visited.append(current_node)
			visited_coord.append(current_node.position)
			
			stack.pop_front()
			
			for node in neighbours:
				if node.position != null and not obstacles.has(node.position):
					if get_ancestors(node) and get_ancestors(node).size() <= move_budget:
						stack.append(node)
		else:
			stack.pop_front()
	
	return visited