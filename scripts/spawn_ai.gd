extends Node2D

# Reference to the AI ship scene
@export var ai_ship_scene: PackedScene = load("res://scenes/ai_ship.tscn")

# Number of AI ships to spawn
@export var ships_per_spawn: int = 2

# Margin size around the viewport for spawning AI ships
@export var margin: int = 786

# Spawn interval in seconds
@export var spawn_interval: float = 70.0

func _ready():
	spawn_ai_ships()
	
	# Set a timer to spawn AI ships every spawn_interval seconds
	var spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", spawn_ai_ships)
	add_child(spawn_timer)

func spawn_ai_ships():
	var viewport_size = get_viewport().size
	var viewport_rect = Rect2(Vector2.ZERO, viewport_size)

	for i in range(ships_per_spawn):
		var ai_ship = ai_ship_scene.instantiate()
		var spawn_position = get_random_position_outside_viewport(viewport_rect)
		ai_ship.position = spawn_position
		add_child(ai_ship)

func get_random_position_outside_viewport(viewport_rect: Rect2) -> Vector2:
	var random_position = Vector2()
	var side = randi() % 4  # Choose a random side: 0 = top, 1 = right, 2 = bottom, 3 = left

	match side:
		0:  # Top
			random_position.x = randf() * viewport_rect.size.x
			random_position.y = -margin
		1:  # Right
			random_position.x = viewport_rect.size.x + margin
			random_position.y = randf() * viewport_rect.size.y
		2:  # Bottom
			random_position.x = randf() * viewport_rect.size.x
			random_position.y = viewport_rect.size.y + margin
		3:  # Left
			random_position.x = -margin
			random_position.y = randf() * viewport_rect.size.y

	return random_position
