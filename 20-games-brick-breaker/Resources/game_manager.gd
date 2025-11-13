extends Node

#----- UI Signals -----
signal score_update
signal level_update
signal lives_update
signal timer_update
signal bonus_score
signal score_animations_finished
signal combo_hit

#----- Game State Signals -----
signal game_start_request
signal game_start
signal game_paused
signal game_over
signal ball_restart
signal level_up
signal quit_game

#----- References -----
@export var background_particle_scene: PackedScene
@onready var particle_parent: Node = $ParticleParent

#----- SFX -----
@onready var wall_hit_1: AudioStreamPlayer2D = $SFX/WallHit1
@onready var wall_hit_2: AudioStreamPlayer2D = $SFX/WallHit2
@onready var combo_alarm: AudioStreamPlayer2D = $SFX/ComboAlarm
@onready var brick_break_1: AudioStreamPlayer2D = $SFX/BrickBreak1
@onready var paddle_hit_1: AudioStreamPlayer2D = $SFX/PaddleHit1
@onready var paddle_hit_2: AudioStreamPlayer2D = $SFX/PaddleHit2
@onready var ui_stamp_02: AudioStreamPlayer = $SFX/UiStamp02
@onready var counting: AudioStreamPlayer = $SFX/UiTextTypeScrollEffect05
@onready var deduction: AudioStreamPlayer = $SFX/UiTextTypeScrollEffect06
@onready var ball_death_sfx: AudioStreamPlayer = $SFX/BallDeath

var wall_hit_sounds : Array
var paddle_hit_sounds : Array
#----- Variables -----
var level_timer: Timer
var level_timer_dict:= {
	"wait_time": 1.0,
	"autostart": false,
	"one_shot": false,
}
var current_level_time:= 0

var is_game_started:= false
var is_paused := false

var current_combo := 0
#----- UI -----
var current_score:= 0
var current_lives:= 3
var current_level_num:= 1

#---- Bonus Score ----
var max_combo: int
var par_time := 30.0
var penalty_rate := 10.0
var life_bonus := 1000
var combo_bonus := 500

func _ready() -> void:
	wall_hit_sounds = [wall_hit_1, wall_hit_2]
	paddle_hit_sounds = [paddle_hit_1, paddle_hit_2]

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

func report_ball_launched() -> void:
	if not is_game_started:
		is_game_started = true
		game_start.emit()
		start_level_timer()	
	var hit_sound = paddle_hit_sounds.pick_random()
	hit_sound.play()

func on_restart_ball() -> void:
	ball_restart.emit()
	ball_death_sfx.play()

func on_game_paused(pause_request: bool) -> void:
	if pause_request:
		if !is_paused:
			is_paused = true
			game_paused.emit(is_paused)
	else:
		is_paused = false
		game_paused.emit(is_paused)

func on_game_over() -> void:
	current_level_num = 1
	_stop_level_timer()
	game_over.emit()
	is_game_started = false
	

func on_score_anim() -> void:
	var seconds_over_par = max(0, current_level_time - par_time)
	var time_penalty = seconds_over_par * penalty_rate
	var combo_score = max_combo * combo_bonus
	var life_score = current_lives * life_bonus
	bonus_score.emit(current_score, combo_score, life_score, time_penalty)

func on_level_up() -> void:
	current_level_num += 1
	max_combo = 0
	level_up.emit()
	level_update.emit()


func on_score_update(score_amount) -> void:
	current_score += score_amount
	score_update.emit()


func on_lives_update(amount) -> void:
	current_combo = 0
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
	var hit_sound = wall_hit_sounds.pick_random()
	hit_sound.play()
	


func on_ball_brick_collision(brick):
	brick.take_hit()
	current_combo += 1
	if current_combo > max_combo:
		max_combo = current_combo
		combo_alarm.play()
		combo_hit.emit(current_combo)
	brick_break_1.play()
	print(current_combo)
		
		
func report_paddle_hit() -> void:
	current_combo = 0
	var hit_sound = paddle_hit_sounds.pick_random()
	hit_sound.play()
	
	
func play_pop_up() -> void:
	ui_stamp_02.play()

func play_counting() -> void:
	counting.play()
	
func play_deduction() -> void:
	deduction.play()

func report_animations_finished(total_score):
	score_animations_finished.emit()
	current_score = total_score
	score_update.emit()


func _on_level_timer_timeout() -> void:
	current_level_time += 1
	timer_update.emit(current_level_time)

func on_game_quit() -> void:
	quit_game.emit()
