# GlobalGame AutoLoad - Singleton script for the game
# Created by Andrew Jacob | Created on 4 May 2018 | Edited on 4 May 2018

extends Node

signal items_changed
signal time_changed
signal day_changed
signal time_complete

var gameCenter = null

var dead = true

var newDay = false

# Constants
const STARTING_TIME = 361
const MAX_MATERIALS = 3
const MAX_FOOD = 3

const SPAWN_PERCENTAGE = 0.2
const GOO_PERCENTAGE = 0.5
const HIGH_PERCENTAGE = 0.9
const NORM_PERCENTAGE = 0.5

const MAX_ITEMS_IN_GAME = 9

var Shake = {
	Duration = 2,
	Frequency = 50,
	Amplitude= 3
}

const DEATH_TIME = 0

var materialsString = "Materials"
var foodString = "Food"
var zoneString = "Zone"

enum { HIGH = 0, NORM = 1 }

onready var game = get_tree().get_root().get_node("Game")
onready var playerService = game.get_node("Players")
onready var worldService = game.get_node("World")
onready var startingPos = worldService.get_node("StartingPosition").position
onready var itemService = worldService.get_node("ItemService")

onready var MaterialZones = {
		0 : worldService.get_node("MaterialZones").get_node("High"),
		1 : worldService.get_node("MaterialZones").get_node("Norm")
	}
onready var FoodZones = {
		0 : worldService.get_node("FoodZones").get_node("High"),
		1 : worldService.get_node("FoodZones").get_node("Norm")
	}
var newRoundUI = "res://Game/Menu/NewRoundUI.tscn"
var playerUI = "res://Game/Player/PlayerUI.tscn"
var deathUI = "res://Game/Player/DeathUI.tscn"

var timerRunning = false

var player = null
onready var playerScene = preload("res://Game/PlayerBody/Player.tscn")
onready var enemyScene = preload("res://Game/EnemyBody/EnemyCPU.tscn")

onready var foodScene = preload("res://Game/Items/Food.tscn")
onready var materialsScene = preload("res://Game/Items/Materials.tscn")

onready var interfaceService = game.get_node("Interface")
onready var enemyService = worldService.get_node("Enemies")

onready var DEATH_SOUND = preload("res://Assets/Audio/FX/Death.wav")
const DEATH_VOLUME = -18

var gameInfo = {
		materialCount = 0,
		foodCount = 0
	}

# Dictionaries
var userInfo = {
		day = 0,
		timer = null,
		secondsLeft = STARTING_TIME,
		
		materials = 0,
		food = 0
	}

func _ready():
	get_tree().get_root().pause_mode = PAUSE_MODE_PROCESS
	
	if load_game() == null:
		save_game(GlobalInterface.SOUND_OPTIONS.TRUE, 1)

func _process(delta):
	if userInfo.timer != null:
		userInfo.secondsLeft = int(userInfo.timer.time_left)
		emit_signal("time_changed")
	else:
		userInfo.secondsLeft = STARTING_TIME

func begin_game():
	userInfo.day = 0
	userInfo.secondsLeft = STARTING_TIME
	userInfo.materials = 0
	userInfo.food = 0
	if userInfo.timer != null:
		userInfo.timer.queue_free()
		userInfo.timer = null
	dead = false
	new_round(startingPos)
	

func spawn_items(var fZoneArray, var fScene, var fPercent, var fRepeat):
	var fDataVar
	for i in fZoneArray:
		randomize()
		if fScene == foodScene:
			fDataVar = gameInfo.foodCount
		else:
			fDataVar = gameInfo.materialCount
		if rand_range(0, 1) <= fPercent and fDataVar < MAX_ITEMS_IN_GAME and i.Used == false and i.is_in_group("Zone"):
			var fPosXEnd = i.rect_position.x + i.rect_size.x
			var fPosXStart = i.rect_position.x
			var fPosYEnd = i.rect_position.y + i.rect_size.y
			var fPosYStart = i.rect_position.y
			var fRandomX = rand_range(fPosXStart, fPosXEnd)
			var fRandomY = rand_range(fPosYStart, fPosYEnd)
			var fItem = fScene.instance()
			fItem.position = Vector2(fRandomX, fRandomY)
			itemService.add_child(fItem)
			i.Used = true
			if fScene == foodScene:
				gameInfo.foodCount += 1
			else:
				gameInfo.materialCount += 1
		elif fDataVar >= MAX_ITEMS_IN_GAME:
			return
	if fRepeat == true:
		spawn_items(fZoneArray, fScene, fPercent, fRepeat)

