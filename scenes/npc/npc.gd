extends CharacterBody2D

@onready
var _sprite: Sprite2D = $Sprite2D
@onready
var _debug_label: Label = $DebugLabel
@onready
var _nav_agent: NavigationAgent2D = $NavAgent

@export
var _patrol_speed: float = 100.0
@export
var _chase_speed: float = 160.0
@export
var _patrol_points_node: NodePath

var _patrol_points: Array[Waypoint]
var _current_point: int = 0


func _ready() -> void:
	_set_patrol_points()
	_patrol_to(_current_point)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_released("set_target"):
		_nav_agent.target_position = get_global_mouse_position()

	_update_navigation()

	_set_debug_label()


func _update_navigation() -> void:
	if _nav_agent.is_target_reachable():

		if not _nav_agent.is_navigation_finished():
			var next_nav_point: Vector2 = _nav_agent.get_next_path_position()
			_sprite.look_at(next_nav_point)
			velocity = global_position.direction_to(next_nav_point) * _patrol_speed
			move_and_slide()
		else:
			_patrol_to(_get_next_patrol_point())


func _set_patrol_points() -> void:
	var node: Node2D = get_node(_patrol_points_node)
	for w: Waypoint in node.get_children():
		_patrol_points.append(w)


func _get_next_patrol_point() -> int:
	_current_point = 0 if _current_point == _patrol_points.size() - 1 else _current_point + 1
	return _current_point


func _patrol_to(point_index: int) -> void:
	_nav_agent.target_position = _patrol_points[point_index].global_position
	_update_navigation()
	_set_debug_label()


func _set_debug_label() -> void:
	var s: String = "TARGET %s is %s" % [_nav_agent.target_position, "reached" if _nav_agent.is_target_reached() else ("reachable" if _nav_agent.is_target_reachable() else "unreachable")]
	_debug_label.text = s
