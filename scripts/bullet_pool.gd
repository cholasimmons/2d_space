extends Node

const MAX_BULLETS: int = 50  # Adjust this value based on your game's needs
const BULLET_PATH: String = "res://scenes/Bullet.tscn"

var bullets: Array = []

func _ready():
	# Preload the bullet scene
	preload(BULLET_PATH)

	# Populate the bullet pool
	for i in range(MAX_BULLETS):
		var bullet = load(BULLET_PATH).instantiate()
		bullet.visible = false  # Initially hide bullets
		add_child(bullet)
		bullets.append(bullet)

func get_bullet():
	# Get a bullet from the pool
	for bullet in bullets:
		if !bullet.visible:
			return bullet

	# If no available bullet, create a new one (expand the pool if needed)
	if bullets.size() < MAX_BULLETS:
		var new_bullet = load(BULLET_PATH).instantiate()
		new_bullet.visible = false
		add_child(new_bullet)
		bullets.append(new_bullet)
		return new_bullet

	# If the pool is full, return null (handle this case in the calling function)
	return null
