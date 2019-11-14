# Button Handler - Script for the start menu
# Created by Andrew Jacob | Created on 30 April 2018 | Edited on 4 May 2018

extends CanvasLayer

# Constants
const START_PATH = "res://Game/Menu/TutorialPortal.tscn"
const OPTIONS_PATH = "res://Game/Menu/OptionsPortal.tscn"
const CREDITS_PATH = "res://Game/Menu/CreditsPortal.tscn"
const GAME_CENTER_PATH = { "view": "leaderboards" }

# Member Variables
onready var startBtn = get_node("StartButton")
onready var optionsBtn = get_node("OptionsButton")
onready var creditsBtn = get_node("CreditsButton")
onready var gameCenterBtn = get_node("GameCenterButton")



# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	startBtn.connect("pressed", GlobalInterface, "change_interface", [START_PATH])
	optionsBtn.connect("pressed", GlobalInterface, "change_interface", [OPTIONS_PATH])
	creditsBtn.connect("pressed", GlobalInterface, "change_interface", [CREDITS_PATH])
	if Engine.has_singleton("GameCenter"):
		GlobalGame.gameCenter = Engine.get_singleton("GameCenter")
		gameCenterBtn.connect("pressed", GlobalGame.gameCenter, "show_game_center", [GAME_CENTER_PATH])
		gameCenterBtn.visible = true