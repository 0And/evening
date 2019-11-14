extends CanvasLayer

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

onready var quitBtn = get_node("QuitButton")
onready var retryBtn = get_node("RetryButton")

onready var scoreBox = get_node("ScoreBox/Numbers")
onready var highscoreBox = get_node("ScoreBox/HighScoreImage/Numbers")
onready var highscoreImage = get_node("ScoreBox/HighScoreImage")

const IMAGE_MULT = 7

func _ready():
	
	var score = GlobalGame.userInfo.day
	var highscore = score
	
	if GlobalGame.load_game() != null:
		highscore = int(GlobalGame.load_game()[1])
	
	retryBtn.connect("pressed", GlobalGame, "begin_game")
	quitBtn.connect("pressed", GlobalGame, "end_game", [true])
	
	for i in range(str(score).length()):
		var fNewScore = TextureRect.new()
		fNewScore.texture = NUMBERS[int(str(score)[i])]
		fNewScore.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		scoreBox.add_child(fNewScore)
	
	for i in range(str(highscore).length()):
		var fNewHigh = TextureRect.new()
		fNewHigh.texture = NUMBERS[int(str(highscore)[i])]
		highscoreBox.add_child(fNewHigh)
	
	highscoreImage.rect_size.x = (str(highscore).length() + 1) * IMAGE_MULT