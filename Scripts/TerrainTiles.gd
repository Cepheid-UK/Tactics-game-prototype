extends TileMap

onready var unit_manager = $"../UnitManager"

var obstacles : Array
var obstacles_id : Array

func _ready():
	update_obstacles()

func get_obstacles():
	update_obstacles()
	return obstacles

func update_obstacles():
	obstacles.clear()
	var tileset_ids = tile_set.get_tiles_ids()
	for tile_id in tileset_ids:
		if tile_id == 0:
			var used_cells = get_used_cells_by_id(0)
			var unit_positions = unit_manager.get_unit_positions()
			for unit_position in unit_positions:
				if used_cells.has(unit_position):
					obstacles.append(unit_position)
			continue
		var used_cells = get_used_cells_by_id(tile_id)
		for cell in used_cells:
			obstacles.append(cell)