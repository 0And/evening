extends Area2D

func _ready():
	connect("body_entered", self, "add_materials")

func add_materials(var fObject):
	if fObject.is_in_group("Player"):
		GlobalGame.add_item(true, false)
		queue_free()