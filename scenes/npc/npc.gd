class_name NPC
extends CharacterBody2D

enum NPC_STATE {PATROLLING, CHASING, SEARCHING}

const EMO_EXCLAM: Texture2D = preload("res://assets/images/emotes/8665321_exclamation_icon.png")
const EMO_QUEST: Texture2D = preload("res://assets/images/emotes/8665727_question_icon.png")

const FOV: Dictionary = {
	NPC_STATE.PATROLLING: 60,
	NPC_STATE.SEARCHING: 100,
	NPC_STATE.CHASING: 120
}

const SPEED: Dictionary = {
	NPC_STATE.PATROLLING: 60,
	NPC_STATE.SEARCHING: 80,
	NPC_STATE.CHASING: 100
}

const MIN_DISTANCE: float = 150.0

@onready
var _sprite_and_gun: Node2D = $SpriteAndGun
@onready
var _debug_label: Label = $DebugLabel
@onready
var _nav_agent: NavigationAgent2D = $NavAgent
@onready
var _player_detect: Node2D = $PlayerDetector
@onready
var _raycast: RayCast2D = $PlayerDetector/RayCast2D
@onready
var _emote: Sprite2D = $Emote
@onready
var _sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready
var _gun: Gun = $SpriteAndGun/Gun

@export
var _patrol_points_node: NodePath
@export
var _show_debug: bool = false

var _patrol_points: Array[Waypoint]
var _current_point: int = 0
var _is_off_patrol: bool = false
var _player_ref: Player
var _current_state: NPC_STATE = NPC_STATE.PATROLLING
var _tween: Tween
var _can_shoot: bool = true


func _ready() -> void:
	_emote.hide()
	if _show_debug:
		_debug_label.show()
	set_physics_process(false)
	NavigationServer2D.map_changed.connect(_on_nav_map_changed)
	_player_ref = get_tree().get_first_node_in_group(Constants.GRP_PLAYER)


func _physics_process(_delta: float) -> void:
	_point_raycast_to_player()
	_update_state()
	_update_navigation()

	_set_debug_label()


func disable_shooting() -> void:
	_can_shoot = false


func _animate_state(s: NPC_STATE) -> void:
	if _tween:
		_reset_tween()

	if s == NPC_STATE.PATROLLING:
		return

	_tween = create_tween()

	match s:
		NPC_STATE.CHASING:
			_tween.set_loops()
			_tween.tween_property(_sprite_and_gun, "modulate", Color.RED, 0.2).set_trans(Tween.TRANS_SINE)
			_tween.tween_property(_sprite_and_gun, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_SINE)

		NPC_STATE.SEARCHING:
			_tween.set_loops()
			_tween.tween_property(_sprite_and_gun, "modulate", Color.YELLOW, 0.3).set_trans(Tween.TRANS_SINE)
			_tween.tween_property(_sprite_and_gun, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_SINE)


func _reset_tween() -> void:
	_tween.kill()
	var t: Tween = create_tween()
	t.tween_property(_sprite_and_gun, "modulate", Color.WHITE, 0.01)


func _set_state(s: NPC_STATE) -> void:
	if _current_state != s:
		match s:
			NPC_STATE.PATROLLING:
				_emote.hide()
			NPC_STATE.SEARCHING:
				_emote.texture = EMO_QUEST
				_emote.show()
			NPC_STATE.CHASING:
				_emote.texture = EMO_EXCLAM
				_emote.show()
				SoundManager.play_2d(_sfx, SoundManager.SOUND.GASP)
	
		_animate_state(s)

	_current_state = s


func _update_state() -> void:
	if _can_see_player():
			_set_state(NPC_STATE.CHASING)
	elif !_can_see_player() && _current_state == NPC_STATE.CHASING:
		_set_state(NPC_STATE.SEARCHING)

	_process_movement()


func _get_distance_to_player() -> float:
	return global_position.distance_to(_player_ref.global_position)


func _get_angle_to_player() -> float:
	var direction: Vector2 = global_position.direction_to(_player_ref.global_position)
	var dot_product: float = direction.dot(velocity.normalized())
	if dot_product >= -1.0 and dot_product <= 1.0:
		return rad_to_deg(acos(dot_product))
	return 0.0


func _player_in_fov() -> bool:
	return _get_angle_to_player() <= FOV[_current_state]


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
			_sprite_and_gun.look_at(next_nav_point)
			velocity = global_position.direction_to(next_nav_point) * SPEED[_current_state]

			if _current_state != NPC_STATE.CHASING or _get_distance_to_player() >= MIN_DISTANCE:
				move_and_slide()
				
		else:
			if _current_state == NPC_STATE.PATROLLING:
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
	_set_debug_label()


func _process_searching() -> void:
	if _nav_agent.is_navigation_finished():
		_set_state(NPC_STATE.PATROLLING)


func _navigate_to_player() -> void:
	_set_off_patrol_target(_player_ref.global_position)


func _set_off_patrol_target(target: Vector2) -> void:
	var prev_target: Vector2 = _nav_agent.target_position
	_current_point = _get_previous_patrol_point()
	_nav_agent.target_position = target
	if !_nav_agent.is_target_reachable():
		_nav_agent.target_position = prev_target


func _process_movement() -> void:
	match _current_state:
		NPC_STATE.SEARCHING:
			_process_searching()
		NPC_STATE.CHASING:
			_navigate_to_player()


func _set_debug_label() -> void:
	var s: String = "TARGET %s is %s" % [_nav_agent.target_position, "reached" if _nav_agent.is_target_reached() else ("reachable" if _nav_agent.is_target_reachable() else "unreachable")]
	s += "\nSpeed: %s" % SPEED[_current_state]
	s += "\nPlayer detected is %s" % _detect_player()
	s += "\nPlayer at %.2f distance is in FOV: %s (%s)" % [_get_distance_to_player(), _player_in_fov(), FOV[_current_state]]
	s += "\nState: %s" % NPC_STATE.find_key(_current_state)

	_debug_label.text = s


func _shoot() -> void:
	_gun.shoot(_player_ref.global_position)


func _on_nav_map_changed(_map: RID) -> void:
	if !is_physics_processing():
		set_physics_process(true)
		_set_patrol_points()
		_patrol_to(_current_point)


func _on_shoot_timer_timeout() -> void:
	if _current_state != NPC_STATE.CHASING or !_can_shoot:
		return

	_shoot()
