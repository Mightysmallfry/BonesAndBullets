extends Resource
class_name CombatEvent

## If the player gets to move first
@export var player_moves_first:bool = true
## Array of enemies in combat
@export var enemies:Array[enemy] = []
## If number is greater than -1 it overwrites enemy's default starting distance
@export_range(-1,85,1) var avg_starting_distance:int = -1
## If number is greater than -1 it overwrites enemy's default starting cover
@export_range(-1,90,1) var avg_starting_cover:int = -1
