extends CanvasLayer

@onready var main = $".."

@onready var level_complete: Control = $LevelComplete
@onready var menu_control: Control = $MenuControl
@onready var bonus_pop_up: Label = $LevelComplete/BonusPopUp
@onready var animation_timer: Timer = $AnimationTimer
@onready var score_bonus_score: Label = $LevelComplete/MarginContainer/VBoxContainer/HBoxContainer/ScoreBonusScore
@onready var score_label: Label = %ScoreLabel
@onready var level_label: Label = %LevelLabel
@onready var lives_label: Label = %LivesLabel
@onready var mute_check: CheckBox = $MenuControl/VBoxContainer/HBoxContainer3/MuteCheck
@onready var power_up_label: Label = $PowerUpLabel
@onready var pause_control: Control = $PauseControl
@onready var game_over_label: Label = $GameOverLabel

var ui_current_score:= 0
var current_bonus: int
var tween_finished:= true
var pop_up_amount = 45.0
var original_pop_up_pos: Vector2

func _ready() -> void:
	GameManager.score_update.connect(_on_score_update)
	GameManager.level_update.connect(_on_level_update)
	GameManager.lives_update.connect(_on_lives_update)
	GameManager.timer_update.connect(_on_timer_update)
	GameManager.game_start_request.connect(_on_game_request)
	GameManager.game_paused.connect(_on_game_pause)
	GameManager.bonus_score.connect(_bonus_animations)
	GameManager.game_over.connect(_on_game_over)
	main.update_highscore.connect(_on_highscore_update)
	score_label.text = "Score: %s" % GameManager.current_score
	level_label.text = "Level: %s" % GameManager.current_level_num
	lives_label.text = "Lives: %s" % GameManager.current_lives
	level_complete.visible = false
	menu_control.visible = true
	bonus_pop_up.visible = false
	power_up_label.visible = false
	pause_control.visible = false
	game_over_label.visible = false
	original_pop_up_pos = bonus_pop_up.position

func _on_game_request(_is_new_game) -> void:
	menu_control.visible = false
	game_over_label.visible = false

func _on_highscore_update(new_score) -> void:
	%HighScoreLabel.text = "High Score: %s" % new_score


func _on_score_update() -> void:
	score_label.text = "Score: %s" % GameManager.current_score


func _on_level_update() -> void:
	level_label.text = "Level: %s" % GameManager.current_level_num
	
	
func _on_lives_update() -> void:
	lives_label.text = "Lives: %s" % GameManager.current_lives


func _on_timer_update(new_time) -> void:
	var minutes = new_time / 60
	var seconds = new_time % 60
	%TimerLabel.text = "%02d:%02d" % [minutes, seconds]
	
#----- GAME STATES -----
func _on_play_button_down() -> void:
	GameManager.on_game_start_request(false)


func _on_new_game_button_down() -> void:
	GameManager.on_game_start_request(true)


func _on_quit_button_down() -> void:
	GameManager.on_game_quit()

func _on_game_pause(is_paused: bool) -> void:
	if is_paused:
		power_up_label.visible = true
		pause_control.visible = true
	else:
		power_up_label.visible = false
		pause_control.visible = false
		
func _bonus_animations(current_score, combo_score, life_score, time_penalty) -> void:
	level_complete.visible = true
	var total_bonus = 0
	_update_bonus_score_label(total_bonus)
	
	# "Current Score" pop-up
	await _play_popup_animation("Current Score: %s" % current_score)
	await _animate_score_counter(total_bonus, total_bonus + current_score)
	total_bonus += current_score
	# "Combo Score" pop-up
	await _play_popup_animation("Combo Score: %s" % combo_score)
	await _animate_score_counter(total_bonus, total_bonus + combo_score)
	total_bonus += combo_score
	# "Lives Score" pop-up
	await _play_popup_animation("Lives Score: %s" % life_score)
	await _animate_score_counter(total_bonus, total_bonus + life_score)
	total_bonus += life_score
	# "Time Penalty" pop-up
	await _play_popup_animation("Time Penalty: %s" % time_penalty)
	await _animate_score_counter(total_bonus, total_bonus - time_penalty)
	total_bonus -= time_penalty
	GameManager.report_animations_finished(total_bonus)
	level_complete.visible = false
	
	

func _play_popup_animation(text_to_show: String) -> void:
	bonus_pop_up.text = text_to_show
	bonus_pop_up.position = original_pop_up_pos
	bonus_pop_up.modulate = Color(1.0, 1.0, 1.0, 1.0) # Make it visible
	bonus_pop_up.visible = true

	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_property(bonus_pop_up, "position", Vector2(0, original_pop_up_pos.y - pop_up_amount), 0.2)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(bonus_pop_up, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1).set_delay(1)
	GameManager.play_pop_up()

	await tween.finished

func _update_bonus_score_label(value: int):
	score_bonus_score.text = str(int(value))
	
func _animate_score_counter(start_value: int, end_value: int) -> void:
	if end_value != 0 and end_value > start_value:
		GameManager.play_counting()
		print("up")
	elif end_value < start_value:
		GameManager.play_deduction()
		print("down")
	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	tween.tween_method(_update_bonus_score_label, start_value, end_value, 0.5)
	
	await tween.finished

func _on_mute_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_mute(0,true)
	else:
		AudioServer.set_bus_mute(0,false)

func _on_resume_button_button_down() -> void:
	GameManager.on_game_paused(false)
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_game_over() -> void:
	game_over_label.visible = true
	menu_control.visible = true
	lives_label.text = "Lives: 0"
	level_label.text = "Level: %s" % GameManager.current_level_num
	
