extends Node2D

@export var grid_size: int = 16
@export var next_level_scene: PackedScene

var won: bool = false

func _ready():
	if has_node("WinPopup"):
		$WinPopup.visible = false

func _process(delta):
	if not won and check_win():
		won = true
		on_win()

func check_win() -> bool:
	var boxes = get_tree().get_nodes_in_group("boxes")
	var areas = get_tree().get_nodes_in_group("areas")

	for area in areas:
		var ok := false
		for box in boxes:
			# bandingkan posisi pusat (toleransi kecil)
			if box.global_position.distance_to(area.global_position) < 1.0:
				ok = true
				break
		if not ok:
			return false
	return true

func on_win():
	print("LEVEL COMPLETE")
	if has_node("WinPopup"):
		$WinPopup.visible = true
	won = true

func _unhandled_input(event):
	if event.is_action_pressed("restart_level"):
		restart_level()

	if won and event.is_action_pressed("next_level"):
		if next_level_scene:
			get_tree().change_scene_to_packed(next_level_scene)
		else:
			print("Next level belum di-set")

func restart_level():
	get_tree().reload_current_scene()
