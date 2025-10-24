extends Resource
class_name StoryChoice

enum resource {NONE, BULLET, BONE}

## Description of the choice button
@export var choiceDescription: String
@export var requresResource:resource
## Array of rewards/results of picking choice
@export var rewards: Array[ChoiceReward]
