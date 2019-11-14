# GlobalInterface AutoLoad - Singleton script for the interface
# Created by Andrew Jacob | Created on 29 April 2018 | Edited on 4 May 2018

extends Node

var SOUND_OPTIONS = {
		FALSE = 0,
		TRUE = 1
	}

# Constant Dictionaries
var UI_OVERLAY = {
		NORMAL = Color(1, 1, 1, 1),
		HOVER = Color(0.75, 0.75, 0.75, 1),
		CLICK = Color(0.5, 0.5, 0.5, 1)
	}

# Member Variables
var currentInterface = null
onready var game = get_tree().get_root().get_node("Game")
onready var interfaceService = game.get_node("Interface")

var soundToggle = true

# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	if GlobalGame.load_game() != null:
		if int(GlobalGame.load_game()[0]) == SOUND_OPTIONS.TRUE:
			soundToggle = true
		else:
			soundToggle = false
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not soundToggle)
	
	do_start_menu()



func do_start_menu():
	# Variables
	var startingInterface = "res://Game/Menu/StartMenu.tscn"
	
	# Add the first scene
	call_deferred("change_interface", startingInterface)



# Connect Buttons Function
# Connects the buttons in the scene
# Returns: None
func connect_buttons():
	
	# Variables
	var btnNodes = get_tree().get_nodes_in_group("Button")
	
	# Create connections for each button
	for i in btnNodes:
		if not i.is_connected("button_down", self, "canvas_overlay"):
			i.connect("button_down", self, "canvas_overlay", [i, UI_OVERLAY.CLICK])
		if not i.is_connected("button_up", self, "canvas_overlay"):
			i.connect("button_up", self, "canvas_overlay", [i, UI_OVERLAY.HOVER])
		if not i.is_connected("mouse_entered", self, "canvas_overlay"):
			i.connect("mouse_entered", self, "canvas_overlay", [i, UI_OVERLAY.HOVER])
		if not i.is_connected("mouse_exited", self, "canvas_overlay"):
			i.connect("mouse_exited", self, "canvas_overlay", [i, UI_OVERLAY.NORMAL])



# Canvas Overlay Function
# Changes the modulate of a given node given the color.
# Returns: None
func canvas_overlay(var fNode, var fModulate):
	fNode.self_modulate = fModulate



# Scene Change Function
# Changes the current scene given a scene
# Returns: None
func change_interface(var fInterface):
	
	# Change the current scene
	if currentInterface != null:
		currentInterface.queue_free()
	var fNewInterface = ResourceLoader.load(fInterface)
	currentInterface = fNewInterface.instance()
	interfaceService.add_child(currentInterface)
	# Reconnect the buttons to the new scene
	connect_buttons()



func add_sub_interface(var fSubInterface):
	var fNewSubInterface = ResourceLoader.load(fSubInterface).instance()
	interfaceService.add_child(fNewSubInterface)
	connect_buttons()
	return fNewSubInterface



# Toggle Sound Function
# Changes the sound toggle
# Returns: None
func toggle_sound():
	# Switch the soundToggle variable
	soundToggle = not soundToggle
	
	if GlobalGame.load_game() != null:
		if soundToggle:
			GlobalGame.save_game(SOUND_OPTIONS.TRUE, int(GlobalGame.load_game()[1]))
		else:
			GlobalGame.save_game(SOUND_OPTIONS.FALSE, int(GlobalGame.load_game()[1]))
	
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not soundToggle)