func new_round_items():
	
	for i in enemyService.get_children():
		i.queue_free()
	
	for i in worldService.get_node("Map").get_node("Blocks").get_children():
		if i.is_in_group("Building"):
			for fGoo in i.get_children():
				if fGoo.is_in_group("Goo"):
					fGoo.visible = false
				elif fGoo.name == "MonsterCollision":
					fGoo.disabled = true
	
	for i in worldService.get_node("Map").get_node("Blocks").get_children():
		if i.is_in_group("Building") and rand_range(0, 1) <= GOO_PERCENTAGE:
			for fGoo in i.get_children():
				if fGoo.is_in_group("Goo"):
					fGoo.visible = true
				elif fGoo.name == "MonsterCollision":
					fGoo.disabled = false
	
	for i in itemService.get_children():
		i.queue_free()
	
	for i in FoodZones[HIGH].get_children():
		if i.is_in_group("Zone"):
			i.Used = false
	for i in FoodZones[NORM].get_children():
		if i.is_in_group("Zone"):
			i.Used = false
	for i in MaterialZones[HIGH].get_children():
		if i.is_in_group("Zone"):
			i.Used = false
	for i in MaterialZones[NORM].get_children():
		if i.is_in_group("Zone"):
			i.Used = false
	
	spawn_items(FoodZones[HIGH].get_children(), foodScene, HIGH_PERCENTAGE, false)
	spawn_items(FoodZones[NORM].get_children(), foodScene, NORM_PERCENTAGE, true)
	spawn_items(MaterialZones[HIGH].get_children(), materialsScene, HIGH_PERCENTAGE, false)
	spawn_items(MaterialZones[NORM].get_children(), materialsScene, NORM_PERCENTAGE, true)
	
	

func new_round(var fPos):
	
	newDay = true
	
	if userInfo.day >= 1:
		if userInfo.materials >= MAX_MATERIALS and userInfo.food >= MAX_FOOD:
			player.get_node("EnemyTouch").get_node("Collision").disabled = true
			player.set_physics_process(false)
		else:
			return
	
	# Set up the new round information
	userInfo.day = userInfo.day + 1
	userInfo.secondsLeft = STARTING_TIME
	userInfo.materials = 0
	userInfo.food = 0
	gameInfo.materialCount = 0
	gameInfo.foodCount = 0
	if userInfo.timer != null:
		userInfo.timer.queue_free()
		userInfo.timer = null
	
	var fNewRoundUI = GlobalInterface.add_sub_interface(newRoundUI)
	
	# Waits until the animation is done
	yield(fNewRoundUI, "intermission")
	
	if userInfo.day == 1:
		GlobalInterface.change_interface(playerUI)
	
	emit_signal("items_changed")
	emit_signal("time_changed")
	emit_signal("day_changed")
	
	
	
	# Game has now actually begun
	yield(fNewRoundUI, "end_intermission")
	
	if player != null:
		player.queue_free()
		player = null
	
	new_round_items()
	
	player = playerScene.instance()
	player.position = fPos
	playerService.add_child(player)
	
	pause_game(false)
	player.get_node("EnemyTouch").get_node("Collision").disabled = false
	
	for i in worldService.get_node("EnemyZones").get_children():
		if i.is_in_group("EnemyZone") and rand_range(0, 1) <= (SPAWN_PERCENTAGE * userInfo.day):
			var fPosXEnd = i.rect_position.x + i.rect_size.x
			var fPosXStart = i.rect_position.x
			var fPosYEnd = i.rect_position.y + i.rect_size.y
			var fPosYStart = i.rect_position.y
			var fRandomX = rand_range(fPosXStart, fPosXEnd)
			var fRandomY = rand_range(fPosYStart, fPosYEnd)
			var enemy = enemyScene.instance()
			enemy.nav = game.get_node("Navigation").get_node("Nav")
			enemy.position = Vector2(fRandomX, fRandomY)
			enemyService.add_child(enemy)
	
	userInfo.timer = wait(STARTING_TIME)
	userInfo.timer.pause_mode = PAUSE_MODE_STOP
	
	newDay = false
	
	yield(userInfo.timer, "timeout")
	
	userInfo.timer.queue_free()
	userInfo.timer = null
	
	emit_signal("time_complete")

