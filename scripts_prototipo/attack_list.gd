static func get_attack(index: int, folder: int):
	var pasta: String
	match folder:
		0: pasta = "Central"
		1: pasta = "Diagonal"
		2: pasta = "Espiral"
		3: pasta = "Horizontal"
		4: pasta = "Pathed"
		5: pasta = "Rotacional"
		6: pasta = "Tracking"
		7: pasta = "Vertical"
		
	return load(str("res://cenas_prototipo/Ataques/",pasta,"/Ataque",index,".tscn"))
