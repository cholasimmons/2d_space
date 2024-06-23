extends Control

@onready var acceleration = $HBoxContainer/ColorRect2/MarginContainer2/VBoxContainer/accel
@onready var brake = $HBoxContainer/ColorRect3/MarginContainer2/VBoxContainer2/brake
@onready var speed = $HBoxContainer/ColorRect4/MarginContainer2/VBoxContainer3/speed
@onready var health = $HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/health
@onready var shipname = $HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/shipname
@onready var shipclass = $HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/shipclass
@onready var dockedcontainer = $ColorRect/DockedContainer
@onready var dockedto = $ColorRect/DockedContainer/dockedto

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	acceleration.value = 0.0
	brake.value = 0.0
	speed.value = 0.0
	health.value = 100.0
	shipname.text = "Unregistered"
	shipclass.text = "ZCITA Frigate"
	dockedcontainer.visible = false
	if dockedcontainer.visible:
		dockedto.text = "Annonymous"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
