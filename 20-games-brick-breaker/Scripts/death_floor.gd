extends Area2D

signal lose_life

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		body.queue_free()
		lose_life.emit()
