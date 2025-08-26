extends Node2D

@export var grid_size: int = 16
@export var move_speed: float = 200.0

var target_pos: Vector2

func _ready():
	add_to_group("player")
	target_pos = snap_to_grid(position)
	position = target_pos

func _process(delta):
	# Kalau level sudah dimenangkan → stop semua kontrol player
	if get_parent().has_method("won") and get_parent().won:
		return

	if position != target_pos:
		position = position.move_toward(target_pos, move_speed * delta)
	else:
		handle_input()

func handle_input():
	var dir := Vector2.ZERO
	if Input.is_action_just_pressed("up"):
		dir = Vector2(0, -1)
	elif Input.is_action_just_pressed("down"):
		dir = Vector2(0, 1)
	elif Input.is_action_just_pressed("left"):
		dir = Vector2(-1, 0)
	elif Input.is_action_just_pressed("right"):
		dir = Vector2(1, 0)

	if dir == Vector2.ZERO:
		return

	var next_pos = target_pos + dir * grid_size

	# cek tembok / obstacle
	if is_blocked(next_pos):
		return

	# cek ada box
	for box in get_tree().get_nodes_in_group("boxes"):
		if to_cell(box.target_pos) == to_cell(next_pos):
			var box_next = next_pos + dir * grid_size

			# cek apakah box didorong ke hole
			for hole in get_tree().get_nodes_in_group("holes"):
				if to_cell(hole.position) == to_cell(box_next) and not hole.is_closed:
					hole.close_with_box(box)
					target_pos = next_pos
					return

			# normal check
			if is_blocked(box_next) or is_box_at(box_next):
				return
			box.move(dir)
			target_pos = next_pos
			return

	target_pos = next_pos

# --- Helpers ---
func to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(round(pos.x / grid_size)), int(round(pos.y / grid_size)))

func cell_to_pos(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * grid_size, cell.y * grid_size)

func snap_to_grid(pos: Vector2) -> Vector2:
	return cell_to_pos(to_cell(pos))

func is_blocked(pos: Vector2) -> bool:
	var cell := to_cell(pos)
	var center := cell_to_pos(cell)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(grid_size, grid_size)

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, center)
	params.collide_with_areas = false
	params.collide_with_bodies = true

	var space_state = get_world_2d().direct_space_state
	var hits = space_state.intersect_shape(params)

	# Filter supaya ga hit sama diri sendiri
	for hit in hits:
		if hit.collider != self:
			return true
	return false

func is_box_at(pos: Vector2) -> bool:
	var cell = to_cell(pos)
	for box in get_tree().get_nodes_in_group("boxes"):
		if to_cell(box.target_pos) == cell:
			return true
	return false
