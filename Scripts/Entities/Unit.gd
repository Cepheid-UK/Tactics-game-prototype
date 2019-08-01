extends Node2D

onready var CONSTANTS = $"/root/Constants"

var unit_id : int
var team_id : int # "team" is a native property :(
var attack_damage : int
var maxhp : int
var hitpoints : int
var move_budget : int
var turn_taken_yet : bool
var alive : bool

onready var sprite = $"Sprite"

signal unit_moved
signal unit_dead

func _ready():
	attack_damage = 4
	maxhp = 10
	hitpoints = maxhp
	move_budget = 8
	turn_taken_yet = false
	alive = true
	
	var hp_overlay = get_child(1).get_child(0)
	hp_overlay.set_text(str(hitpoints))

func set_team(team_value : int):
	team_id = team_value
	get_sprite().set_modulate(get_team_colour(team_id)[0])

func get_team():
	return team_id

func get_team_colour(team_int : int):
	if team_int == 1:
		return [Color(1,0,0,1), "red"]
	if team_int == 2:
		return [Color(0,0,1,1), "blue"]
	if team_int == 3:
		return [Color(1,1,0,1), "yellow"]
	if team_int == 4:
		return [Color(0,1,0,1), "green"]

func get_move_budget():
	return move_budget

func take_turn():
	turn_taken_yet = true

func turn_taken():
	return turn_taken_yet

func reset_turn():
	turn_taken_yet = false

func get_sprite():
	return get_child(0)

func set_sprite_texture(texture : Texture):
	sprite.set_texture(texture)

func set_position(new : Vector2):
	position = new

func is_alive():
	return alive

func get_tile_position():
	return convert_viewport_position_to_tilemap_position(position)

func convert_viewport_position_to_tilemap_position(pos : Vector2):
	return pos / CONSTANTS.TILEMAP_CELL_SIZE_VECTOR

func damage(value):
	if hitpoints - value > 0:
		hitpoints -= value
	else:
		hitpoints = 0
		kill()

func heal(value):
	if hitpoints + value > maxhp:
		hitpoints = maxhp
	else:
		hitpoints += value

func kill():
	emit_signal("unit_dead", self)
	alive = false

func revive():
	alive = true

func move(to : Vector2):
	emit_signal("unit_moved", self, get_tile_position(), convert_viewport_position_to_tilemap_position(to))
	self.set_position(to * CONSTANTS.TILEMAP_CELL_SIZE_VECTOR)