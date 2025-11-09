extends Node

#----- UI Signals -----
signal score_update
signal level_update
signal lives_update
signal timer_update

#----- Game State Signals -----
signal game_start_request
signal game_start
signal game_over
signal ball_restart
signal level_up
signal quit_game

#----- References -----
@export var background_particle_scene: PackedScene
@onready var particle_parent: Node = $ParticleParent

#----- Variables -----
var level_timer: Timer
var level_timer_dict:= {
	"wait_time": 1.0,
	"autostart": false,
	"one_shot": false,
}
var current_level_time:= 0

var is_game_started: bool
#----- UI -----
var current_score:= 0
var current_lives:= 3
var current_level_num:= 1

func _ready() -> void:
	pass

func start_level_timer() -> void:
	level_timer = Timer.new()
	for key in level_timer_dict:
		level_timer.set(key, level_timer_dict[key])
	add_child(level_timer)
	current_level_time = 0
	level_timer.timeout.connect(_on_level_timer_timeout)
	level_timer.start()

func _stop_level_timer() -> void:
	if is_instance_valid(level_timer):
		level_timer.stop()

func on_game_start_request(is_new_game: bool) -> void:
	game_start_request.emit(is_new_game)
	current_score = 0
	current_lives = 3
	timer_update.emit(0)
	score_update.emit()
	lives_update.emit()

func game_started(is_new_ball) -> void:
	game_start.emit(is_new_ball)
	if is_new_ball:
		start_level_timer()
	

func on_restart_ball() -> void:
	ball_restart.emit()

func on_game_over() -> void:
	_stop_level_timer()
	game_over.emit()
	is_game_started = false


func on_level_up() -> void:
	current_level_num += 1
	level_up.emit()
	level_update.emit()


func on_score_update(score_amount) -> void:
	current_score += score_amount
	score_update.emit()


func on_lives_update(amount) -> void:
	if current_lives <= 1:
		on_game_over()
	else:
		current_lives -= amount
		lives_update.emit()


func on_ball_wall_collision(collision_pos, impact_normal) -> void:
	var particle_scene: GPUParticles2D = background_particle_scene.instantiate()
	particle_scene.global_position = collision_pos
	particle_scene.rotation = impact_normal.angle()-90
	particle_parent.add_child(particle_scene)
	particle_scene.emitting = true


func _on_level_timer_timeout() -> void:
	current_level_time += 1
	timer_update.emit(current_level_time)

func _on_game_quit() -> void:
	quit_game.emit()
