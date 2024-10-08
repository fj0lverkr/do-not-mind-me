extends CharacterBody2D

@onready
var _sprite: Sprite2D = $Sprite2D
@onready
var _debug_label: Label = $DebugLabel
@onready
var _nav_agent: NavigationAgent2D = $NavAgent

@export
var _speed: float = 100.0


func _ready() -> void:
	var debug_marker: Marker2D = get_tree().get_first_node_in_group("debug")
	if debug_marker:
		_nav_agent.target_position = debug_marker.global_position


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_released("set_target"):
		_nav_agent.target_position = get_global_mouse_position()

	_update_navigation()

	_set_debug_label()


func _update_navigation() -> void:
	if _nav_agent.is_target_reachable() and not _nav_agent.is_navigation_finished():
		var next_nav_point: Vector2 = _nav_agent.get_next_path_position()
		_sprite.look_at(next_nav_point)
		velocity = global_position.direction_to(next_nav_point) * _speed

		move_and_slide()


func _set_debug_label() -> void:
	var s: String = "TARGET %s is %s" % [_nav_agent.target_position, "reached" if _nav_agent.is_target_reached() else ("reachable" if _nav_agent.is_target_reachable() else "unreachable")]
	_debug_label.text = s
