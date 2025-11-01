extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var ball_parent: Node = $Balls

@export var ball_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_ball()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _spawn_ball() -> void:
	var new_ball = ball_scene.instantiate()
	var spawn_pos = player.ball_spawn_point
	
	new_ball.global_position = spawn_pos.global_position
	
	ball_parent.add_child(new_ball)
