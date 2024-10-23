class_name Exit
extends Area2D


func _ready() -> void:
	monitoring = false
	hide()


func activate() -> void:
	monitoring = true
	show()


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	set_deferred("monitoring", false)
	SignalBus.on_exit.emit()