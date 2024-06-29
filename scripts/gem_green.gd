extends Node2D

@export var sound_collect: AudioStream = load("res://audio/powerup_regular.mp3")
@onready var audio_player = AudioStreamPlayer.new()

@onready var animator = $AnimationPlayer
@onready var image = $Sprite2D
@onready var area = $Area2D
var gem_type = "GREEN"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(audio_player)
	audio_player.stream = sound_collect
	
	match gem_type:
		"YELLOW":
			image.texture = load("res://art/gem_yellow.png")
		"BLACK":
			image.texture = load("res://art/gem_black.png")
		"GREEN":
			image.texture = load("res://art/gem_green.png")
		_:
			image.texture = load("res://art/gem_red.png")
	
	# Connect the body_entered signal to detect the player
	area.connect("body_entered", _on_body_entered)
	
	animator.get_animation("gem_pulse").loop = true
	animator.play("gem_pulse")
	pass # Replace with function body.

func _on_body_entered(body):
	if body.is_in_group("Player"):
		_collect_gem(body)

func _collect_gem(the_player):
	# Play the collection sound
	if not audio_player.is_playing():
		audio_player.play()

	# Add the gem's powers to the player's ship
	the_player.add_gem_power(gem_type)

	# Animate the gem out of view
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.6, 0.6), 0.2)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4)
	tween.tween_callback(self.queue_free)

#func _on_tween_completed(tween, object):
	#queue_free()  # Remove the gem from the scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
