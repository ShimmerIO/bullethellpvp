extends Control

#variável que controla o player HP, guardada pela health-bar
#no futuro, com networking, não é uma boa ideia deixar o player controlar isso client-side
var currentHP
var maxHP
@export var playerSide = 0


#carrega os sprites
var fullShield = load("res://sprites_prototipo/full_shield.png")
var emptyShield = load("res://sprites_prototipo/empty_shield.png")

#acha o nodo que tem os escudos
@onready var LocateHP = $HPcontainer
@onready var PlayerDirector = get_tree().get_first_node_in_group("PlayerDirector")

func _ready() -> void:
	#conecta esses sinais aos que o PlayerDirector emite
	PlayerDirector.connect("setHP",_on_director_set_hp)
	PlayerDirector.connect("hit",_on_hit_received)
	#se esconde quando abre???? lol, acho que isso implica que 
	#generate_shields() só roda quando dá start_game()
	self.hide()

#função que gera os shields, o maxHP +1 é por que range(n,m) cria uma lista de n até m-1
func generate_shields():
	for n in range(2, maxHP+1):
		#duplica o shield que já existe
		var clone = get_shield(1).duplicate()
		#bota o nome dele baseado no item do range
		clone.name = str("Shield",n)
		#adiciona ao container, que alinha automático
		LocateHP.add_child(clone)
	#só mostra os shields quando der generate_shields
	self.show()
	#redesenha os shields??????
	redraw()
	

func redraw():
	#error-catching eu suponho
	if currentHP > maxHP:
		currentHP = maxHP
	if currentHP < 0:
		return
	
	#troca a textura dos shields pra shield cheio, até o currentHP
	for i in range(1, currentHP+1):
		get_shield(i).texture = fullShield
		if playerSide == 1:
			get_shield(i).set_flip_h(true)
	
	#troca os shields acima do teu current HP, até o maxHP com shield vazio
	for i in range(currentHP+1, maxHP+1):
		get_shield(i).texture = emptyShield

func _on_hit_received(myHP:int, player:int):
	# se o sinal emitido for pra esse nodo, a vida é setada igual ao do gameDirector
	#supostamente melhor por que o gameDirector é supostamente server-side
	if player == playerSide:
		currentHP = myHP
		redraw()

#acha o nodo do shield, bem simples, tem um error catching mas foda-se
func get_shield(index:int):
	if index < 1 or index > maxHP:
		return
	return get_node(str("HPcontainer/Shield",index))

#no game_start o gameDIrector manda a HP da nave, se o sinal for pra essa health-bar, ele arruma certinho
func _on_director_set_hp(maxReceivedHP:int,player:int) -> void:
	if player == playerSide:
		maxHP = maxReceivedHP
		currentHP = maxHP
		generate_shields()
