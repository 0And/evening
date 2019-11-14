extends Area2D

func _ready():
	connect("body_entered", self, "add_food")

func add_food(var fObject):
	if fObject.is_in_group("Player"):
		GlobalGame.add_item(false, true)
		queue_free()