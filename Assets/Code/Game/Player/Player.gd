# Player UI - Script for the player ui
# Created by Andrew Jacob | Created on 5 May 2018 | Edited on 5 May 2018

extends KinematicBody2D

# Constants
export(int, 1000) var SPEED

onready var playerSprite = get_node("Sprite")
onready var playerMoveAudio = get_node("PlayerMoveAudio")

var DIRECTION = {
		DOWN = Vector2(0, 1),
		LEFT = Vector2(-1, 0),
		RIGHT = Vector2(1, 0),
		UP = Vector2(0, -1)
	}

var IDLE = {
		DOWN = "idleDown",
		LEFT = "idleLeft",
		RIGHT = "idleRight",
		UP = "idleUp"
	}
var MOVE = {
		DOWN = "moveDown",
		LEFT = "moveLeft",
		RIGHT = "moveRight",
		UP = "moveUp"
	}

var moveAudioPlaying = false

var facing = DIRECTION.DOWN

# Ready Function
# Called once this script enters the scene.
# Returns: None
func _ready():
	get_node("EnemyTouch").connect("body_entered", self, "check_enemy_touch")

func check_enemy_touch(fBody):
	if fBody.is_in_group("Enemy"):
		GlobalGame.death()

func _physics_process(var delta):
	
	var fDir = Vector2()
	
	
	if Input.is_action_pressed("ui_up"):
		fDir = fDir + DIRECTION.UP
	if Input.is_action_pressed("ui_down"):
		fDir = fDir + DIRECTION.DOWN
	if Input.is_action_pressed("ui_left"):
		fDir = fDir + DIRECTION.LEFT
	if Input.is_action_pressed("ui_right"):
		fDir = fDir + DIRECTION.RIGHT
	
	var fVel = fDir.normalized() * SPEED * delta
	
	var fCol = move_and_collide(fVel)
	if fCol != null:
		if fCol.collider.is_in_group("Enterable"):
			GlobalGame.new_round(position)
			playerSprite.animation = IDLE.UP
			return
	
	if fDir != Vector2() and (not moveAudioPlaying or (fDir != facing and (not (playerSprite.animation == MOVE.DOWN and fDir.y > 0)) and (not (playerSprite.animation == MOVE.UP and fDir.y < 0)))) and (playerSprite.frame == 0 or playerSprite.frame == 2):
		playerMoveAudio.play()
		moveAudioPlaying = true
	elif moveAudioPlaying and (fDir == Vector2() or playerSprite.frame == 1 or playerSprite.frame == 3):
		moveAudioPlaying = false
	
	if fDir != Vector2():
		facing = fDir
	
	if fDir.y > 0:
		playerSprite.animation = MOVE.DOWN
	elif fDir.y < 0:
		playerSprite.animation = MOVE.UP
	elif fDir.x > 0:
		playerSprite.animation = MOVE.RIGHT
	elif fDir.x < 0:
		playerSprite.animation = MOVE.LEFT
	elif fDir == Vector2():
		if facing.y > 0:
			playerSprite.animation = IDLE.DOWN
		elif facing.y < 0:
			playerSprite.animation = IDLE.UP
		elif facing.x > 0:
			playerSprite.animation = IDLE.RIGHT
		elif facing.x < 0:
			playerSprite.animation = IDLE.LEFT
	