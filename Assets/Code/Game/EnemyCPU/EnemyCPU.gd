extends KinematicBody2D


# Constants
export(int, 1000) var SPEED
export(int, 1000) var HIGH_SPEED
export(int, 100) var INCREASE_SPEED_DAY

const REDO_PATH_SPEED = 60

onready var sprite = get_node("Sprite")

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

var nav = null
var path = null
var redoPath = REDO_PATH_SPEED
var pathLoop = false

const ENEMY_COLLISION_BIT = 2
const ENEMY_ON_PATH_COLLISION_BIT = 4

func _ready():
	if GlobalGame.userInfo.day >= INCREASE_SPEED_DAY:
		SPEED = HIGH_SPEED
	set_physics_process(false)
	var visionArea = get_node("Vision")
	visionArea.connect("body_entered", self, "toggle_movement", [true])
	visionArea.connect("body_exited", self, "toggle_movement", [false])

func toggle_movement(var fBody, var fToggle):
	if fBody.is_in_group("Player"):
		set_physics_process(fToggle)
		var goal = null
		var goalComplete = true
		if fToggle == false:
			sprite.animation = IDLE.DOWN

func new_path(var fBody):
	if fBody != null and redoPath >= REDO_PATH_SPEED and GlobalGame.player != null and nav != null:
		if not fBody.collider.is_in_group("Player") and not fBody.collider.is_in_group("Enemy"):
			set_collision_layer_bit(ENEMY_ON_PATH_COLLISION_BIT, true)
			set_collision_layer_bit(ENEMY_COLLISION_BIT, false)
			set_collision_mask_bit(ENEMY_COLLISION_BIT, false)
			path = nav.get_simple_path(position, GlobalGame.player.position, false)
			redoPath = 0
			pathLoop = true
	elif pathLoop == true and redoPath >= REDO_PATH_SPEED:
		set_collision_layer_bit(ENEMY_ON_PATH_COLLISION_BIT, true)
		set_collision_layer_bit(ENEMY_COLLISION_BIT, false)
		set_collision_mask_bit(ENEMY_COLLISION_BIT, false)
		path = nav.get_simple_path(position, GlobalGame.player.position, false)
		redoPath = 0
	if path != null and path.size() <= 1:
		set_collision_layer_bit(ENEMY_ON_PATH_COLLISION_BIT, false)
		set_collision_layer_bit(ENEMY_COLLISION_BIT, true)
		set_collision_mask_bit(ENEMY_COLLISION_BIT, true)
		path = null
		pathLoop = false

func _physics_process(fDelta):
	var fPrevPos = position
	var fDistance = 1
	if GlobalGame.player != null:
		var fGoal
		if path == null:
			fGoal = GlobalGame.player.position
			redoPath = REDO_PATH_SPEED
		elif path.size() > 0:
			fGoal = path[0]
			redoPath += 1
		else:
			redoPath += 1
		
		if typeof(fGoal) == TYPE_VECTOR2:
			fDistance = position.distance_to(fGoal)
		else:
			return
		
		if path != null and path.size() >= 1 and fDistance < 1.0:
			path.remove(0)
		else:
			var fVel = position.linear_interpolate(fGoal, (SPEED * fDelta) / fDistance)
			var fMovement = fVel - position
			new_path(move_and_collide(fMovement))
		
		var fAngle = fPrevPos.angle_to_point(position)
		if fDistance >= 1.0:
			if fPrevPos.distance_to(position) > (SPEED * fDelta) / fDistance:
				if fAngle > 3*PI/4 or fAngle <= -1*3*PI/4:
					sprite.animation = MOVE.RIGHT
				elif fAngle >= PI/4 and fAngle < 3*PI/4:
					sprite.animation = MOVE.UP
				elif fAngle < -1*PI/4 and fAngle >= -1*3*PI/4:
					sprite.animation = MOVE.DOWN
				elif fAngle < PI/4 and fAngle >= -1*PI/4:
					sprite.animation = MOVE.LEFT