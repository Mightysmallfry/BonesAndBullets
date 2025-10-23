extends Resource
class_name StoryChoice

# Rewards can also be subtractive
enum ChoiceTypeEnum { CONTINUE, BULLET, HEALTH, PROGRESS, GAMBLE, NEXT, COMBAT }

# Continue - Move on
# Bullet - Gain or lose bullets instead of health etc.
# Health - gain or lose hp, could costs bones to heal
# Progress - effects progress, +- time on the timer
# Gamble - better or worse future outcomes. It's ok if we fail to implement

@export var choiceType: ChoiceTypeEnum
@export var choiceDescription: String
@export var rewards: Array[int]
@export var nextEvent:StoryEventData
@export var combatPath:CombatEvent
