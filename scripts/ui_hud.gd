extends CanvasLayer

@onready var acceleration = $Control/HBoxContainer/ColorRect2/MarginContainer2/VBoxContainer/accel
@onready var brake = $Control/HBoxContainer/ColorRect3/MarginContainer2/VBoxContainer2/brake
@onready var speed = $Control/HBoxContainer/ColorRect4/MarginContainer2/VBoxContainer3/speed
@onready var health = $Control/HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/health
@onready var shipname = $Control/HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/shipname
@onready var shipclass = $Control/HBoxContainer/ColorRect5/MarginContainer2/VBoxContainer4/shipclass
@onready var label_x = $Control/HBoxContainer2/ColorRect2/MarginContainer2/VBoxContainer/label_x
@onready var label_y = $Control/HBoxContainer2/ColorRect3/MarginContainer2/VBoxContainer/label_y
@onready var gem_black = $Control/HBoxContainer2/ColorRect4/MarginContainer2/VBoxContainer/gem_black
@onready var gem_green = $Control/HBoxContainer2/ColorRect5/MarginContainer2/VBoxContainer/gem_green
@onready var gem_yellow = $Control/HBoxContainer2/ColorRect6/MarginContainer2/VBoxContainer/gem_yellow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true;
	acceleration.value = 0.0
	brake.value = 0.0
	speed.value = 0.0
	health.value = 100.0
	shipname.text = "Zictus 2000"
	shipclass.text = "Scout Class"
	label_x.text = str(0)
	label_y.text = str(0)
	#dockedcontainer.visible = false
	#if dockedcontainer.visible:
		#dockedto.text = "Annonymous"
	
	# self.connect("ship_engine", _on_ship_engine)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_ship_stats(stats):
	acceleration.value = stats.acceleration * 100 ;
	brake.value = stats["brake"] * 100;
	speed.value = stats.speed * 100;
	health.value = stats.health;
	label_x.text = str(stats.coords.x);
	label_y.text = str(stats.coords.y);
	gem_black.text = str(stats.gems["BLACK"])
	gem_yellow.text = str(stats.gems["YELLOW"])
	gem_green.text = str(stats.gems["GREEN"])
	# print("received: ",thrust_vector, velocity)

func _on_ship_ready(ship):
	print(ship.name, ship.class)
	shipname.text = ship.name
	shipclass.text = ship.class
