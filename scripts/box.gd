extends Node2D

@export var grid_size: int = 16
@export var box_id: int = 0

var target_pos: Vector2

func _ready():
	target_pos = position
	add_to_group("boxes")

func _process(delta):
	if position.distance_to(target_pos) > 0.5:
		position = position.move_toward(target_pos, 200 * delta)
	else:
		position = target_pos

func move(dir: Vector2):
	target_pos += dir * grid_size
