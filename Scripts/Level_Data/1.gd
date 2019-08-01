# Script to hold the level data

# LEVEL 1

func get_teams():
	var teams : Array

	var team1 = [
	Vector2(3,3),
	Vector2(3,4),
	Vector2(3,5)
	]
	
	var team2 = [
	Vector2(4,3),
	Vector2(5,4),
	Vector2(5,5)
	]
	
	teams.append(team1)
	teams.append(team2)
	
	return teams