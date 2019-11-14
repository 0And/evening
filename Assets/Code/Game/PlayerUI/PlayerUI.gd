# Player UI - Script for the player ui
# Created by Andrew Jacob | Created on 5 May 2018 | Edited on 5 May 2018

extends CanvasLayer

# Constants
const PAUSE_PATH = "res://Game/Player/PausePortal.tscn"

# Constant Dictionaries
onready var NUMBERS = {
		0: preload("res://Assets/Art/PlayerUI/zero.png"),
		1: preload("res://Assets/Art/PlayerUI/one.png"),
		2: preload("res://Assets/Art/PlayerUI/two.png"),
		3: preload("res://Assets/Art/PlayerUI/three.png"),
		4: preload("res://Assets/Art/PlayerUI/four.png"),
		5: preload("res://Assets/Art/PlayerUI/five.png"),
		6: preload("res://Assets/Art/PlayerUI/six.png"),
		7: preload("res://Assets/Art/PlayerUI/seven.png"),
		8: preload("res://Assets/Art/PlayerUI/eight.png"),
		9: preload("res://Assets/Art/PlayerUI/nine.png")
	}

# Member Variables
onready var pauseBtn = get_node("PauseButton")

onready var materialText = get_node("MaterialsBox/Number")
onready var foodText = get_node("FoodBox/Number")

onready var materialTimes = get_node("MaterialsBox/TimesText")
onready var foodTimes = get_node("FoodBox/TimesText")

onready var dayBox = get_node("DayBox")

onready var timerMin = get_node("TimerBox/Minute")
onready var timerTenSec = get_node("TimerBox/TenSecond")
onready var timerSec = get_node("TimerBox/Second")

var paused = false
var pauseScreen = null

# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	pauseBtn.connect("pressed", self, "toggle_pause")
	GlobalGame.connect("items_changed", self, "update_items_ui")
	GlobalGame.connect("day_changed", self, "update_day_ui")
	GlobalGame.connect("time_changed", self, "update_time_ui")

func toggle_pause():
	if not GlobalGame.dead:
		paused = not paused
		if paused:
			pauseScreen = GlobalInterface.add_sub_interface(PAUSE_PATH)
		elif pauseScreen != null:
			pauseScreen.queue_free()
		GlobalGame.pause_game(paused)

func update_items_ui():
	var fMaterialsAmmount = GlobalGame.userInfo.materials
	var fFoodAmmount = GlobalGame.userInfo.food
	if fMaterialsAmmount < NUMBERS.size():
		materialText.texture = NUMBERS[fMaterialsAmmount]
	if fFoodAmmount < NUMBERS.size():
		foodText.texture = NUMBERS[fFoodAmmount]
	
	if fMaterialsAmmount >= GlobalGame.MAX_MATERIALS:
		materialText.modulate = Color("4D8952")
		materialTimes.modulate = Color("4D8952")
	else:
		materialText.modulate = Color(1, 1, 1, 1)
		materialTimes.modulate = Color(1, 1, 1, 1)
	
	if fFoodAmmount >= GlobalGame.MAX_FOOD:
		foodText.modulate = Color("4D8952")
		foodTimes.modulate = Color("4D8952")
	else:
		foodText.modulate = Color(1, 1, 1, 1)
		foodTimes.modulate = Color(1, 1, 1, 1)

func update_day_ui():
	var fDay = GlobalGame.userInfo.day
	for i in range(dayBox.get_children().size()):
		if i != 0 and i != 1 and i != 2:
			dayBox.get_children()[i].queue_free()
	for i in range(str(fDay).length()):
		var fNewNum = TextureRect.new()
		fNewNum.texture = NUMBERS[int(str(fDay)[i])]
		dayBox.add_child(fNewNum)

func update_time_ui():
	
	var fTotalSeconds = GlobalGame.userInfo.secondsLeft
	
	var fMINUTE = 60
	var fTENSECONDS = 10
	
	var fMins = 0
	var fTenSecs = 0
	var fSecs = fTotalSeconds
	
	if fSecs >= fMINUTE:
		fSecs %= fMINUTE
		fMins = int((fTotalSeconds - fSecs)/fMINUTE)
	if fSecs >= fTENSECONDS:
		fSecs %= fTENSECONDS
		fTenSecs = int((fTotalSeconds - fMins*fMINUTE - fSecs)/fTENSECONDS)
	
	if fMins < NUMBERS.size():
		timerMin.texture = NUMBERS[fMins]
	if fTenSecs < NUMBERS.size():
		timerTenSec.texture = NUMBERS[fTenSecs]
	if fSecs < NUMBERS.size():
		timerSec.texture = NUMBERS[fSecs]