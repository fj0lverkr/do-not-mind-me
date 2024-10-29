extends Node

const EXPLOSION: PackedScene = preload("res://scenes/explosion/explosion.tscn")
const BULLET: PackedScene = preload("res://scenes/bullet/bullet.tscn")


func create_explosion(pos: Vector2) -> void:
    var e: Explosion = EXPLOSION.instantiate()
    e.global_position = pos
    get_tree().root.add_child(e)


func create_bullet(pos: Vector2, target: Vector2) -> void:
    var b: Bullet = BULLET.instantiate()
    b.setup(pos, target)
    b.add_to_group(Constants.GRP_BULLET)
    get_tree().root.add_child(b)
