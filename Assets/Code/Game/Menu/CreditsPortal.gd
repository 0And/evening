# Button Handler - Script for the start menu
# Created by Andrew Jacob | Created on 30 April 2018 | Edited on 4 May 2018

extends CanvasLayer

# Constants
const GODOT_PATH = "https://godotengine.org/"
const BACK_PATH = "res://Game/Menu/StartMenu.tscn"
const LICENSE_PATH = "https://godotengine.org/license"#"res://Game/Menu/LicensePortal.tscn"

# Member Variables
onready var godotBtn = get_node("GodotButton")
onready var backBtn = get_node("BackButton")

onready var godotWebBtn = godotBtn.get_node("WebsiteButton")
onready var godotLicenseBtn = godotBtn.get_node("LicenseButton")


# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	godotBtn.connect("pressed", self, "toggle_visible", [godotBtn])
	
	godotWebBtn.connect("pressed", self, "open_website", [GODOT_PATH])
	godotLicenseBtn.connect("pressed", self, "open_website", [LICENSE_PATH])
	
	backBtn.connect("pressed", GlobalInterface, "change_interface", [BACK_PATH])


func license_popup():
	pass


func toggle_visible(fBtn):
	if fBtn == godotBtn:
		godotWebBtn.visible = not godotWebBtn.visible
		godotLicenseBtn.visible = not godotLicenseBtn.visible

# Open Website Function
# Opens a website given the URL
# Returns: None
func open_website(var fURL):
	OS.shell_open(fURL)