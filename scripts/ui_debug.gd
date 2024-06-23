extends Control

@onready var debug = "."
@onready var thrustforce = $ColorRect/MarginContainer/HBoxContainer/SpeedContainer/HBoxContainer/thrustforce


# Called when the node enters the scene tree for the first time.
func _init() -> void:
	# thrustforce.text = "0.0"
	print("init")
	# debug.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
