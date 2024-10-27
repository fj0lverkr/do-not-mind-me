class_name Player
extends CharacterBody2D

@export
var _speed: float = 130.0


func _physics_process(_delta: float) -> void:
    _process_input()
    move_and_slide()


func _process_input() -> void:
    velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
    velocity.y = Input.get_action_strength("down") - Input.get_action_strength("up")
    velocity = velocity.normalized()
    velocity *= _speed
    if Input.is_action_pressed("up") or Input.is_action_pressed("down") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
        rotation = velocity.angle()