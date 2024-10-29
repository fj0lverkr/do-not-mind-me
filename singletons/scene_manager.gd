extends Node

enum SCENES {MAIN, LEVEL, }

const PACKEDSCENES: Dictionary = {
    SCENES.MAIN: preload("res://scenes/main/main.tscn"),
    SCENES.LEVEL: preload("res://scenes/level_map/level_map.tscn"),
}

func load_scene(scene: SCENES) -> void:
    get_tree().change_scene_to_packed(PACKEDSCENES[scene])