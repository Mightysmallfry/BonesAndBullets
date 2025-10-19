extends Resource
## The base enemy class
class_name enemy
@export var name:String
@export_category("Base Stats")
## The Starting Health of the enemy
@export_range(1,9999) var health:int = 100
## How much the starting health can vary per instance
@export var health_variance:int = 1
## The moral of the enemy, everytime the player kills another enemy the moral will drop causing them to runaway if it reaches 0
@export_range(1,9999) var moral:int = 100
## How much the starting moral can vary per instance
@export var moral_variance:int = 1

@export_category("Skills")
## How far the enemy can move in a turn, and how many action points the enemy gets ap = floor(speed/100) + 2
@export_range(1,100,1) var speed:int = 50
## Variance of speed skill per instances
@export var speed_variance:int = 0
## Base chance in percentage of hitting shots
@export_range(1,100,1) var aim:int = 50
## Variance of aim skill per instances
@export var aim_variance:int = 0
## Compared against player strength to determine the winner of a melee attack
@export_range(1,100,1) var melee:int = 50
## Variance of melee skill per instances
@export var melee_variance:int = 0

@export_category("Attack Type")
## Chance of Attacks the enemy will preform
@export_enum("Melee Only", "Armed") var attack_type:int = 0
## Chance of cover seeking
@export_enum("Never", "Sometimes", "Often", "Always") var cover_seeking:int = 0
## How close the enemy will get to the player
@export_enum("At Player", "Close", "Mid", "Far", "Retreat") var prefered_distance:int = 0
## How the enemy will move to maintain prefered distance if the player moves closer
@export_enum("Do Not Fall Back", "Occasionaly Fall Back", "Often Fall Back", "Always Fall Back") var movement_reaction:int = 0

@export_category("Default Starting Positions")
## Enemy's starting distance from player
@export_range(0,85,1) var distance:float = 60
## Varicance in enemy's starting distance  per instances
@export var distance_variance:int = 1
## Enemy's starting cover
@export_range(0,100,1) var cover:int = 0
## Varicance in enemy's starting cover  per instances
@export var cover_variance:int = 1

var movement:int = 1
var action_points:int = floor(speed / 33.0) + 1
