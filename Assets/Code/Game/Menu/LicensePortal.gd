# Button Handler - Script for the start menu
# Created by Andrew Jacob | Created on 30 April 2018 | Edited on 4 May 2018

extends CanvasLayer

# Constants
const MUZUBI_PATH = "http://#"
const GODOT_PATH = "http://godotengine.org"
const EXIT_PATH = "res://Game/Menu/CreditsPortal.tscn"
const LICENSE_PATH = "res://Game/Menu/LicensePortal.tscn"


# Member Variables
onready var licenseBtn = get_node("LicenseBtn")
onready var thirdPartyBtn = get_node("ThirdPartyBtn")
onready var exitBtn = get_node("ExitBtn")

onready var licenseTxt = get_node("LicenseTxt")
onready var thirdPartyTxt = get_node("ThirdPartyTxt")


# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	licenseBtn.connect("pressed", self, "change_text", [licenseBtn])
	thirdPartyBtn.connect("pressed", self, "change_text", [thirdPartyBtn])
	
	exitBtn.connect("pressed", GlobalInterface, "change_interface", [EXIT_PATH])

func change_text(fBtn):
	if fBtn == licenseBtn:
		licenseTxt.visible = true
		thirdPartyTxt.visible = false
	elif fBtn == thirdPartyBtn:
		thirdPartyTxt.visible = true
		licenseTxt.visible = false