extends CharacterBody2D

@onready var ball_spawn_point: Marker2D = %BallSpawnPoint

@export var ball_scene: PackedScene
var held_ball = null

@export var max_speed := 800.0
@export var acceleration := 10000.0
@export var deceleration := 8000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.game_start_request.connect(_on_game_request)
	GameManager.level_up.connect(_on_level_up)
	GameManager.ball_restart.connect(_on_ball_restart)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if held_ball != null:
		held_ball.position = ball_spawn_point.position

	if Input.is_action_just_pressed("ui_accept") and is_instance_valid(held_ball):
		held_ball.launch()
		held_ball = null
		 
		GameManager.report_ball_launched()
	
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	
	if direction.x != 0:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	move_and_slide()
		
		
func spawn_new_ball() -> void:
	if held_ball == null:
		held_ball = ball_scene.instantiate()
		call_deferred("add_child", held_ball)

func _on_game_request(_is_new_game) -> void:
	spawn_new_ball()

func _on_ball_restart() -> void:
	spawn_new_ball()
	
func _on_level_up() -> void:
	spawn_new_ball()
