extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var ball_parent: Node = $Balls
@onready var death_floor: Area2D = $Walls/floor

@export var ball_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_ball()
	death_floor.lose_life.connect(_new_ball)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _spawn_ball() -> void:
	var new_ball = ball_scene.instantiate()
	var spawn_pos = player.ball_spawn_point
	new_ball.global_position = spawn_pos.global_position
	ball_parent.call_deferred("add_child", new_ball)
	
func _new_ball() -> void:
	_spawn_ball()
