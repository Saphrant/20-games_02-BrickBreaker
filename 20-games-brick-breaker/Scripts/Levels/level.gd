extends Node2D

signal level_complete

@onready var current_level_index = GameManager.current_level_num

# Dictionary maps to level_db numbers
@export var brick_scenes: Dictionary = {
	1: preload("res://Scenes/Brick Types/brick_blue.tscn"),
	2: preload("res://Scenes/Brick Types/brick_green.tscn"),
	3: preload("res://Scenes/Brick Types/brick_orange.tscn"),
	4: preload("res://Scenes/Brick Types/brick_purple.tscn")
}

@export var level_db: Levels
@export_flags("Use Debug") var use_debug
@export var level_index := 1

@export var brick_size: Vector2 = Vector2(50, 20)
@export var level_start_pos: Vector2 = Vector2(466, 150)
@export var brick_padding := 1

var bricks_remaining_count: int = 0

func _ready():
	GameManager.game_over.connect(on_game_over)
	if use_debug:
		current_level_index = level_index
		print("debug mode")
	else:
		current_level_index = GameManager.current_level_num
	var level_data = level_db.get("Level_" + str(current_level_index))
	_spawn_level(level_data)

func _spawn_level(level_data: PackedStringArray):
	# Loop through Y-axis
	for y in level_data.size():
		var row_string = level_data[y]
		# Loop through X-axis
		for x in row_string.length():
			# Convert the character to an integer
			var brick_type = row_string[x].to_int()
			
			# 0 means empty, so we only spawn if > 0
			if brick_type > 0:
				var brick_scene = brick_scenes.get(brick_type)
				if brick_scene:
					var new_brick = brick_scene.instantiate()
					new_brick.position = level_start_pos + Vector2(x * (brick_size.x + brick_padding),y * (brick_size.y + brick_padding))
					call_deferred("add_child", new_brick)
					bricks_remaining_count += 1
					new_brick.brick_death.connect(_on_brick_death)


func _on_brick_death() -> void:
	bricks_remaining_count -= 1
	if bricks_remaining_count <= 0:
		level_complete.emit()

func on_game_over() -> void:
	call_deferred("queue_free")
