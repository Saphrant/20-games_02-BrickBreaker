extends Node2D

signal update_highscore

const SAVE_PATH = "user://score.save"

@onready var death_floor: Area2D = $PlayArea/floor
@onready var menu: CanvasLayer = $Menu
@onready var wait_timer: Timer = $WaitTimer

@export var level_scene: PackedScene

var current_highscore:int
var is_game_started: bool
var current_level_node = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_game_started = false
	GameManager.game_start_request.connect(_on_game_start_request)
	GameManager.game_over.connect(_on_game_over)
	GameManager.quit_game.connect(_on_game_quit)
	GameManager.score_animations_finished.connect(_on_score_animations_finished)
	current_highscore = player_load()
	update_highscore.emit(current_highscore)

#--- Game states ---
func _on_game_start_request(is_new_game: bool) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if is_new_game:
		if FileAccess.file_exists(SAVE_PATH):
			DirAccess.remove_absolute(SAVE_PATH)
			
	if is_instance_valid(current_level_node):
		current_level_node.queue_free()
	current_level_node = level_scene.instantiate()
	add_child(current_level_node)
	current_level_node.level_complete.connect(_on_level_complete)


func _on_level_complete() -> void:
	GameManager.on_score_anim()
	var tween = get_tree().create_tween()
	tween.tween_property(Engine, "time_scale",0.01,0.3).set_trans(Tween.TRANS_SINE)

func _on_score_animations_finished() -> void:
	Engine.time_scale = 1.0
	GameManager.on_level_up()
	_on_game_start_request(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and GameManager.is_game_started:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if not GameManager.is_paused:
			get_tree().paused = true
			GameManager.on_game_paused(true)
		elif GameManager.is_paused:
			get_tree().paused = false
			GameManager.on_game_paused(false)
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_game_over() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if GameManager.current_score > current_highscore:
		current_highscore = GameManager.current_score
		player_save()
		update_highscore.emit(current_highscore)


# --- Player Save/Load
func player_save() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(current_highscore)
	file.close()


func player_load() -> int:
	# 1. Check if file exists
	if not FileAccess.file_exists(SAVE_PATH):
		return 0
	# 2. Access file, get variables, close file
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var loaded_score = file.get_var()
	file.close()
	return loaded_score


func _on_game_quit() -> void:
	player_save()
	get_tree().call_deferred("quit")
	
