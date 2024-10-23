class_name LevelMap
extends Node2D

@onready
var _pickups: Node = $Pickups


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.on_pickup_taken.connect(_on_pickup_taken)


func _on_pickup_taken() -> void:
	if _pickups.get_child_count() - 1 > 0:
		return
	
	SignalBus.on_request_exit.emit()