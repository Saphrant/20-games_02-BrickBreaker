extends CharacterBody2D

@export var max_speed := 800.0
@export var acceleration := 8000.0
@export var deceleration := 6000.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO	
	direction.x = Input.get_axis("move_left", "move_right")
	
	if direction.x != 0:
		var desired_velocity := direction * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	print(velocity)
	move_and_slide()
