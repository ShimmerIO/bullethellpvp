extends Node

#sinais que determinam vida de player e se eles foram atingidos
signal hit
signal setHP
signal end_game
signal send_attack 
signal makeInvulnerable
signal send_blank

#player 1 e player 2
@export var Player0:Area2D
@export var Player1:Area2D

var Player0HP:int
@export var Player0MaxHP:int = 7
var Player1HP:int 
@export var Player1MaxHP:int = 7

var player0Graze:int
var player1Graze:int

@onready var gameDirector = get_tree().get_first_node_in_group("GameDirector")
@onready var shopDirector = get_tree().get_first_node_in_group("ShopDirector")

var AttackList = preload("res://scripts_prototipo/attack_list.gd")

var Player0Moveset:Array
var Player1Moveset:Array

var GrazeMeter0
var GrazeMeter1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameDirector.connect("start_shop", _make_invulnerable)
	#conecta ao sinal start_game do game director
	gameDirector.connect("start_game",_on_game_start)
	#encontra os players e conecta os sinais a eles
	Player0 = get_tree().get_nodes_in_group("Player")[0]
	Player1 = get_tree().get_nodes_in_group("Player")[1]
	GrazeMeter0 = get_tree().get_nodes_in_group("GrazeMeter")[0]
	GrazeMeter1 = get_tree().get_nodes_in_group("GrazeMeter")[1]
	Player0.connect("grazed",_on_player_grazed)
	Player0.connect("hit",_on_player_hit)
	Player1.connect("grazed",_on_player_grazed)
	Player1.connect("hit",_on_player_hit)
	Player0.connect("request_attack", _process_attack)
	Player1.connect("request_attack", _process_attack)
	Player0.connect("request_blank", _process_blank)
	Player1.connect("request_blank", _process_blank)
	Player0.connect("request_special", _process_special_skill)
	Player1.connect("request_special", _process_special_skill)
	shopDirector.connect("set_attack", _on_shop_attackset)

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
	synchronize_graze_meter()
	if (isGrazing and return_player_graze(playerSide) < 100):
		match playerSide:
			0: player0Graze += 1
			1: player1Graze += 1
		

#TODO adicionar um check pra ver se o ataque tá em cooldown do jogador
func _process_attack(requestingPlayer:int, attackNumber:int):
	if gameDirector.isStop:
		return
	
	var moveset
	match requestingPlayer:
		0: moveset = Player0Moveset
		1: moveset = Player1Moveset
	
	var attack = moveset[attackNumber]
	var currentAttack = AttackList.get_attack(attack[0],attack[1]).instantiate()
	
	if(return_player_graze(requestingPlayer) >= currentAttack.get("attackCost")):
		send_attack.emit(currentAttack, requestingPlayer)
		match requestingPlayer:
			0: player0Graze -= currentAttack.get("attackCost")
			1: player1Graze -= currentAttack.get("attackCost")
		synchronize_graze_meter()
	else:
		currentAttack.queue_free()
		
func _process_blank(requestingPlayer:int):
	if gameDirector.isStop:
		return
	if(return_player_graze(requestingPlayer) >= 1):
		send_blank.emit(requestingPlayer,1)
		match requestingPlayer:
			0: player0Graze -= 10
			1: player1Graze -= 10
		synchronize_graze_meter()

func _process_special_skill(requestingPlayer:int, skillNumber:int):
	pass

func return_player_graze(player:int):
	match player:
		0: return player0Graze
		1: return player1Graze 

func _on_shop_attackset( playerSide:int, attack: Array) -> void:
	match playerSide:
		0: Player0Moveset.push_front(attack)
		1: Player1Moveset.push_front(attack)
		2: 
			Player0Moveset.push_front(attack)
			Player1Moveset.push_front(attack)

func _make_invulnerable():
	makeInvulnerable.emit()
	
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
				end_game.emit(0)
		1: 
			Player1HP -= 1
			hit.emit(Player1HP,player)
			if Player1HP == 0:
				get_player(1).sleep()
				end_game.emit(1)

func synchronize_graze_meter():
	GrazeMeter0.position.y = 446 - 2.84 * player0Graze
	GrazeMeter1.position.y = 446 - 2.84 * player1Graze
