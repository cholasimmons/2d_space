extends Node2D

@export var grid_size = Vector2(1024, 1024)  # Size of each grid cell
@export var grid_count = 20  # Number of grid cells in one dimension (total grids will be grid_count^2)
@export var seed = 42  # Seed for random generation
@export var load_radius = 2  # Number of grids around the player to keep loaded

var grids = {}
var loaded_grids = {}

func _ready():
	randomize_with_seed(seed)
	set_process(true)
	#generate_playable_area()

func _process(delta):
	update_loaded_grids()

func randomize_with_seed(seed):
	RandomNumberGenerator.new().seed = seed

func generate_playable_area():
	for x in range(grid_count):
		for y in range(grid_count):
			var grid_position = Vector2(x, y)
			grids[grid_position] = generate_grid_content(grid_position)
			create_grid_visual(grid_position)

func generate_grid_content(grid_position: Vector2) -> Dictionary:
	var content = {}
	content.planets = generate_planets()
	content.asteroids = generate_asteroids()
	return content

func generate_planets() -> Array:
	var planets = []
	var planet_count = randi_range(1, 5)
	for i in range(planet_count):
		planets.append({
			"position": Vector2(randf_range(0, grid_size.x), randf_range(0, grid_size.y)),
			"size": randf_range(50, 150)
		})
	return planets

func generate_asteroids() -> Array:
	var asteroids = []
	var asteroid_count = randi_range(5, 20)
	for i in range(asteroid_count):
		asteroids.append({
			"position": Vector2(randf_range(0, grid_size.x), randf_range(0, grid_size.y)),
			"size": randf_range(10, 50)
		})
	return asteroids

func update_loaded_grids():
	var player_position = get_node("Ship").global_position
	var player_grid = Vector2(int(player_position.x / grid_size.x), int(player_position.y / grid_size.y))

	for x in range(player_grid.x - load_radius, player_grid.x + load_radius + 1):
		for y in range(player_grid.y - load_radius, player_grid.y + load_radius + 1):
			var grid_position = Vector2(x, y)
			if grid_position in grids and grid_position not in loaded_grids:
				load_grid(grid_position)

	var grids_to_unload = []
	for grid_position in loaded_grids:
		if grid_position.distance_to(player_grid) > load_radius:
			grids_to_unload.append(grid_position)

	for grid_position in grids_to_unload:
		unload_grid(grid_position)

func load_grid(grid_position: Vector2):
	if grid_position in grids:
		var grid_node = Node2D.new()
		grid_node.name = "Grid_%s_%s" % [grid_position.x, grid_position.y]
		grid_node.position = grid_position * grid_size
		add_child(grid_node)
		loaded_grids[grid_position] = grid_node

		for planet in grids[grid_position].planets:
			var planet_node = create_planet_visual(planet)
			grid_node.add_child(planet_node)

		for asteroid in grids[grid_position].asteroids:
			var asteroid_node = create_asteroid_visual(asteroid)
			grid_node.add_child(asteroid_node)

func unload_grid(grid_position: Vector2):
	if grid_position in loaded_grids:
		var grid_node = loaded_grids[grid_position]
		remove_child(grid_node)
		grid_node.queue_free()
		loaded_grids.erase(grid_position)

func create_grid_visual(grid_position: Vector2):
	var grid_node = Node2D.new()
	grid_node.position = grid_position * grid_size
	add_child(grid_node)

	for planet in grids[grid_position].planets:
		var planet_node = create_planet_visual(planet)
		grid_node.add_child(planet_node)

	for asteroid in grids[grid_position].asteroids:
		var asteroid_node = create_asteroid_visual(asteroid)
		grid_node.add_child(asteroid_node)

func create_planet_visual(planet_data: Dictionary) -> Node2D:
	var planet_node = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/planet_texture_1.jpg")
	sprite.scale = Vector2(planet_data.size / 100, planet_data.size / 100)
	planet_node.position = planet_data.position
	planet_node.add_child(sprite)
	return planet_node

func create_asteroid_visual(asteroid_data: Dictionary) -> Node2D:
	var asteroid_node = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/asteroid_texture_1.jpg")
	sprite.scale = Vector2(asteroid_data.size / 50, asteroid_data.size / 50)
	asteroid_node.position = asteroid_data.position
	asteroid_node.add_child(sprite)
	return asteroid_node
