extends Area2D
signal hit

const SPEED = 600.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	if direction:
		position += direction * SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	handle_hit()
	hit.emit()
	
func handle_hit():
	print("ai meu pancreas")
	pass
	
