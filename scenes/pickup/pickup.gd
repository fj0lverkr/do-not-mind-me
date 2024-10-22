class_name PickUp
extends Area2D

const DURATION: float = 0.6

@onready
var _sprite: Sprite2D = $Sprite2D
@onready
var _collider: CollisionShape2D = $CollisionShape2D
@onready
var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

var _tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animate_pulsing()


func _animate_pulsing() -> void:
	if _tween:
		_tween.kill()

	_tween = create_tween().set_loops()
	_tween.tween_property(_sprite, "modulate", Color.YELLOW, DURATION)
	_tween.parallel().tween_property(_sprite, "scale", Vector2(0.85, 0.85), DURATION)
	_tween.parallel().tween_property(_collider, "scale", Vector2(0.85, 0.85), DURATION)
	
	_tween.tween_property(_sprite, "modulate", Color.WHITE, DURATION)
	_tween.parallel().tween_property(_sprite, "scale", Vector2(0.7, 0.7), DURATION)
	_tween.parallel().tween_property(_collider, "scale", Vector2(0.7, 0.7), DURATION)


func _animate_vanish() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.parallel().tween_property(_sprite, "scale", Vector2(0.01, 0.01), DURATION / 2)
	_tween.parallel().tween_property(_collider, "scale", Vector2(0.0, 0.0), 0.01)


func _play_sound() -> void:
	SoundManager.play_2d(_sfx, SoundManager.SOUND.PICKUP)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	SignalBus.on_pickup_taken.emit()
	_animate_vanish()
	_play_sound()


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
	pass
