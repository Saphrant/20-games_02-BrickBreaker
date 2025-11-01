extends CharacterBody2D


var initial_ball_velocity := 800.0
var current_ball_velocity : float

var is_in_air := false

func _ready() -> void:
	current_ball_velocity = initial_ball_velocity

func _physics_process(_delta: float) -> void:
	if not is_in_air:
		global_position.x = get_tree().get_first_node_in_group("paddle").global_position.x

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and not is_in_air:
		velocity.y = -initial_ball_velocity
		is_in_air = true
		
	move_and_slide()
	
	if get_slide_collision_count() > 0 and is_in_air:
		var collision := get_slide_collision(0)
		var collider := collision.get_collider()
		var normal := collision.get_normal()
		
		if collision.get_collider().is_in_group("paddle"):
			var shape_width = collider.get_node("CollisionShape").shape.size.y
			var shape_half_width = shape_width/2
			var shape_offset_x = global_position.x - collider.global_position.x
			var influence_x = clamp(shape_offset_x / shape_half_width, -1.0, 1.0)
			var bounce_vector = Vector2(influence_x, -1.0).normalized()
			velocity = bounce_vector * current_ball_velocity
		elif collision.get_collider().is_in_group("brick"):
			velocity = velocity.bounce(normal)
			velocity = velocity * 1.005
			collider.take_hit(1)
		else:
			velocity = velocity.bounce(normal)
		current_ball_velocity = velocity.length()
