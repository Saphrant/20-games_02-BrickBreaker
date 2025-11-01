extends CharacterBody2D

@onready var ball_spawn_point: Marker2D = %BallSpawnPoint


@export var max_speed := 900.0
@export var acceleration := 10000.0
@export var deceleration := 5000.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_node = self #Loads self into global


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO	
	direction.x = Input.get_axis("move_left", "move_right")
	
	if direction.x != 0:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	move_and_slide()
