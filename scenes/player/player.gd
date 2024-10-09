class_name Player
extends CharacterBody2D

@export
var _speed: float = 130.0


func _ready() -> void:
    pass


func _physics_process(_delta: float) -> void:
    _process_input()
    move_and_slide()


func _process_input() -> void:
    var new_velocity: Vector2 = Vector2.ZERO
    new_velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
    new_velocity.y = Input.get_action_strength("down") - Input.get_action_strength("up")
    velocity = new_velocity.normalized() * _speed