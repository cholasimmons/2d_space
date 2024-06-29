extends CharacterBody2D

#signal ship_engine(stats)
signal ship_is_ready(ready)
signal ship_stats(ship_stats)

var weapon_sound: AudioSample
@onready var weapon_audio_player: AudioStreamPlayer = $AudioStreamPlayer0
@onready var igniteSound: AudioStreamPlayer = $AudioStreamPlayer1
@onready var thrustSound: AudioStreamPlayer = $AudioStreamPlayer2
@onready var hatch = $Dock2D
@onready var scanner = $Proximity2D
@onready var shiphull = $ShipHull

@export var ship_name:String = 'Nebuchadnnezzer'
@export var ship_class:String = 'Destroyer'
@export_range(0,300,5) var max_speed:float = 180.0
@export var mass:float = 1.0
@export var MAX_ARMOR = 100 
@export var ship_color :Color = Color.CRIMSON 

# Consts
const THRUST_FORCE:float = 100.0
const BASE_ROTATION_SPEED = 1.8
const ACCELERATION_SPEED = 4.0
const DECELERATION_SPEED = 1.5
const MAX_HEALTH = 100.0
const BLACK_HOLE_SCENE_PATH = "res://scenes/BlackHole.tscn"

var scanner_radius = 175

# weapons
enum weapons_arsenal {
	gun,
	rocket,
	torpedo
}
var selected_weapon: weapons_arsenal = weapons_arsenal.gun
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

var collected_gems :Dictionary = {
	"BLACK": 0,
	"YELLOW": 0,
	"GREEN": 0
}

func _ready() -> void:
	add_to_group("Player")
	var ship = {
		"name":ship_name,
		"class":ship_class
	}
	shiphull.name = ship_name
	shiphull.add_to_group("Player")
	if ship_name and ship_class:
		print(ship.name, " ready to blast off")
		ship_is_ready.emit(ready)
	#hatch.connect("docked_with_ship", _on_docked_with_ship)
	
	# weapon_sound = AudioSample.new()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		reset_player()
	#if event.is_action_pressed("dock"):
		#attempt_dock()
	#if event.is_action_pressed("2"):
		#select_weapon(2)
	if event.is_action_pressed("space"):
		shoot_weapon(selected_weapon)
	if event.is_action_pressed("tab"):
		show_debug = !show_debug
	if event.is_action_pressed("blackmagic"):
		unleash_blackmagic("BLACK")
	
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
		if current_speed > 10 and !playing_ignite:
			play_ignite_sound()
	if Input.is_action_pressed("ui_down"):
		current_brake = lerp(current_brake, 0.9, DECELERATION_SPEED * delta)
		thrust_vector = Vector2(-(THRUST_FORCE/mass), 0).rotated(rotation) * current_brake

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
	
	# audio stuff
	if current_speed > 150 and !playing_thrust:
		play_thrust_sound()
	if current_speed < 150:
		thrustSound.stop()
		playing_thrust = false
		
	current_health -= 0.8 * delta
	if current_health <= 0:
		get_tree().quit()
	
	update_coordinates()	
	
	ship_stats.emit({
		"coords": coords,
		"acceleration":current_acceleration,
		"brake":current_brake,
		"thrust":thrust_vector,
		"speed":current_speed/max_speed,
		"health":current_health,
		"show":show_debug,
		"top_speed":max_speed,
		"current_speed":current_speed,
		"rot_speed":rotation,
		"rot_angle":rotation_angle,
		"gun":selected_weapon,
		"gems": collected_gems
	})


func _physics_process(_delta:float):
	pass

# Map coordinates
func update_coordinates():
	var x_coordinate = int(position.x / 1000.0)
	var y_coordinate = -int(position.y / 1000.0)

	# Update the labels with the converted coordinates
	coords = Vector2(x_coordinate, y_coordinate)


func reset_player():
	print("Resetting...")

func attempt_dock():
	print("Attempting to dock...")
	
func select_weapon(weapon_id: int):
	selected_weapon = weapons_arsenal.rocket
	#weapon_sound.set("audio")
	#weapon_audio_player.set_stream(weapon_sound)
	print("Selected weapon: ",weapon_id, selected_weapon)

func shoot_weapon(_weapon: weapons_arsenal):
	if (Time.get_time_dict_from_system()["second"] - lastShootTime) >= shootCooldown:
		#print("Firing: ",weapon)
		# Instantiate the bullet scene
		#var bullet = load(BULLET_PATH).instantiate()
		
		# Set the bullet's initial position and rotation (adjust as needed)
		#bullet.global_position = global_position  # Or use a specific spawn point
		#bullet.rotation = rotation  # Match the ship's rotation
#
		## Add the bullet to the scene
		#get_parent().add_child(bullet)
		
		#lastShootTime = Time.get_time_dict_from_system()["second"]
		
		var bullet = bulletPool.get_bullet() # Get a bullet from the pool
		
		# Check if a bullet was successfully obtained from the pool
		if bullet:
			bullet.visible = true  # Show the bullet
			# Reset bullet properties (position, rotation, etc.)
			bullet.global_position = global_position  # Or use a specific spawn point
			bullet.rotation = rotation  # Match the ship's rotation
			
			# Apply velocity to the bullet (assuming your bullet script handles this)
			bullet.velocity = Vector2(bullet.bullet_speed, 0).rotated(rotation)

			# Play shooting audio (if applicable)
			weapon_audio_player.play()
		else:
			print("Bullet pool is empty! Cannot shoot.")

		

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



# engines
func play_ignite_sound():
	# Check if the AudioStreamPlayer node is valid and the audio is not already playing
	#if playing_thrust:
		#thrustSound.volume_db -= thrustSound.volume_db * 1.5
		#thrustSound.stop()
		#playing_thrust = false
	if igniteSound and !igniteSound.is_playing() and !playing_thrust:
		igniteSound.volume_db = -8.0
		igniteSound.play()
		playing_ignite = true
	igniteSound.connect("finished", finished_ignite)

func play_thrust_sound():
	# Check if the AudioStreamPlayer node is valid and the audio is not already playing
	if playing_ignite:
		igniteSound.volume_db -= igniteSound.volume_db * 1.5
		igniteSound.stop()
		playing_ignite = false
	if thrustSound and !thrustSound.is_playing():
		thrustSound.volume_db = -12.0
		thrustSound.play()
		playing_thrust = true

func finished_ignite():
	playing_ignite = false
func finished_thrust():
	playing_thrust = false

func unleash_blackmagic(this_gem_type):
	if collected_gems.get(this_gem_type, 0) > 0:
		var black_hole = load(BLACK_HOLE_SCENE_PATH).instantiate()
		var player_position = global_position
		var offset = Vector2(-20, 0)  # Adjust offset position behind the player
		black_hole.global_position = player_position + offset
		get_parent().add_child(black_hole)
	
		collected_gems[this_gem_type] -= 1
		print("Used a ", this_gem_type, " gem! Remaining:", collected_gems["BLACK"] )
	else:
		print("No ", this_gem_type, " gems available!" )
	pass


func add_gem_power(gem_type: String):
	if collected_gems.has(gem_type):
		collected_gems[gem_type] += 1
	else:
		collected_gems[gem_type] = 1

	match gem_type:
		"YELLOW":
			# Add yellow gem power logic
			print("Collected a yellow gem! Total:", collected_gems[gem_type])
		"GREEN":
			# Add purple gem power logic
			print("Collected a green gem! Total:", collected_gems[gem_type])
		"BLACK":
			# Add black gem power logic
			print("Collected a black gem! Total:", collected_gems[gem_type])
