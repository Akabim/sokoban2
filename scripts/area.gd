extends Area2D

@export var area_id: int = 0
@export var grid_size: int = 16
@export var strict_mode: bool = false

func _ready():
	# posisi diambil dari editor; tidak di-snap otomatis
	add_to_group("areas")
