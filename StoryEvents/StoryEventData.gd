extends Resource
class_name StoryEventData

@export var Title: String
@export var Dialog: String
@export var Choices: Array[StoryChoice]

# Perhaps an array of StoryEventButtons?
# They are resource of enum, reward(array of ints) and string vals?
# enum allows us to act
# 	Base on enum we will know if we have a reward
#	Rewards can be split up as currency, integrity, etc.
# string is then what will be listed on the button
