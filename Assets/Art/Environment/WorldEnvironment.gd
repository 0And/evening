extends WorldEnvironment

const START_BRIGHT = 0.8
const END_BRIGHT = 0.5
const SECONDS_TO_DEATH = 1
const STEP = 0.01
const MULT = 100

func _ready():
	GlobalGame.connect("time_changed", self, "change_brightness")

func change_brightness():
	var fTotalSeconds = GlobalGame.userInfo.secondsLeft
	var fBrightness = ((float(fTotalSeconds) / float(GlobalGame.STARTING_TIME)) * (START_BRIGHT - END_BRIGHT)) + END_BRIGHT
	environment.adjustment_brightness = fBrightness
	if fTotalSeconds <= 0 and GlobalGame.newDay == false:
		for i in range(0, END_BRIGHT*MULT, STEP*MULT):
			i = float(i) / MULT
			environment.adjustment_brightness = abs(i-END_BRIGHT)
			var fTimer = GlobalGame.wait(float(SECONDS_TO_DEATH)/(END_BRIGHT/STEP))
			yield(fTimer, "timeout")
			fTimer.queue_free()
			fTimer = null
		environment.adjustment_brightness = 0
		if environment.adjustment_brightness <= 0 and GlobalGame.newDay == false:
			GlobalGame.death()