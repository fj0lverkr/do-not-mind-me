class_name Bullet
extends Area2D

const SPEED: float = 250.0
const FULL_SIZE: Vector2 = Vector2(0.35, 0.35)

@onready
var _sprite: Sprite2D = $Sprite2D

var _direction: Vector2
var _target: Vector2 = Vector2.ZERO


func _ready() -> void:
    look_at(_target)
    _sprite.scale = Vector2(0.001, 0.001)
    _animate_in()


func _process(delta: float) -> void:
    position += SPEED * delta * _direction


func setup(pos: Vector2, target: Vector2) -> void:
    _target = target
    _direction = pos.direction_to(_target)
    global_position = pos


func _animate_in() -> void:
    var t: Tween = create_tween()
    t.tween_property(_sprite, "scale", FULL_SIZE, 0.03)


func _remove_bullet(explosion: bool) -> void:
    if explosion:
        ObjectFactory.create_explosion(global_position)

    queue_free()


func _on_body_entered(body: Node2D) -> void:
    _remove_bullet(not body is Player)