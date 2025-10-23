extends Resource
class_name ChoiceReward


# Rewards can also be subtractive
enum ChoiceTypeEnum { CONTINUE, BULLET, HEALTH, PROGRESS, GAMBLE, NEXT, COMBAT }

# Continue - Move on
# Bullet - Gain or lose bullets instead of health etc.
# Health - gain or lose hp, could costs bones to heal
# Progress - effects progress, +- time on the timer
# Gamble - better or worse future outcomes. It's ok if we fail to implement

## The Type of Reward the choice does
@export var rewardType: ChoiceTypeEnum
## The value of the reward if chosen Bullet, Health, Progress, or Gamble
@export var rewardValue:int
## The next event if chosen NEXT
@export var nextEvent:StoryEventData
## The combat if chosen COMBAT
@export var combatPath:CombatEvent
