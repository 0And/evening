# Button Handler - Script for the start menu
# Created by Andrew Jacob | Created on 30 April 2018 | Edited on 4 May 2018

extends CanvasLayer

# Constants
const SOUND_ON_TEXTURE = preload("res://Assets/Art/Menu/SoundOnButton.png")
const SOUND_OFF_TEXTURE = preload("res://Assets/Art/Menu/SoundOffButton.png")
const BACK_PATH = "res://Game/Menu/StartMenu.tscn"

# Member Variables
onready var soundBtn = get_node("SoundButton")
onready var backBtn = get_node("BackButton")



# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	
	change_sound(false)
	
	soundBtn.connect("pressed", self, "change_sound", [true])
	backBtn.connect("pressed", GlobalInterface, "change_interface", [BACK_PATH])



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