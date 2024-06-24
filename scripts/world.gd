extends Node2D

@onready var ship = $Ship
@onready var hud = $Hud
@onready var debug = $Debug
@onready var fader = $CanvasLayer/Fader
@onready var animationplayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ship.connect("ship_is_ready", hud._on_ship_ready)
	ship.connect("ship_engine", hud._on_ship_engine)
	ship.connect("ship_stats", debug._on_ship_stats)
	print("World Ready.")
	animationplayer.play("fade_in_anim")
	animationplayer.connect("animation_finished", _on_fade_complete)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_fade_complete():
	queue_free()
	fader.visible = false
