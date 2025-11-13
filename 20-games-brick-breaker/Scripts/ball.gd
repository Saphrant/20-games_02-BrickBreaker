extends CharacterBody2D

@onready var ball_hum: AudioStreamPlayer2D = $ball_hum

var initial_y_velocity := 500.0
var current_ball_velocity : float
var min_vertical_speed := 150
var launch_x = 10

var is_in_air := false
var is_held = true

func _ready() -> void:
	current_ball_velocity = initial_y_velocity
	GameManager.level_up.connect(_on_level_up)

func _physics_process(_delta: float) -> void:
	if is_held: #Checks if ball is on paddle
		return
		
	move_and_slide()
	
	#Getting collision data to simulate bounce
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
			GameManager.report_paddle_hit()
		elif collision.get_collider().is_in_group("brick"):
			velocity = velocity.bounce(normal)
			velocity = velocity * 1.005
			GameManager.on_ball_brick_collision(collider)
		else:
			velocity = velocity.bounce(normal)
			var collision_pos = collision.get_position()
			GameManager.on_ball_wall_collision(collision_pos, normal)
			
		current_ball_velocity = velocity.length()
		var speed_percent = velocity.length() / current_ball_velocity
		ball_hum.pitch_scale = 1.0 + (speed_percent * 0.5)
	if abs(velocity.y) < min_vertical_speed:
		velocity.y = sign(velocity.y) * min_vertical_speed

func launch() -> void:
	if not is_held:
		return
	is_held = false
	reparent(get_tree().current_scene)
	velocity = Vector2(launch_x, -initial_y_velocity)
	is_in_air = true

func _on_level_up() -> void:
	call_deferred("queue_free")
