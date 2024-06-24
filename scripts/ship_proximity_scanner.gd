extends Area2D

@onready var collision_shape = $CollisionShape2D  # Adjust the path to your CollisionShape2D node
var circle_shape: CircleShape2D

signal scanner_alert(detected)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_shape.visible = true;
	circle_shape = collision_shape.shape
	# connect("body_entered", self, "_on_body_entered")
	print("Current Radius: ", get_radius())
	set_radius(250)  # Adjust the radius value as needed
	print("New Radius: ", get_radius())
	
func _on_body_entered(body):
	emit_signal("scanner_alert", body)
	print("detected: ",get_radius(), body)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Function to get the radius of the circular collision shape
func get_radius() -> float:
	return circle_shape.radius

# Function to set the radius of the circular collision shape
func set_radius(new_radius: float) -> void:
	circle_shape.radius = new_radius
