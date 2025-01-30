extends Node


static func get_wave(index: int, difficulty: int):
	var dificuldade:String
	match difficulty:
		0: dificuldade = "FÁCIL"
		1: dificuldade = "MÉDIO"
		2: dificuldade = "MÓDIFÍCIL"
		
	return load(str("res://cenas_prototipo/Wave/",dificuldade,"/Wave",index,".gd"))
