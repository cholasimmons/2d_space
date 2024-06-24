extends TextureRect

@export var planet : Node2D = get_parent()
@export_range(0.5, 2, 0.25) var spin_multiplier : float = 1.2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation = planet.transform.get_rotation() *spin_multiplier
