class_name Gun
extends Node2D

@onready
var _sfx: AudioStreamPlayer2D = $SFX


func shoot(target: Vector2) -> void:
	SoundManager.play_2d(_sfx, SoundManager.SOUND.LASER)
	ObjectFactory.create_bullet(global_position, target)