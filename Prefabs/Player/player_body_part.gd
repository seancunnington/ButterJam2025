extends MoveableObject


##func set_position(newPosition: Vector2) -> void:
##	self.position = newPosition

func set_texture(newTexture: Texture2D) -> void:
	$CollisionShape2D/Sprite2D.texture = newTexture

func set_collider_size(newSize: float) -> void:
	$CollisionShape2D.shape.radius = newSize
