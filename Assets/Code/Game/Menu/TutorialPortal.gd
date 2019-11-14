# Button Handler - Script for the start menu
# Created by Andrew Jacob | Created on 4 May 2018 | Edited on 4 May 2018

extends CanvasLayer

# Member Variables
var started = false

# Input Function
# Called once user input is entered
# Returns: None
func _input(fEvent):
	if (fEvent is InputEventMouseButton && (fEvent.button_index != BUTTON_WHEEL_UP && fEvent.button_index != BUTTON_WHEEL_DOWN && fEvent.button_index != BUTTON_WHEEL_LEFT && fEvent.button_index != BUTTON_WHEEL_RIGHT) && started == false) or (fEvent is InputEventKey && started == false):
		started = true
		GlobalGame.begin_game()