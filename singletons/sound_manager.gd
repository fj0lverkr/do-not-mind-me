extends Node

const GASPS: Array[AudioStream] = [
    preload("res://assets/sounds/gasp1.wav"),
    preload("res://assets/sounds/gasp2.wav"),
    preload("res://assets/sounds/gasp3.wav"),
]

enum SOUND {GASP}


func play_2d(p: AudioStreamPlayer2D, s: SOUND) -> void:
    match s:
        SOUND.GASP:
            p.stream = GASPS.pick_random()
    
    p.play()