extends Node2D

# chemtrails
@onready var ship: Node2D = get_parent()
@onready var trail_l: Node2D = get_parent().get_node("trail_l")
@onready var trail_r: Node2D = get_parent().get_node("trail_r")

@export var trail_size = 1.4
@export var is_enemy:= false

const threshold_velocity = 40.0
const max_velocity = 150.0
const min_opacity = 0.1  # 10% opacity
const max_opacity = 1.0  # 100% opacity

var trail_points_left = []
var trail_points_right = []
var l: Vector2
var r: Vector2
var max_points = 80
var fade_start = 0.9

var point_opacity: float
var prev_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print("Line engines online")
	prev_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var speed = (global_position - prev_position).length() / delta

	if speed >= threshold_velocity:
		point_opacity = min_opacity + (max_opacity - min_opacity) * (speed - threshold_velocity) / (max_velocity - threshold_velocity)
		point_opacity = clamp(point_opacity, min_opacity, max_opacity)  # Clamp opacity between min and max values
		emit_points()
	
	prev_position = global_position

	# Request redraw
	queue_redraw()
	
func emit_points() -> void:
	# Get global positions of trail points
	var l_global = trail_l.global_position
	var r_global = trail_r.global_position
	
	# Add a new point to the trail with specified opacity
	trail_points_left.append(l_global)
	trail_points_right.append(r_global)

	# Remove older points (e.g., after max_points points)
	if trail_points_left.size() > max_points:
		trail_points_left.remove_at(0)
		trail_points_right.remove_at(0)

func _draw():
	var trail_color = Color(1,1,1)
	if is_enemy:
		trail_color = Color(0.698039, 0.133333, 0.133333)
	for i in range(1, trail_points_left.size()):
		var alpha = i / (max_points * fade_start)  # Gradual fading
		draw_line(to_local(trail_points_left[i]), to_local(trail_points_left[i - 1]), Color(trail_color.r, trail_color.g, trail_color.b, alpha * point_opacity ), trail_size)
	for i in range(1, trail_points_right.size()):
		var alpha = i / (max_points * fade_start)  # Gradual fading
		draw_line(to_local(trail_points_right[i]), to_local(trail_points_right[i - 1]), Color(trail_color.r, trail_color.g, trail_color.b, alpha * point_opacity ), trail_size)
