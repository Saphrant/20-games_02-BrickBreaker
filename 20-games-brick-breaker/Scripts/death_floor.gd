extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		body.queue_free()
		GameManager.on_lives_update(1)
		GameManager.on_restart_ball()
