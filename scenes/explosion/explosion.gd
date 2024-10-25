class_name Explosion
extends AnimatedSprite2D

@onready
var _sfx: AudioStreamPlayer2D = $Sfx


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.play_2d(_sfx, SoundManager.SOUND.EXPLOSION)


func _on_sfx_finished() -> void:
	queue_free()
