extends CharacterBody2D

signal ship_engine(stats)
signal ship_is_ready(ready)
signal ship_stats(ship_stats)

@onready var hatch = $Dock2D
@onready var scanner = $Proximity2D

# chemtrails
@onready var line2d_l = $Line2D_L
@onready var line2d_r = $Line2D_R
@onready var lefttip = $lefttip
@onready var righttip = $righttip
@onready var timer = $Timer

@export var ship_name:String = 'Nebuchadnnezzer'
@export var ship_class:String = 'Destroyer'
@export_range(0,300,5) var max_speed:float = 180.0
@export var mass:float = 1.0
@export var MAX_ARMOR = 100 
@export var ship_color :Color = Color.CRIMSON 

# Consts
const THRUST_FORCE:float = 110.0
const BASE_ROTATION_SPEED = 1.8
const ACCELERATION_SPEED = 4.0
const DECELERATION_SPEED = 1.5
const MAX_HEALTH = 100.0

var scanner_radius = 175

enum weapons_arsenal {
	gun,
	rocket,
	torpedo
}
var selected_weapon: weapons_arsenal = weapons_arsenal.gun

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

var show_debug := false;

# chemtrails
var trail_points_left = []
var trail_points_right = []

func _ready() -> void:
	timer.wait_time = 0.1
	timer.connect("timeout", _on_Timer_timeout)
	timer.start();
	
	var ready = {
		"name":ship_name,
		"class":ship_class
	}
	if ship_name and ship_class:
		await emit_signal("ship_is_ready", ready)
	hatch.connect("docked_with_ship", _on_docked_with_ship)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		reset_player()
	if event.is_action_pressed("dock"):
		attempt_dock()
	if event.is_action_pressed("2"):
		select_weapon(2)
	if event.is_action_pressed("space"):
		shoot_weapon(selected_weapon)
	if event.is_action_pressed("tab"):
		show_debug = !show_debug
	
	# Check for Shift key pressed along with left/right arrow keys
	if Input.is_action_pressed("shift") and Input.is_action_pressed("ui_left"):
		is_strafing = true
		print("Strafing Left")
		move_strafe(-1)  # Move left when strafing
	elif Input.is_action_pressed("shift") and Input.is_action_pressed("ui_right"):
		is_strafing = true
		print("Strafing Right")
		move_strafe(1)  # Move right when strafing
	else:
		is_strafing = false

