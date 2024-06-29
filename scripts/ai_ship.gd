extends CharacterBody2D

@export var ship_name:String = 'Governer'
@export var ship_class:String = 'Destroyer'
@export_range(0,300,5) var max_speed:float = 90.0
@export var mass:float = 1.4
@export var MAX_ARMOR = 120 
@export var ship_color :Color = Color.DARK_RED

# Reference to the player node
@export var player: NodePath = "../../Ship"
var player_instance: Node2D

# Consts

const BASE_ROTATION_SPEED = .6
const ACCELERATION_SPEED = 1.2
const DECELERATION_SPEED = 1.8
const MAX_HEALTH = 100.0
const MIN_DISTANCE_TO_PLAYER: float = 210.0
const MIN_DISTANCE_BETWEEN_SHIPS: float = 140.0

var scanner_radius = 175


const BULLET_PATH: String = "res://scenes/Bullet.tscn"
@onready var bulletPool = load("res://scenes/BulletPool.tscn").instantiate()
var shootCooldown: float = 0.2  # Adjust this value based on your game's needs
var lastShootTime: float = 0.0

# Variables
# velocity = Vector2.ZERO
var is_strafing:bool = false
var strafe_speed = 10  # Adjust as needed
var strafe_cooldown = 10  # Cooldown time in seconds
var can_strafe = true  # Flag to track if strafing is allowed

var current_acceleration = 0.0
var current_brake = 0.0
var current_speed = 0.0
var current_health = 100.0
var current_armor = 0.0
var rotation_angle = 0.0
var rotation_multiplier := 0.0
var rotation_deceleration = 0.3  # Adjust the rate of reduction
var target_rotation_multiplier = 0.0
var coords:Vector2 = Vector2.ZERO # XY map coordinates

var show_debug := false;

# audio
var playing_ignite:= false
var playing_thrust:= false

func _ready() -> void:
	player_instance = get_node(player)
	add_to_group("AIShip")


func _process(delta: float) -> void:
	seek_and_follow_player(delta)
	avoid_other_ships(delta)
	#attack_when_ready()
	
func seek_and_follow_player(delta):
	var direction = (player_instance.position - position).normalized()
	var distance_to_player = position.distance_to(player_instance.position)

	# Maintain at least 100 units distance from the player
	if distance_to_player < MIN_DISTANCE_TO_PLAYER:
		direction *= -1  # Reverse direction to move away from the player

	# Gradually turn towards the player
	var desired_angle = direction.angle()
	var current_angle = rotation
	var angle_diff = wrap_angle(desired_angle - current_angle)
	rotation += clamp(angle_diff, -BASE_ROTATION_SPEED * delta, BASE_ROTATION_SPEED * delta)

	# Accelerate or decelerate towards the player
	if velocity.length() < max_speed:
		velocity += Vector2(cos(rotation), sin(rotation)) * ACCELERATION_SPEED
	else:
		velocity -= velocity.normalized() * DECELERATION_SPEED
	# Clamp the velocity to max speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	position += velocity * delta
	move_and_slide()

# AI behavior to avoid other ships
func avoid_other_ships(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)

	if collision and collision.get_collider() is CharacterBody2D:
		
		var other_ship = collision.get_collider()
		var distance_to_other_ship = position.distance_to(other_ship.position)
		#print(other_ship.name, " is ", distance_to_other_ship, " units away")

		# Calculate direction away from the other ship if too close
		if distance_to_other_ship < MIN_DISTANCE_BETWEEN_SHIPS:
			var direction_away = (position - other_ship.position).normalized()
			var move_away = direction_away * ACCELERATION_SPEED

			# Adjust velocity to move away from the other ship
			velocity += move_away * delta

			# Clamp the velocity to max speed
			if velocity.length() > max_speed:
				velocity = velocity.normalized() * max_speed

func wrap_angle(angle):
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle

func attack_when_ready():
	pass
