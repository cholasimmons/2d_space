extends CanvasLayer

@onready var audio_player = $AudioStreamPlayer  # Reference to your AudioStreamPlayer node
@onready var animation_player = $AnimationPlayer # Reference to your AnimationPlayer node
@onready var fader = $Fader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fader.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	# Fade out the music over 2 seconds
	# Start the fade-out process
	var fade_duration = 2.0  # Duration of the fade-out in seconds
	var start_volume = audio_player.volume_db  # Get the current volume
	#var end_volume = -80  # Volume level to fade to (in decibels, -80 is silent)
	
	# Set up a timer to handle the fade-out process
	var fade_timer = Timer.new()
	fade_timer.one_shot = true
	fade_timer.wait_time = fade_duration
	add_child(fade_timer)
	fade_timer.connect("timeout", _on_fade_timer_timeout)

	#audio_player.fade_target_db = end_volume
	audio_player.volume_db = start_volume  # Set initial volume to start the fade
	fade_timer.start()
	
	# Call a function to start the screen fade-out animation after the audio fade-out
	call_deferred("_start_screen_fade_out")

func _start_screen_fade_out():
	fader.visible = true;
	
	# Play the "ScreenFade" animation
	animation_player.play("screen_fade")

	# Connect a signal to start loading the main game after the fade-out completes
	#animation_player.connect("animation_finished", _on_screen_fade_out_finished)

func _on_screen_fade_out_finished():
	print("fade out finished")
	# Load the main game scene
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_fade_timer_timeout():
	audio_player.stop()
	get_tree().change_scene_to_file("res://scenes/world.tscn")
