extends Area2D

#signal docked_with_ship(ship)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body):
	if body.is_in_group("ships"):
		emit_signal("docked_with_ship")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
