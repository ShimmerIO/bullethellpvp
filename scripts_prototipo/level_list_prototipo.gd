extends Node


static func get_level(index: int, difficulty: int):
	
	var dificuldade: String
	
	if difficulty == 0:
		dificuldade = "FÁCIL"
	elif difficulty == 1:
		dificuldade = "MÉDIO"
	elif difficulty == 2:
		dificuldade = "DIFÍCIL"
		
	return load(str("res://cenas_prototipo/Padrões/", dificuldade,"Padrão", index, ".tscn"))
