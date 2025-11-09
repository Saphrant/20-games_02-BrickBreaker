extends CanvasLayer

@onready var main = $".."

@onready var level_complete: Control = $LevelComplete


func _ready() -> void:
	GameManager.score_update.connect(_on_score_update)
	GameManager.level_update.connect(_on_level_update)
	GameManager.lives_update.connect(_on_lives_update)
	GameManager.timer_update.connect(_on_timer_update)
	main.update_highscore.connect(_on_highscore_update)
	main.score_anim.connect(_on_score_animation)
	%ScoreLabel.text = "Score: %s" % GameManager.current_score
	%LevelLabel.text = "Level: %s" % GameManager.current_level_num
	%LivesLabel.text = "Lives: %s" % GameManager.current_lives
	level_complete.visible = false

func _on_highscore_update(new_score) -> void:
	%HighScoreLabel.text = "High Score: %s" % new_score


func _on_score_update() -> void:
	%ScoreLabel.text = "Score: %s" % GameManager.current_score


func _on_level_update() -> void:
	%LevelLabel.text = "Level: %s" % GameManager.current_level_num
	
	
func _on_lives_update() -> void:
	%LivesLabel.text = "Lives: %s" % GameManager.current_lives


func _on_timer_update(new_time) -> void:
	var minutes = new_time / 60
	var seconds = new_time % 60
	%TimerLabel.text = "%02d:%02d" % [minutes, seconds]
	
#----- GAME STATES -----
func _on_play_button_down() -> void:
	GameManager.on_game_start_request(false)


func _on_new_game_button_down() -> void:
	GameManager.on_game_start_request(true)


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1,db_to_linear(value))


func _on_sfx_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2,db_to_linear(value))


func _on_quit_button_down() -> void:
	GameManager._on_game_quit()

func _on_score_animation() -> void:
	level_complete.visible = false
