class_name NPC
extends CharacterBody2D

enum NPC_STATE {PATROLLING, CHASING, SEARCHING}

@onready
var _sprite: Sprite2D = $Sprite2D
@onready
var _debug_label: Label = $DebugLabel
@onready
var _nav_agent: NavigationAgent2D = $NavAgent
@onready
var _player_detect: Node2D = $PlayerDetector
@onready
var _raycast: RayCast2D = $PlayerDetector/RayCast2D

@export
var _patrol_speed: float = 100.0
@export
var _chase_speed: float = 160.0
@export
var _patrol_points_node: NodePath

var _patrol_points: Array[Waypoint]
var _current_point: int = 0
var _is_off_patrol: bool = false
var _player_ref: Player
var _fov: float = 60.0
var _current_state: NPC_STATE = NPC_STATE.PATROLLING
var _current_speed: float


func _ready() -> void:
	set_physics_process(false)
	NavigationServer2D.map_changed.connect(_on_nav_map_changed)
	_player_ref = get_tree().get_first_node_in_group(Constants.GRP_PLAYER)
	_current_speed = _patrol_speed


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_released("set_target"):
		_set_off_patrol_target(get_global_mouse_position())

	_set_state()
	_update_navigation()
	_point_raycast_to_player()
	_set_debug_label()


func _set_state() -> void:
	if _can_see_player():
		_current_state = NPC_STATE.CHASING
	else:
		_current_state = NPC_STATE.PATROLLING

	_process_movement()


func _get_angle_to_player() -> float:
	var direction: Vector2 = global_position.direction_to(_player_ref.global_position)
	var dot_product: float = direction.dot(velocity.normalized())
	if dot_product >= -1.0 and dot_product <= 1.0:
		return rad_to_deg(acos(dot_product))
	return 0.0


func _player_in_fov() -> bool:
	return _get_angle_to_player() <= _fov


func _point_raycast_to_player() -> void:
	_player_detect.look_at(_player_ref.global_position)


func _detect_player() -> bool:
	var c: Node = _raycast.get_collider()
	if c != null:
		return c.is_in_group(Constants.GRP_PLAYER)
	else:
		return false


func _can_see_player() -> bool:
	return _detect_player() and _player_in_fov()


func _update_navigation() -> void:
	if _nav_agent.is_target_reachable():
		if not _nav_agent.is_navigation_finished():
			var next_nav_point: Vector2 = _nav_agent.get_next_path_position()
			_sprite.look_at(next_nav_point)
			velocity = global_position.direction_to(next_nav_point) * _current_speed
			move_and_slide()
		else:
			_patrol_to(_get_next_patrol_point())


func _set_patrol_points() -> void:
	var node: Node2D = get_node(_patrol_points_node)
	for w: Waypoint in node.get_children():
		_patrol_points.append(w)


func _get_next_patrol_point() -> int:
	_is_off_patrol = false
	_current_point = 0 if _current_point == _patrol_points.size() - 1 else _current_point + 1
	return _current_point


func _get_previous_patrol_point() -> int:
	if _is_off_patrol:
		return _current_point
	else:
		_is_off_patrol = true
		return _patrol_points.size() - 1 if _current_point == 0 else _current_point - 1


func _patrol_to(point_index: int) -> void:
	_nav_agent.target_position = _patrol_points[point_index].global_position
	_update_navigation()
	_set_debug_label()


func _process_patrolling() -> void:
	_current_speed = _patrol_speed
	_update_navigation()


func _navigate_to_player() -> void:
	_current_speed = _chase_speed
	_set_off_patrol_target(_player_ref.global_position)


func _set_off_patrol_target(target: Vector2) -> void:
	var prev_target: Vector2 = _nav_agent.target_position
	_current_point = _get_previous_patrol_point()
	_nav_agent.target_position = target
	if !_nav_agent.is_target_reachable():
		_nav_agent.target_position = prev_target


func _process_movement() -> void:
	match _current_state:
		NPC_STATE.PATROLLING:
			_process_patrolling()
		NPC_STATE.CHASING:
			_navigate_to_player()


func _set_debug_label() -> void:
	var s: String = "TARGET %s is %s" % [_nav_agent.target_position, "reached" if _nav_agent.is_target_reached() else ("reachable" if _nav_agent.is_target_reachable() else "unreachable")]
	s += "\nSpeed: %s" % _current_speed
	s += "\nPlayer detected is %s" % _detect_player()
	s += "\nPlayer at %.2f° is in FOV: %s" % [_get_angle_to_player(), _player_in_fov()]

	_debug_label.text = s


func _on_nav_map_changed(_map: RID) -> void:
	if !is_physics_processing():
		set_physics_process(true)
		_set_patrol_points()
		_patrol_to(_current_point)