extends Node

#sinais que determinam vida de player e se eles foram atingidos
signal hit
signal setHP

#player 1 e player 2
@export var Player0:Area2D
@export var Player1:Area2D

var Player0HP:int
@export var Player0MaxHP:int = 7
var Player1HP:int 
@export var Player1MaxHP:int = 7

@onready var gameDirector = get_tree().get_first_node_in_group("GameDirector")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#conecta ao sinal start_game do game director
	gameDirector.connect("start_game",_on_game_start)
	#encontra os players e conecta os sinais a eles
	Player0 = get_tree().get_nodes_in_group("Player")[0]
	Player1 = get_tree().get_nodes_in_group("Player")[1]
	Player0.connect("grazed",_on_player_grazed)
	Player0.connect("hit",_on_player_hit)
	Player1.connect("grazed",_on_player_grazed)
	Player1.connect("hit",_on_player_hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#se for 0 retorna o player 1(Player0) se for 1 retorna o player 2(Player1)
func get_player(index):
	if index == 0:
		return Player0
	elif index == 1:
		return Player1

#isso é rodado quando ele recebe o sinal start_game do game director
func _on_game_start():
	Player0HP = Player0MaxHP
	Player1HP = Player1MaxHP
	
	setHP.emit(Player0MaxHP,0)
	setHP.emit(Player1MaxHP,1)

#parece idiota mas é pro servidor saber quando aumentar o graze, atualmente
#só aumenta o graze no player mesmo, mas no futuro vai ter uma variável do
#game-director que faz isso também
func _on_player_grazed(isGrazing:bool, playerSide:int) -> void:
	if (isGrazing):
		get_player(playerSide).grazeMeter += 1
		print("Aumentado! ", playerSide," Graze: ", get_player(playerSide).grazeMeter)

#Quando ele recebe o sinal de hit do player, ele diminui a vida do player
# e manda o valor atual pra ele, pro player a vida dele só tá sendo diminuida
#mas isso é bom pra guardar informação crucial no server side
func _on_player_hit(player:int):
	match player:
		0: 
			Player0HP -= 1
			hit.emit(Player0HP,player)
			if Player0HP == 0:
				get_player(0).sleep()
		1: 
			Player1HP -= 1
			hit.emit(Player1HP,player)
			if Player1HP == 0:
				get_player(1).sleep()
