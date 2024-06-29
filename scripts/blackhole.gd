extends Area2D

@onready var animator = get_parent().get_node("AnimationPlayer")
@onready var coll = $CollisionShape2D

@export var sound_collect: AudioStream = load("res://audio/deploy.mp3")
@onready var audio_player = AudioStreamPlayer.new()

const GRAVITY_FORCE = 1000.0  # Adjust as needed
var MAX_GRAVITY_DISTANCE = 300.0  # Maximum distance over which gravity affects ships
const SPIN_SPEED = 0.4  # Maximum distance over which gravity affects ships


func _ready():
	add_child(audio_player)
	audio_player.stream = sound_collect
	audio_player.volume_db = -3.0
	if not audio_player.is_playing():
		audio_player.play()
	# Connect the area_entered signal to handle AI ship interactions
	connect("area_entered", _on_Area2D_area_entered)
	connect("area_exited", _on_Area2D_area_exited)
	
	animator.play("blackhole_scalar")
	MAX_GRAVITY_DISTANCE = coll.shape.radius

func _on_Area2D_area_entered(area):
	if area.is_in_group("AIShip") or area.is_in_group("Player"):
		print(area)
		objects_in_area[area] = true

func _on_Area2D_area_exited(area):
	if area.is_in_group("AIShip") or area.is_in_group("Player"):
		objects_in_area.erase(area)

# Dictionary to keep track of objects within the black hole's area
var objects_in_area = {}

func _process(delta: float) -> void:
	# Spin the hole
	rotation -= (SPIN_SPEED * delta)
	
	for obj in objects_in_area.keys():
		#if obj and obj.is_instance_of(CharacterBody2D):
		apply_gravity(obj, delta)

func apply_gravity(obj, delta):
	var direction = (global_position - obj.global_position).normalized()
	var distance = global_position.distance_to(obj.global_position)

	# Calculate gravity force based on distance
	var gravity_effect = 1.0 - (distance / MAX_GRAVITY_DISTANCE)
	var gravity_force = GRAVITY_FORCE * gravity_effect

	# Apply force towards the black hole
	if obj is RigidBody2D:
		obj.apply_central_impulse((direction * gravity_force) * delta)
	else:
		# Manually adjust position for non-RigidBody2D objects
		var new_position = obj.global_position + (direction * gravity_force * delta)
		obj.global_position = new_position
	obj.queue_free()
