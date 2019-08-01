extends Node

onready var unit_manager = $"../../UnitManager"
onready var controls = $"../../Controls"
onready var pathfinding = $"Pathfinding"
onready var ui_tiles = $"../../TerrainTiles/UITiles"
onready var terrain_tiles = $"../../TerrainTiles"
onready var map_size = terrain_tiles.get_used_rect().end

# state for handling what happens when a player selects one of their units

# When the state is entered, all the possible moves for the unit are calculated via flood fill BFS
# When updating, the location of the mouse is checked, and a path is calculated to that location via A*
# The possible moves and the path to the mouseover square are drawn (if it is within the possible moves)
# when a click is made, if it's a valid path, change state to "Unit_Movement" else revert to "Idle"

# if the player clicks the unit again, they bring up the order menu
# if the player right clicks, they revert back to the 'Idle' state

# --------------------------------------------------------
# IN THIS STATE:
# reset the path to null (saved from last Unit_Selected state) - CHECK
# get the location clicked in tilemap coordinates. (Convert between mouseclick in viewport to mouseclick on tilemap)
# find the unit at that location
# get that unit's movement value
# get all the obstacles on the map
# calculate all the tiles that are valid moves using Floodfill and put into an array
# remove the starting tile from that array
# subtract all the obstacles from the valid moves list
# do a first-pass pathfind to connect all the nodes for A*
# UPDATE EVERY FRAME:
# get the mouse's current location
# check if it's within the valid moves as calculated by Floodfill earlier, if so:
# recalculate the path to the mouse's current location
# send the UI the path from the unit to the mouse's location as an array
# if the player left clicks the location of the unit selected: Return "Awaiting_Orders" state change
# if the player left clicks a valid location: Return "Unit_Movement" state change
# if the player right clicks: Return the "Idle" state change
# ---------------------------------------------------------
var astar = AStar.new()
var obstacles
var path : Array
var selected_unit 
var click_location
var path_start_pos
var path_end_pos
var mouseover_cell
var node_moves
var possible_moves
var last_mouseover_cell

func enter(host, data):
	
	click_location = data
	selected_unit = unit_manager.get_unit_at_coordinate(click_location)
	
	# reset path from previous 'Unit_Selected' state
	path = []
	
	# reset the possible moves for pathfinding calculations
	possible_moves = []
	
	obstacles = $"../../TerrainTiles".get_obstacles()
	
	path_start_pos = selected_unit.get_tile_position()
	mouseover_cell = controls.get_mouseover_cell()
	path_end_pos = mouseover_cell
	
	node_moves = flood_fill_from(path_start_pos, selected_unit.get_move_budget())
	node_moves.remove(0)
	
	for node in node_moves:
		if not obstacles.has(node.position):
			possible_moves.append(node.position)
	
	path = pathfind(path_start_pos, path_end_pos)
	
	for tile in possible_moves:
		ui_tiles.set_cellv(tile,0)
	
	return

func update(host, delta):
	
	ui_tiles.clear()
	
	for tile in possible_moves:
		ui_tiles.set_cellv(tile,0)
	
	var last_mouseover_cell = mouseover_cell
	
	mouseover_cell = controls.get_mouseover_cell()
	
	if last_mouseover_cell != mouseover_cell:
		
		path_start_pos = selected_unit.get_tile_position()
		path_end_pos = mouseover_cell
		
		path = calculate_path()
		
		if path.size() != 0:
			path.remove(0)
		for coord in path:
			# draw all the nodes in the path onto the UI tilemap
			ui_tiles.set_cellv(Vector2(coord.x,coord.y),1)
	elif path:
		for coord in path:
			# draw all the nodes in the path onto the UI tilemap
			ui_tiles.set_cellv(Vector2(coord.x,coord.y),1)
	
	if Input.is_action_just_pressed("ui_leftclick"):
		if controls.get_last_clicked_tile() == selected_unit.get_tile_position():
			return 'Unit_Awaiting_Orders'
		if not possible_moves.has(controls.get_mouse_click_cell()):
			return 'Idle'
		if possible_moves and possible_moves.has(controls.get_mouse_click_cell()):
			return 'Unit_Movement'
		# check if clicked on a unit - return 'Idle' and change clicked_location to the new unit
		# check if clicked on a valid move location - return 'Unit_Movement'
		# check if clicked on an invalid location - return 'Idle' with no clicked location
		pass
	
	if Input.is_action_just_pressed("ui_rightclick"):
		return 'Idle'
	return

func exit(host):
	ui_tiles.clear()
	return [path_end_pos, selected_unit]

func pathfind(from, to):
	path_start_pos = from
	path_end_pos = to
	
	var max_potential_moves = []
	
	var nodes = flood_fill_from(from, selected_unit.get_move_budget())
	
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
			if obstacles.has(tile) and tile != selected_unit.get_tile_position():
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
	for node in get_node_neighbours(start_node):
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