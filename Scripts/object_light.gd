extends PointLight2D



## Maximum jitter offset per dimension, in pixels
@export var jitter_offset := 2.5

## How fast the light changes, in jitters per second
@export var jitter_speed := 4.0

@export_range(0.0, 30.0) var jitter_range := 10.0
@export var light_move_speed := 50.0

@export var light_cookies : Array[Texture2D]
var index_change = 0
var index_change_cap = 10
var light_index = 0
var light_position_target := Vector2.ZERO

var progress := 0.0


func _process(delta: float) -> void:
	progress += delta * jitter_speed
	if progress >= 1.0:
		progress -= 1.0
		jitter()
		toggle_rotate_cookie()
	position = position.move_toward(light_position_target, delta * light_move_speed)


func jitter() -> void:
	var p := Vector2(
		randf_range(-jitter_offset, jitter_offset),
		randf_range(-jitter_offset, jitter_offset)
	)
	light_position_target = p


func toggle_rotate_cookie() -> void:
	index_change += 1
	if index_change > index_change_cap:
		index_change = 0
		index_change_cap = randf_range(5,20)
		light_index += 1
		if light_index >= light_cookies.size():
			light_index = 0
		texture = light_cookies[light_index]
	rotation_degrees += randf_range(-jitter_range, jitter_range)
	texture_scale = clamp(texture_scale + randf_range(-0.08, 0.08), 0.2, 0.6)
	
	
