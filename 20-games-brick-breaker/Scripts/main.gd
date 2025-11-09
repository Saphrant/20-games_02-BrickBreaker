extends Node2D

signal update_highscore
signal score_anim

const SAVE_PATH = "user://score.save"

@onready var death_floor: Area2D = $PlayArea/floor
@onready var menu: CanvasLayer = $Menu
@onready var wait_timer: Timer = $WaitTimer

@export var level_scene: PackedScene

var current_highscore:int
var is_game_started: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.visible = true
	is_game_started = false
	GameManager.game_start_request.connect(_on_game_start_request)
	GameManager.game_over.connect(_on_game_over)
	GameManager.quit_game.connect(_on_game_quit)
	current_highscore = player_load()
	update_highscore.emit(current_highscore)

#--- Game states ---
func _on_game_start_request(is_new_game: bool) -> void:
	if is_new_game:
		if FileAccess.file_exists(SAVE_PATH):
			DirAccess.remove_absolute(SAVE_PATH)
	var new_level = level_scene.instantiate()
	add_child(new_level)
	new_level.level_complete.connect(_on_level_complete)
	menu.visible = false


func _on_level_complete() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(Engine, "time_scale",0,0.2).set_trans(Tween.TRANS_SINE)
	wait_timer.start()
	await wait_timer.timeout
	tween.kill()
	GameManager.on_level_up()
	score_anim.emit()
	Engine.time_scale = 1.0
	_on_game_start_request(false)
	

func _on_game_over() -> void:
	menu.visible = true
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
	
