extends Node2D

@onready var ship = $Ship
@onready var hud = $Hud
@onready var debug = $Debug
@onready var fader = $CanvasLayer/Fader
@onready var animationplayer = $AnimationPlayer
@onready var audioplayer = $AudioStreamPlayer

# procedural | grid manager
@export var grid_size = Vector2(1024, 1024)  # Size of each grid cell
@export var grid_count = 20  # Number of grid cells in one dimension (total grids will be grid_count^2)
@export var random_seed = 42  # Seed for random generation
@export var load_radius = 2  # Number of grids around the player to keep loaded


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ship.connect("ship_is_ready", hud._on_ship_ready)
	ship.connect("ship_stats", hud._on_ship_stats)
	print("World Ready.")
	animationplayer.play("fade_in_anim")
	animationplayer.connect("animation_finished", _on_fade_complete)
	#audioplayer.stop()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_fade_complete():
	queue_free()
	fader.visible = false
