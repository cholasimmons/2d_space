extends Node2D

@onready var planet = $"."
@onready var ring = $TextureRect
@export var planet_name = "Titus"
@export var rotation_speed = 0.05


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var scl = transform.get_scale()
	print(scl[0])
	pass
	# Ensure the ring is centered around the planet
	# ring.position = planet.position

	# Optionally, connect any other animations or signals


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += rotation_speed * delta
