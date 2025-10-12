extends Resource
class_name StoryChoice

# Rewards can also be subtractive
enum ChoiceTypeEnum { CONTINUE, BULLET, HEALTH, PROGRESS, GAMBLE }

# Continue - Move on
# Bullet - Gain or lose bullets instead of health etc.
# Health - gain or lose hp, could costs bones to heal
# Progress - effects progress, +- time on the timer
# Gamble - better or worse future outcomes. It's ok if we fail to implement

@export var ChoiceType: ChoiceTypeEnum
@export var ChoiceDescription: String
@export var Rewards: Array[int]
