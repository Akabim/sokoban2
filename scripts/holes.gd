extends Area2D

@export var open_texture: Texture2D    # sprite lubang terbuka
@export var closed_texture: Texture2D  # sprite lubang tertutup (misal pakai sprite box)

var is_closed: bool = false
var level
var grid_pos: Vector2 = Vector2.ZERO

# Hole.gd
func _process(delta):
	if is_closed:
		return
	var player = get_tree().get_nodes_in_group("player")
	for p in player:
		if p.global_position.distance_to(global_position) < 8: # tolerance
			if level and level.has_method("restart_level"):
				level.restart_level()
			else:
				get_tree().reload_current_scene()


func _ready():
	add_to_group("holes")
	$Sprite2D.texture = open_texture
	$CollisionShape2D.disabled = false
	level = get_parent()

# Dipanggil kalau box didorong ke hole
func close_with_box(box):
	if is_closed:
		return
	$Sprite2D.texture = closed_texture
	is_closed = true
	# biarkan CollisionShape2D tetap aktif (supaya Area2D masih bisa deteksi body_entered)
	box.queue_free()

# Kalau player masuk hole terbuka
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player ada di area")
		if not is_closed:   # lubang masih terbuka → player mati
			if level and level.has_method("restart_level"):
				level.restart_level()
			else:
				get_tree().reload_current_scene()
