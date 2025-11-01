extends Node2D

enum BrickType {Normal, Heavy, Explosive}

@export var brick_data : BrickData
@export var brick_type : BrickType

var health := 1

func _ready() -> void:
	if brick_data:
		$CollisionShape2D.shape.size = brick_data.brick_size
		match brick_type:
			BrickType.Normal:
				health = 1
			BrickType.Heavy:
				health = 3
			BrickType.Explosive:
				health = 1
	print(brick_type)		

func take_hit(hit_power : int) -> void:
	health -= hit_power
	if health <= 0:
		queue_free()
