extends CharacterBody2D

@export var grid_size: int = 16

func _ready():
	add_to_group("bricks")
