extends Node2D

@onready var this = get_node(".")

const bullet_speed: float = 520  
const rocket_speed: float = 420 
const missile_speed: float = 250

var velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	 # Set the bullet's initial velocity to move straight ahead in global space
	velocity = Vector2(bullet_speed, 0).rotated(rotation)
	print("Fired!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Move the bullet based on its velocity
	translate(velocity * delta)

	# Destroy the bullet when it goes out of view
	if !get_viewport_rect().has_point(global_position):
		
		#print("DELETE BULLET")
		queue_free()
