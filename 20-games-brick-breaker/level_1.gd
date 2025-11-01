extends Node2D

@onready var top_left_marker: Marker2D = $margins/TopLeft
@onready var bottom_right_marker: Marker2D = $margins/BottomRight

@export var brick_blueprints: Array[PackedScene]
@export var brick_padding := 8

var screen_size : Vector2

var rng = RandomNumberGenerator
var rng_seed = "%s" % "level_1"
var brick_size = Vector2(100,10)
var grid_position = brick_size + (Vector2.ONE * brick_padding)
var top_left_margin := Vector2(150,100)
var bottom_margin := Vector2(50,250)

func _ready() -> void:
	screen_size = get_viewport_rect().size
	top_left_marker.global_position = Vector2(top_left_margin.x, top_left_margin.y)
	bottom_right_marker.global_position = Vector2((screen_size.x - bottom_margin.x), (screen_size.y - bottom_margin.y))
	var grid_layout = calculate_grid_layout()
	spawn_bricks(grid_layout)

func calculate_grid_layout() -> Dictionary:
	var grid_x = bottom_right_marker.global_position.x - top_left_marker.global_position.x
	var grid_y = bottom_right_marker.global_position.y - top_left_marker.global_position.y
	var grid_size = Vector2(grid_x, grid_y)
	
	var num_cols = int(grid_size.x / (brick_size.x + brick_padding))
	var num_rows = int(grid_size.y / (brick_size.y + brick_padding))
	
	return {
		"columns": num_cols,
		"rows": num_rows,
		"start_position": top_left_marker.global_position
	}


func spawn_bricks(grid_data: Dictionary) -> void:
	var start_pos = grid_data["start_position"]
	var brick_width_with_padding = brick_size.x + brick_padding
	var brick_height_with_padding = brick_size.y + brick_padding

	for y in grid_data["rows"]:
		for x in grid_data["columns"]:
			# 1. Calculate the new position
			var spawn_pos_x = start_pos.x + (x * brick_width_with_padding)
			var spawn_pos_y = start_pos.y + (y * brick_height_with_padding)
			
			# 2. Instantiate and set position
			var random_brick_scene = brick_blueprints.pick_random()
			var new_brick = random_brick_scene.instantiate()
			new_brick.global_position = Vector2(spawn_pos_x, spawn_pos_y)
			add_child(new_brick)
	
