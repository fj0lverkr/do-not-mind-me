class_name GameUi
extends Control

const PICKUPLABEL: String = "Picked up %s of %s items"

@onready
var _label_pickups: Label = $MC/LabelPickups
@onready
var _label_exit: Label = $MC/LabelExit
@onready
var _label_timer: Label = $MC/LabelTimer
@onready
var _game_over_rect: ColorRect = $GameOverRect
@onready
var _game_over_label: Label = $GameOverRect/VBoxContainer/Label
@onready
var _game_over_timer: Timer = $TimerGameOver
@onready
var _menu_label: Label = $GameOverRect/VBoxContainer/LabelMenu

var _pickups: int
var _taken: int = 0
var _click_enabled: bool = false


func _ready() -> void:
    SignalBus.on_level_start.connect(_on_level_start)
    SignalBus.on_pickup_taken.connect(_on_pickup_taken)
    SignalBus.on_request_exit.connect(_on_request_exit)
    SignalBus.on_exit.connect(_on_exit)


func _process(_delta: float) -> void:
    _label_timer.text = _format_time(Time.get_ticks_msec())
    if _click_enabled and Input.is_action_just_pressed("lmb"):
        SceneManager.load_scene(SceneManager.SCENES.MAIN)


func _update_pickup_label() -> void:
    _label_pickups.text = PICKUPLABEL % [_taken, _pickups]


func _format_time(ms: int) -> String:
    var total_seconds: float = ms / 1000.0
    var seconds: float = fmod(total_seconds, 60.0)
    var minutes: int = int(total_seconds / 60.0) % 60
    var hours: int = int(total_seconds / 3600.0)
    var hhmmss_string: String = "%02d:%02d:%05.2f" % [hours, minutes, seconds]
    return hhmmss_string


func _on_level_start(num_pickups: int) -> void:
    _pickups = num_pickups
    _update_pickup_label()


func _on_pickup_taken() -> void:
    _taken += 1
    _update_pickup_label()


func _on_request_exit() -> void:
    _label_exit.show()


func _on_exit(win: bool) -> void:
    _label_pickups.hide()
    _label_exit.hide()
    _label_timer.hide()
    var end_time: int = Time.get_ticks_msec()
    var go: String = "You win!" if win else "You died!"
    go += "\nTime taken: %s" % _format_time(end_time)
    _game_over_label.text = go
    _game_over_rect.show()
    _game_over_timer.start()


func _on_timer_game_over_timeout() -> void:
    _menu_label.show()
    _click_enabled = true
