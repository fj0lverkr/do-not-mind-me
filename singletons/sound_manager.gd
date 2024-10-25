extends Node

const GASPS: Array[AudioStream] = [
    preload("res://assets/sounds/gasp1.wav"),
    preload("res://assets/sounds/gasp2.wav"),
    preload("res://assets/sounds/gasp3.wav"),
]

const PICKUPS: Array[AudioStream] = [
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup1.wav"),
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup2.wav"),
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup3.wav"),
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup4.wav"),
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup5.wav"),
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup6.wav"),
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup7.wav"),
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup8.wav"),
    preload("res://assets/sounds/Positive Sounds/sfx_sounds_powerup9.wav"),
]

const EXPLOSION: AudioStream = preload("res://assets/sounds/sfx_exp_medium4.wav")

enum SOUND {GASP, PICKUP, EXPLOSION}


func play_2d(p: AudioStreamPlayer2D, s: SOUND) -> void:
    match s:
        SOUND.GASP:
            p.stream = GASPS.pick_random()
        SOUND.PICKUP:
            p.stream = PICKUPS.pick_random()
        SOUND.EXPLOSION:
            p.stream = EXPLOSION
    
    p.play()