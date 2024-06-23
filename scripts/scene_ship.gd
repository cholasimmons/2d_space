extends CharacterBody2D

@onready var hatch = $Dock2D

@export var ship_name:String = 'Nebuchadnnezzer'
@export var ship_class:String = 'Destroyer'
@export var max_speed:float = 180.0
@export var mass:float = 1.0

# Consts
const THRUST_FORCE:float = 60.0
const ROTATION_SPEED = 1.8

enum weapons_arsenal {
	gun,
	rocket,
	torpedo
}
var selected_weapon: weapons_arsenal = weapons_arsenal.gun

# Variables
# velocity = Vector2.ZERO
var rotation_angle = 0.0

func _ready() -> void:
	pass
	# hatch.connect("docked_with_ship", self, "_on_docked_with_ship")

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
		print("debug")

func _process(delta: float) -> void:
	var thrust_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		thrust_vector = thrust_vector.lerp(Vector2((1.0/mass),0), 0.6)
		# thrust_vector = Vector2((1/mass), 0).rotated(rotation)
	if Input.is_action_pressed("ui_down"):
		thrust_vector = Vector2(-(0.2/mass), 0).rotated(rotation)
	
	if Input.is_action_pressed("ui_left"):
		rotation = lerp(rotation_angle, (ROTATION_SPEED/mass) * delta, 0.75)
		if velocity.length():
			rotation -= (ROTATION_SPEED/mass) * delta
	
	if Input.is_action_pressed("ui_right"):
		if velocity.length():
			rotation += (ROTATION_SPEED/mass) * delta
	
	velocity += thrust_vector.normalized() * THRUST_FORCE * delta
	position += velocity * delta


func _physics_process(delta: float) -> void:
	pass

	move_and_slide()

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
