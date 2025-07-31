extends CharacterBody2D

## Speed in pixels per second
@export_range(0, 1000) var speed := 120

@export var image_idle := Texture2D
@export var image_hop_up := Texture2D
@export var image_hop_down := Texture2D
@onready var move_anim := [image_hop_up, image_hop_down]

var animation_timer = 0.0
var animation_speed = 5
var animation_index = 0


func _physics_process(_delta: float) -> void:
	get_player_input()
	if move_and_slide():
		resolve_collisions()


func _process(delta: float) -> void:
	if velocity.length() > 0.0:
		animation_timer += delta * animation_speed
		if animation_timer > 1:
			animation_timer -= 1
			animation_index += 1
			if animation_index >= move_anim.size():
				animation_index = 0
		if velocity.x < 0.0:
			$CollisionShape2D/Player_Sprite.flip_h = true
		else:
			$CollisionShape2D/Player_Sprite.flip_h = false
		$CollisionShape2D/Player_Sprite.texture = move_anim.get(animation_index)
	else:
		$CollisionShape2D/Player_Sprite.texture = image_idle


func get_player_input() -> void:
	var vector := Vector2.ZERO
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		##var target_vector := get_viewport().get_mouse_position() - self.position
		var target_vector := get_global_mouse_position() - self.position
		if target_vector.length() > 5:
			vector = target_vector.normalized()
	velocity = vector * speed


func resolve_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider() as MoveableObject
		if body:
			body.apply_impact(velocity)
