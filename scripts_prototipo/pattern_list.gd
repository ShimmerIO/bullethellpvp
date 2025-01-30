extends Node


static func get_pattern(index: int, difficulty: int):
	var dificuldade: String
	match difficulty:
		0: dificuldade = "FÁCIL"
		1: dificuldade = "MÉDIO"
		2: dificuldade = "MÓDIFÍCIL"
		
	return load(str("res://cenas_prototipo/Padrões_Completos/",dificuldade,"/Padrão",index,".tscn"))