func pause_game(var fPause):
	get_tree().paused = fPause

func death():
	dead = true
	player.get_node("Sprite").get_node("Glitch").visible = true
	player.get_node("Sprite").get_node("Glitch").get_node("Anim").play("GlitchAnim")
	player.get_node("Camera").pause_mode = PAUSE_MODE_PROCESS
	pause_game(true)
	player.get_node("Camera").shake(Shake.Duration, Shake.Frequency, Shake.Amplitude)
	
	var fDeathAudio = AudioStreamPlayer.new()
	fDeathAudio.stream = DEATH_SOUND
	fDeathAudio.volume_db = DEATH_VOLUME
	self.add_child(fDeathAudio)
	fDeathAudio.play()
	
	if DEATH_TIME > 0:
		var fTempWait = wait(DEATH_TIME)
		yield(fTempWait, "timeout")
		fTempWait.queue_free()
		fTempWait = null
	
	if load_game() != null:
		if userInfo.day > int(load_game()[1]):
			save_game(int(load_game()[0]), userInfo.day)
	
	GlobalInterface.change_interface(deathUI)
	

func end_game(var fToMainMenu):
	userInfo.secondsLeft = STARTING_TIME
	userInfo.materials = 0
	userInfo.food = 0
	gameInfo.materialCount = 0
	gameInfo.foodCount = 0
	if userInfo.timer != null:
		userInfo.timer.queue_free()
		userInfo.timer = null
	pause_game(true)
	if player != null:
		player.queue_free()
		player = null
	for i in interfaceService.get_children():
		i.queue_free()
	if fToMainMenu:
		GlobalInterface.do_start_menu()

func add_item(var fMaterials, var fFood):
	if fMaterials and userInfo.materials < MAX_MATERIALS:
		userInfo.materials += 1
		emit_signal("items_changed")
	elif fFood and userInfo.food < MAX_FOOD:
		userInfo.food += 1
		emit_signal("items_changed")

func wait(var fSeconds):
	var fTimer = Timer.new()
	fTimer.wait_time = fSeconds
	fTimer.one_shot = true
	fTimer.autostart = true
	self.add_child(fTimer)
	return fTimer


func save_game(fSound, fScore):
	if typeof(fSound) == TYPE_INT and typeof(fScore) == TYPE_INT:
		var fFile = File.new()
		var fEncrypt = fFile.open_encrypted_with_pass("user://Game.dat", File.WRITE, "password")
		fFile.store_string(str(fSound) + "/")
		fFile.store_string(str(fScore))
		fFile.close()

func load_game():
	var fFile = File.new()
	if fFile.file_exists("user://Game.dat"):
		var fEncrypt = fFile.open_encrypted_with_pass("user://Game.dat", File.READ, "password")
		var fContent = fFile.get_as_text()
		fFile.close()
		if fContent.split("/").size() == 2:
			if fContent.split("/")[0].is_valid_integer() and fContent.split("/")[1].is_valid_integer() and int(fContent.split("/")[1]) >= 1 and (int(fContent.split("/")[0]) == 0 or int(fContent.split("/")[0]) == 1):
				return fContent.split("/")
			else:
				return null
		else:
			return null
	else:
		return null