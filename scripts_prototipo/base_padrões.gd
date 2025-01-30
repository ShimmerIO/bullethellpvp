extends Node2D

class_name Padrão

@export_enum("FÁCIL","MÉDIO","DIFÍCIL") var dificuldade: int 
@export var índice_padrão:int

func _get(property):
	if property == "index":
		return índice_padrão
	if property == "difficulty":
		return dificuldade

func _get_property_list():
	var properties = []
	properties.append({
		"name":name,
		"type":TYPE_INT,
		"index":índice_padrão,
		"difficulty":dificuldade
	})
	return properties

func check_if_expired():
	await get_tree().create_timer(get_process_delta_time()).timeout
	if(get_child_count() == 0):
		queue_free()