func _process(delta: float) -> void:
	var thrust_vector = Vector2.ZERO
	# Calculate rotation speed based on mass
	var rotation_speed = BASE_ROTATION_SPEED / mass
	
	if Input.is_action_pressed("ui_up"):
		# Update acceleration multiplier based on input
		current_acceleration = lerp(current_acceleration, 1.0, ACCELERATION_SPEED * delta)
		thrust_vector = Vector2((THRUST_FORCE/mass), 0).rotated(rotation) * current_acceleration
	elif Input.is_action_pressed("ui_down"):
		current_brake = lerp(current_brake, 0.9, DECELERATION_SPEED * delta)
		thrust_vector = Vector2(-(THRUST_FORCE/mass), 0).rotated(rotation) * current_brake
	else:
		current_acceleration = lerp(current_acceleration, 0.0, ACCELERATION_SPEED * delta)
		current_brake = lerp(current_brake, 0.0, DECELERATION_SPEED * delta)
	
	
	# Regular left/right movement code here
	if Input.is_action_pressed("ui_left") and not Input.is_action_pressed("shift"):
		if velocity.length():
			target_rotation_multiplier = 1.0
			rotation -= rotation_speed * rotation_multiplier * delta
	elif Input.is_action_pressed("ui_right") and not Input.is_action_pressed("shift"):
		if velocity.length():
			target_rotation_multiplier = 1.0
			rotation += rotation_speed * rotation_multiplier * delta
	else:
		target_rotation_multiplier = 0.0
	
	# Smoothly interpolate the rotation multiplier towards the target
	rotation_multiplier = lerp(rotation_multiplier, target_rotation_multiplier, rotation_speed * delta)
	# Ensure the rotation multiplier is clamped to prevent overshooting
	rotation_multiplier = clamp(rotation_multiplier, 0.0, 1.0)
	
	# Regular left/right movement code here
	if Input.is_action_pressed("freeze"):
		rotation_multiplier = lerp(rotation_multiplier, 0.0, rotation_speed * delta)


	# Update cooldown timer
	if not can_strafe:
		strafe_cooldown -= delta
		if strafe_cooldown <= 0:
			can_strafe = true
			strafe_cooldown = 10  # Reset cooldown time
	
	velocity += thrust_vector * delta
	# Limit the velocity to max_speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	 # Update position based on velocity
	position += velocity * delta
	
	# Calculate and update the current speed
	current_speed = velocity.length()
	
	var ship = {
		"acceleration":current_acceleration,
		"brake":current_brake,
		"thrust":thrust_vector,
		"speed":current_speed/max_speed,
		"health":current_health
	}
	emit_signal("ship_engine", ship)
	emit_signal("ship_stats", {
		"show":show_debug,
		"thrust_force":THRUST_FORCE,
		"top_speed":max_speed,
		"current_speed":current_speed,
		"rot_speed":rotation_multiplier,
		"rot_angle":rotation_angle,
		"gun":selected_weapon
	})
	
	# Update the time for each trail point
	for point in trail_points_left:
		point["time"] += delta
	for point in trail_points_right:
		point["time"] += delta

	# Remove points older than 2 seconds
	trail_points_left = trail_points_left.filter(func(point):
		return point["time"] <= .5
	)
	trail_points_right = trail_points_right.filter(func(point):
		return point["time"] <= .5
	)

	# Update the Line2D points
	_update_line2d()

func _physics_process(_delta:float):
	pass



func reset_player():
	print("Resetting...")

func attempt_dock():
	print("Attempting to dock...")
	
func select_weapon(weapon_id: int):
	selected_weapon = weapons_arsenal.rocket
	print("Selected weapon: ",weapon_id, selected_weapon)

func shoot_weapon(weapon: weapons_arsenal):
	print("Firing: ",weapon)

func _on_docked_with_ship(other_ship):
	print("docked with: ", other_ship.name)

# Function to handle strafing left/right
func move_strafe(direction):
	var movement =  transform.basis_xform(Vector2(0, direction * strafe_speed/mass))
	# Apply movement here based on your game's logic
	# For example:
	#position += movement
	position = lerp(position, position+movement, 0.9)
	# move_and_slide(movement)  # Apply strafe movement in local space

	# Start cooldown timer
	can_strafe = false

func _on_Timer_timeout():
	var left_tip_position = lefttip.global_position
	var right_tip_position = righttip.global_position
	# Add the new points to the trail
	trail_points_left.append({
		"position": left_tip_position,
		"time": 0.0  # Initialize the time for fading
	})
	trail_points_right.append({
		"position": right_tip_position,
		"time": 0.0  # Initialize the time for fading
	})

	# Update the Line2D points
	_update_line2d()
	
func _update_line2d():
	line2d_l.clear_points()
	line2d_r.clear_points()

	for point in trail_points_left:
		#var alpha = 1.0
		#if point["time"] > 1.0:
			#alpha = 2.0 - point["time"]  # Fade out in the second second
		#var color = Color(1, 1, 1, alpha)  # White color with varying alpha
		line2d_l.add_point(point["position"])
		#line2d_l.default_color(line2d_l.get_point_count() - 1, color)

	for point in trail_points_right:
		#var alpha = 1.0
		#if point["time"] > 1.0:
			#alpha = 2.0 - point["time"]  # Fade out in the second second
		#var color = Color(1, 1, 1, alpha)  # White color with varying alpha
		line2d_r.add_point(point["position"])
		#line2d_r.default_color(line2d_r.get_point_count() - 1, color)
