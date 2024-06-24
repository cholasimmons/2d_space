extends Camera2D

@onready var ship:Node2D = get_parent().get_node("Ship")  # Adjust the path to your ship node

# Define the minimum and maximum zoom levels
@export var min_zoom: Vector2 = Vector2(0.9, 0.9)
@export var max_zoom: Vector2 = Vector2(1.8, 1.8)
@export var zoom_speed: float = 0.2 # Define the zoom speed

# Define variables
@export var screen_threshold: float = 0.25  # 15% of the screen size
@export var smoothing_speed: float = 5.0  # Adjust the smoothing speed
var target_position: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure the camera starts with the correct zoom level
	zoom = Vector2(1, 1)
	
	is_current()
	if ship:
		target_position = ship.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ship:
		# Calculate the screen threshold distance
		var screen_size = get_viewport().size
		var threshold_distance = screen_size * screen_threshold

		# Calculate the difference between the camera's position and the ship's position
		var difference = ship.position - global_position
		
		# Create a circular area around the camera position
		var radius = threshold_distance.length()
		var within_threshold = difference.length() < radius

		# Check if the ship is beyond the threshold distance
		if not within_threshold:
			# Set the target position to the ship's position minus the threshold distance
			target_position = ship.position - (difference.sign() * threshold_distance)
		else:
			# Smoothly interpolate the camera's position to the ship's position within the threshold
			target_position = ship.position
		# Smoothly interpolate the camera's position to the target position
		global_position = global_position.lerp(target_position, smoothing_speed * delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()
	#elif event is InputEventGesture and event.gesture_type == InputEventGesture.GESTURE_PINCH:
		## Handle pinch zoom on mobile devices
		#if event.factor < 1.0:
			#zoom_in(event.factor)
		#else:
			#zoom_out(event.factor)

func zoom_in(factor: float = 1.0):
	var new_zoom = zoom + Vector2(zoom_speed * factor, zoom_speed * factor)
	zoom = new_zoom.clamp(min_zoom, max_zoom)

func zoom_out(factor: float = 1.0):
	var new_zoom = zoom - Vector2(zoom_speed * factor, zoom_speed * factor)
	zoom = new_zoom.clamp(min_zoom, max_zoom)
	
