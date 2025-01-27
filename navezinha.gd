extends Area2D
signal hit


const SPEED = 600.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	if direction:
		position += direction * SPEED * delta

	
func handle_hit():
	print("ai meu pancreas")
	pass
	
func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Bullets")):
		handle_hit()
		hit.emit()
	else:
		print("ah yes, zona")
