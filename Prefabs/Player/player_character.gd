extends CharacterBody2D

##-----------
## Movement
@export_range(0, 1000) var speed := 120		## Speed in pixels per second
var drag := 5.0
var allow_input := true

##-----------
## Animation
@export var image_idle := Texture2D
@export var image_hop_up := Texture2D
@export var image_hop_down := Texture2D
@onready var move_anim := [image_hop_up, image_hop_down]
var animation_timer = 0.0
var animation_speed = 5
var animation_index = 0

##-----------
## Body Parts
@export var body_part_scene = load("uid://c11f8vvstu7t0")
@export var body_part_images : Array[Texture2D]
@onready var body_part_count := body_part_images.size()
var body_part_names := [
	"Leg_L",
	"Leg_R",
	"Arm_R",
	"Torso",
	"Arm_L",
	"Head",
	"Hat"
]
var body_part_start_positions := [
	Vector2(-9, 18), 	## Leg_L
	Vector2(9, 17), 	## Leg_R
	Vector2(14, 1), 	## Arm_R
	Vector2(0, 6),  	## Torso
	Vector2(-17, 5), 	## Arm_L
	Vector2(0, -10), 	## Head
	Vector2(0, -22) 	## Hat
]
var body_part_collider_sizes := [
	5.0,	## Leg_L
	5.0,	## Leg_R
	5.0,	## Arm_R
	11.0,	## Torso
	5,0,	## Arm_L
	11.0,	## Head
	6.0		## Hat
]
var body_part_default_angle := [
	120, 	## Leg_L
	60, 	## Leg_R
	340, 	## Arm_R
	140,  	## Torso
	190, 	## Arm_L
	340, 	## Head
	210 	## Hat
]

##-----------
## Camera Zoom
var camera_index = 0
var camera_zoom_targets = [
	Vector2(1.2, 1.2),
	Vector2(1.4, 1.4),
	Vector2(1.6, 1.6),
	Vector2(1.8, 1.8),
	Vector2(2.0, 2.0)
]


##----------------------------------------------
##                    Update                   |
##----------------------------------------------

func _physics_process(delta: float) -> void:
	get_player_input(delta)
	if move_and_slide():
		resolve_collisions()


func _process(delta: float) -> void:
	## movement
	if velocity.length() > 0.0:
		animation_timer += delta * animation_speed
		if animation_timer > 1:
			animation_timer -= 1
			animation_index += 1
			if animation_index >= move_anim.size():
				animation_index = 0
		if velocity.x < 0.0:
			$Collider/Player_Sprite.flip_h = true
		else:
			$Collider/Player_Sprite.flip_h = false
		$Collider/Player_Sprite.texture = move_anim.get(animation_index)
	else:
		$Collider/Player_Sprite.texture = image_idle
	
	## camera zoom
	if Main.ghost_timer_tick == true:
		print("ghost timer tick! do camera zoom: ", camera_zoom_targets[camera_index], "  --  index: ", camera_index)
		var tween = create_tween()
		tween.tween_property($Camera2D, "zoom", camera_zoom_targets[camera_index], 1)
		camera_index += 1


##----------------------------------------------
##             Input and Collisions            |
##----------------------------------------------

func get_player_input(delta: float) -> void:
	## input guard
	if not allow_input:
		if velocity.length_squared() > 1.0:
			velocity *= 1.0 - drag * delta
		else:
			velocity = Vector2.ZERO
		return
	
	## move towards target
	var vector := Vector2.ZERO
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		##var target_vector := get_viewport().get_mouse_position() - self.position
		var target_vector := get_global_mouse_position() - self.position
		if target_vector.length() > 5:
			vector = target_vector.normalized()
		velocity = vector * speed
		
	else:
		velocity = Vector2.ZERO
		
	## debug
	if Input.is_action_just_pressed("ui_up"):
		on_player_death(velocity)


func resolve_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body := collision.get_collider() as MoveableObject
		if body:
			body.apply_impact(velocity)


##----------------------------------------------
##            Death and Body Parts             |
##----------------------------------------------

func on_player_death(forceDirection: Vector2 = Vector2.ZERO) -> void:
	allow_input = false
	$Collider.disabled = true
	spawn_body_parts(forceDirection)
	$Collider/Player_Sprite.visible = false
	Main.global_light_scale = 0.0


func spawn_body_parts(forceDirection : Vector2) -> void:
	for i in body_part_count:
		var body_part = body_part_scene.instantiate()
		body_part.name = body_part_names[i]
		body_part.position = self.position + body_part_start_positions[i]
		body_part.set_texture( body_part_images[i] )
		body_part.set_collider_size( body_part_collider_sizes[i] )
		self.owner.add_child(body_part)
		if forceDirection == Vector2.ZERO:			
			var direction = Vector2.from_angle( deg_to_rad(body_part_default_angle[i] + randf_range(-25,25)) )
			var force = randf_range(600,1400)
			body_part.apply_impact(direction * force)
		else:
			body_part.apply_impact( (forceDirection + Vector2(randf_range(-1.0,1.0), randf_range(-1.0,1.0))) * randf_range(3.0, 8.0) )
