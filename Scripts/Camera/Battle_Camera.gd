extends Camera2D

onready var TILESIZE = $"../TerrainTiles".get_cell_size()
onready var TILEMAP_RECT = $"../TerrainTiles".get_used_rect()
const MOVE_DELAY = 0.05
var position_limit : Vector2
var camera_location = Vector2(0,0)

func _ready():
	position = Vector2(0,0)
	set_camera_limits()

func set_camera_limits():
	limit_top = 0
	limit_left = 0
	limit_right = TILEMAP_RECT.end.x * TILESIZE.x
	limit_bottom = TILEMAP_RECT.end.y * TILESIZE.y
	position_limit = Vector2(limit_right - get_viewport_rect().end.x, limit_bottom - get_viewport_rect().end.y) 

func get_camera_location():
	# this variable is a Vector2 that stores how many tiles the camera has moved from 0,0
	return camera_location

# Camera Movement

func _on_Controls_ui_down_just_pressed():
	if position.y < position_limit.y:
		position.y += TILESIZE.y
		camera_location.y += 1

func _on_Controls_ui_left_just_pressed():
	if position.x > 0:
		position.x -= TILESIZE.x
		camera_location.x -= 1

func _on_Controls_ui_right_just_pressed():
	if position.x < position_limit.x:
		position.x += TILESIZE.x
		camera_location.x += 1

func _on_Controls_ui_up_just_pressed():
	if position.y > 0:
		position.y -= TILESIZE.y
		camera_location.y -= 1
