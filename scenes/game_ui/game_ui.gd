class_name GameUi
extends Control

@onready
var _label_pickups: Label = $MC/LabelPickups
@onready
var _label_exit: Label = $MC/LabelExit
@onready
var _label_timer: Label = $MC/LabelTimer
@onready
var _game_over_rect: ColorRect = $GameOverRect
@onready
var _game_over_label: Label = $GameOverRect/Label


func _ready() -> void:
    SignalBus.on_exit.connect(_on_exit)


func _on_exit(win: bool) -> void:
    _game_over_label.text = "You win!" if win else "You died!"
    _game_over_rect.show()