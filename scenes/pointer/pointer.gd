class_name Pointer
extends Sprite2D

@export
var point_from: Node2D
@export
var point_to: Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not point_from or not point_to:
		queue_free()

	set_process(false)
	hide()
	SignalBus.on_request_exit.connect(_on_request_exit)
	SignalBus.on_exit.connect(_on_exit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_point_at()


func _on_request_exit() -> void:
	_point_at()
	show()
	set_process(true)


func _point_at() -> void:
	global_position = point_from.global_position
	look_at(point_to.global_position)


func _on_exit(_w: bool) -> void:
	hide()
	set_process(false)