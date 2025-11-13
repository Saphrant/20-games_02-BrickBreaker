@tool
extends Node2D

signal brick_death

var health := 1
var brick_score_value := 50

func _ready() -> void:
	$BrickColor.visible = true
	$CollisionShape2D.disabled = false

func take_hit() -> void:
	$HitParticle.emitting = true
	GameManager.on_score_update(brick_score_value)
	$CollisionShape2D.disabled = true
	$BrickColor.visible = false
	brick_death.emit()
	await $HitParticle.finished
	call_deferred("queue_free")
	
