extends TileMap

var last_tile = Vector2(0,0)
onready var controls = $"../../Controls"

func _ready():
	pass

func _process(delta):
	# displays the cursor tile
	set_cellv(last_tile, -1)
	last_tile = controls.get_mouseover_cell()
	set_cellv(last_tile,0)