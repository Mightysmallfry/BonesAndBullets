extends Node2D

@onready var step1:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep1.mp3")
@onready var step2:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep2.mp3")
@onready var step3:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep3.mp3")
@onready var step4:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep4.mp3")
@onready var step5:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep5.mp3")
@onready var step6:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep6.mp3")
@onready var step7:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep7.mp3")
@onready var step8:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep8.mp3")
@onready var step9:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep9.mp3")
@onready var step10:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep10.mp3")
@onready var step11:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep11.mp3")
@onready var step12:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep12.mp3")
@onready var step13:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep13.mp3")
@onready var step14:AudioStreamMP3 = preload("res://Assets/SFX/SnowSteps/SnowStep14.mp3")

@onready var steps:Array[AudioStreamMP3] = [step1, step2, step3, step4, step5, step6, step7, step8, step9, step10, step11, step12, step13, step14]

var left:bool = true
func _on_animated_sprite_2d_frame_changed() -> void:
	if $AnimatedSprite2D.frame == 1 or $AnimatedSprite2D.frame == 4:
		if left:
			left = false
			$AudioStreamPlayer2D.stream = steps[randi_range(0,13)]
			$AudioStreamPlayer2D.play()
		else:
			left = true
			$AudioStreamPlayer2D2.stream = steps[randi_range(0,13)]
			$AudioStreamPlayer2D2.play()
