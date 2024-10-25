extends Node

const EXPLOSION: PackedScene = preload("res://scenes/explosion/explosion.tscn")


func create_explosion(pos: Vector2) -> void:
    var e: Explosion = EXPLOSION.instantiate()
    e.global_position = pos
    get_tree().root.add_child(e)