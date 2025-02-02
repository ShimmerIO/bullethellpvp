extends Node

var FirstPlayer
var SecondPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Start"):
		if get_parent().name  == "main":
			get_tree().change_scene_to_file("res://cenas_prototipo/cena_teste.tscn")
			queue_free()
