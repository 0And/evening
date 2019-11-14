# New Round Sub UI - Script for starting a new round
# Created by Andrew Jacob | Created on 5 May 2018 | Edited on 5 May 2018

extends CanvasLayer

signal intermission
signal end_intermission

const WAIT_TIME = 5

onready var DAY_NUMBERS = {
		0: preload("res://Assets/Art/Menu/DayZero.png"),
		1: preload("res://Assets/Art/Menu/DayOne.png"),
		2: preload("res://Assets/Art/Menu/DayTwo.png"),
		3: preload("res://Assets/Art/Menu/DayThree.png"),
		4: preload("res://Assets/Art/Menu/DayFour.png"),
		5: preload("res://Assets/Art/Menu/DayFive.png"),
		6: preload("res://Assets/Art/Menu/DaySix.png"),
		7: preload("res://Assets/Art/Menu/DaySeven.png"),
		8: preload("res://Assets/Art/Menu/DayEight.png"),
		9: preload("res://Assets/Art/Menu/DayNine.png")
	}

# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	
	var fFrame = get_node("Frame")
	var fDayNumbers = fFrame.get_node("DayNumbers")
	var fFrameAnim = get_node("FrameAnimation")
	
	for i in range(str(GlobalGame.userInfo.day).length()):
		var fNewDigit = TextureRect.new()
		fNewDigit.texture = DAY_NUMBERS[int(str(GlobalGame.userInfo.day)[i])]
		fDayNumbers.add_child(fNewDigit)
	fFrameAnim.play("Fade In")
	
	yield(fFrameAnim, "animation_finished")
	
	emit_signal("intermission")
	
	var timer = GlobalGame.wait(WAIT_TIME)
	yield(timer, "timeout")
	timer.queue_free()
	
	emit_signal("end_intermission")
	
	fFrameAnim.play("Fade Out")
	
	yield(fFrameAnim, "animation_finished")
	
	
	
	queue_free()