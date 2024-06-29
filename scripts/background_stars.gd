extends Node2D

# Number of stars to create
@export var star_count = 180
# Star size range
@export var min_star_size = 1
@export var max_star_size = 3
# Speed at which the background scrolls
@export var scroll_speed = 50

@onready var player = get_parent().get_node("Ship")

func _ready():
	create_stars()

func create_stars():
	var viewport_size = get_viewport().size
	for i in range(star_count):
		var star = ColorRect.new()
		star.color = Color.WHITE
		star.size = Vector2(rand_range(min_star_size, max_star_size), rand_range(min_star_size, max_star_size))
		star.position = Vector2(rand_range(0, viewport_size.x), rand_range(0, viewport_size.y))
		add_child(star)

func rand_range(mmin, mmax):
	return randi() % (mmax - mmin + 1) + mmin

func _process(delta: float) -> void:
	for star in get_children():
		var new_pos = star.position.y + scroll_speed * delta
		if new_pos > get_viewport().size.y:
			new_pos = 0  # Wrap around to the top
		star.position.y = new_pos
