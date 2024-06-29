extends CanvasLayer

@onready var debug = $"."
@onready var topspeed = $HBoxContainer/ColorRect/MarginContainer/SpeedContainer/HBoxContainer3/topspeed
@onready var currentspeed = $HBoxContainer/ColorRect/MarginContainer/SpeedContainer/HBoxContainer4/currentspeed
@onready var rotationspeed = $HBoxContainer/ColorRect2/MarginContainer/RotationContainer/HBoxContainer2/rotationspeed
@onready var rotationangle = $HBoxContainer/ColorRect2/MarginContainer/RotationContainer/HBoxContainer4/rotationangle
@onready var selectedgun = $HBoxContainer/ColorRect4/MarginContainer/WeaponsContainer/weapon1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	debug.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_ship_stats(ship_stats):
	# print(ship_stats.show)
	debug.visible = ship_stats.show
	if debug.visible:
		currentspeed.text = str(round(ship_stats.current_speed));
		topspeed.text = str(round(ship_stats.top_speed));
		rotationspeed.text = str(floor(ship_stats.rot_speed));
		rotationangle.text = str(floor(ship_stats.rot_angle));
		selectedgun.text = str(ship_stats.gun)
