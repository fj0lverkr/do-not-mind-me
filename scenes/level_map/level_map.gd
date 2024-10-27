class_name LevelMap
extends Node2D

@onready
var _pickups: Node = $Pickups
@onready
var _exit: Exit = $Exit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.on_level_start.emit(_pickups.get_child_count())
	SignalBus.on_pickup_taken.connect(_on_pickup_taken)
	SignalBus.on_request_exit.connect(_on_request_exit)
	SignalBus.on_exit.connect(_on_exit)


func _on_pickup_taken() -> void:
	if _pickups.get_child_count() - 1 > 0:
		return
	
	SignalBus.on_request_exit.emit()


func _on_request_exit() -> void:
	_exit.activate()


func _on_exit(_w: bool) -> void:
	get_tree().paused = true