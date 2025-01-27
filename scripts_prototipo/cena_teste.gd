extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Start"):
		var ataque = load("res://cenas_prototipo/Cenas_Base/Padrão1.tscn")
		var cena = ataque.instantiate()
		$'.'.get_parent().add_child(cena)
		queue_free()
