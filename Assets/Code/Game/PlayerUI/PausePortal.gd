# Player UI - Script for the player ui
# Created by Andrew Jacob | Created on 5 May 2018 | Edited on 5 May 2018

extends CanvasLayer

# Constants
const SOUND_ON_TEXTURE = preload("res://Assets/Art/Menu/SoundOnButton.png")
const SOUND_OFF_TEXTURE = preload("res://Assets/Art/Menu/SoundOffButton.png")

# Member Variables
onready var quitBtn = get_node("QuitButton")
onready var soundBtn = get_node("SoundButton")

# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	change_sound(false)
	
	soundBtn.connect("pressed", self, "change_sound", [true])
	quitBtn.connect("pressed", GlobalGame, "end_game", [true])

# Change Sound Function
# Toggles the global interface sound variable and changes the sound button texture
# Returns: None
func change_sound(var fToggle):
	if fToggle:
		GlobalInterface.toggle_sound()
	if GlobalInterface.soundToggle:
		soundBtn.texture_normal = SOUND_ON_TEXTURE
	else:
		soundBtn.texture_normal = SOUND_OFF_TEXTURE