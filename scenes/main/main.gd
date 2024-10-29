extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_btn_exit_pressed() -> void:
	get_tree().quit()

func _on_btn_start_pressed() -> void:
	SceneManager.load_scene(SceneManager.SCENES.LEVEL)
