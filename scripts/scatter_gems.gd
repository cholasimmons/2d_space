extends Node2D

# Paths to different Gem scenes
const GEM_SCENES = {
	"yellow": "res://scenes/GemYellow.tscn",
	"green": "res://scenes/GemGreen.tscn",
	"black": "res://scenes/GemBlack.tscn"
}

# Number of gems to scatter
@export var num_gems: int = 90

# Bounds for scattering the gems
@export var min_x: float = -7000
@export var max_x: float = 7000
@export var min_y: float = -6000
@export var max_y: float = 6000

# Ratios for different gem types
@export var gem_ratios = {
	"yellow": 25,
	"green": 20,
	"black": 55
}

func _ready():
	scatter_gems()

func scatter_gems():
	var gem_scenes = [GEM_SCENES["yellow"], GEM_SCENES["green"], GEM_SCENES["black"]]
	var gem_weights = [gem_ratios["yellow"], gem_ratios["green"], gem_ratios["black"]]

	for i in range(num_gems):
		var gem_scene_path = weighted_random_choice(gem_scenes, gem_weights)
		var gem_scene = load(gem_scene_path).instantiate()
		var random_x = randf_range(min_x, max_x)
		var random_y = randf_range(min_y, max_y)
		gem_scene.position = Vector2(random_x, random_y)
		#gem_scene.gem_type = "YELLOW"
		add_child(gem_scene)

func weighted_random_choice(items, weights):
	var total_weight = 0
	for weight in weights:
		total_weight += weight

	var random_weight = randf() * total_weight
	for i in range(items.size()):
		if random_weight < weights[i]:
			return items[i]
		random_weight -= weights[i]
	return items[0]  # Fallback in case of an error
