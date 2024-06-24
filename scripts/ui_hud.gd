extends CanvasLayer

@onready var acceleration = $Control/HBoxContainer/ColorRect2/MarginContainer2/VBoxContainer/accel
@onready var brake = $Control/HBoxContainer/ColorRect3/MarginContainer2/VBoxContainer2/brake
@onready var speed = $Control/HBoxContainer/ColorRect4/MarginContainer2/VBoxContainer3/speed
@onready var health = $Control/HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/health
@onready var shipname = $Control/HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/shipname
@onready var shipclass = $Control/HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/shipclass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true;
	acceleration.value = 0.0
	brake.value = 0.0
	speed.value = 0.0
	health.value = 100.0
	shipname.text = "Unregistered"
	shipclass.text = "Hiace Recon"
	#dockedcontainer.visible = false
	#if dockedcontainer.visible:
		#dockedto.text = "Annonymous"
	
	# self.connect("ship_engine", _on_ship_engine)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_ship_engine(ship_engine):
	acceleration.value = ship_engine.acceleration * 100 ;
	brake.value = ship_engine["brake"] * 100;
	speed.value = ship_engine.speed * 100;
	health.value = ship_engine.health;
	# print("received: ",thrust_vector, velocity)

func _on_ship_ready(ship):
	print(ship)
	shipname.text = ship["name"]
	shipclass.text = ship.class
