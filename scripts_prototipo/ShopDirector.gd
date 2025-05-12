extends Node

signal end_shop
signal set_attack
signal blank_screen

var timeToChoose: float
var survivalTime: float

@onready var gameDirector = get_tree().get_first_node_in_group("GameDirector")
@onready var playerDirector = get_tree().get_first_node_in_group("PlayerDirector")

var shopScene = preload("res://cenas_prototipo/SHOP.tscn")

#chama a lista de ataques, pra saber o que colocar no shop
var AttackList = preload("res://scripts_prototipo/attack_list.gd")

#número de cada ataque
@export var centralCount:int 
@export var diagonalCount:int
@export var spiralCount:int
@export var horizontalCount: int
@export var pathedCount:int
@export var rotationalCount: int
@export var trackingCount: int
@export var verticalCount: int

var attackSelection:Array
var activeShop 
var activeShop2
 
var player0 
var player1

var player0chosenAttack
var player1chosenAttack

@onready var label0 = $Tempo1
@onready var label1 = $Tempo2

const SCREEN_CENTER: Vector2 = Vector2(154.5,160)
const RIGHT_BORDER = 27
const LEFT_BORDER = 13

func _ready() -> void:

	gameDirector.connect("start_shop", _generate_shop)

	

func roll_attack(currentSelection:Array)-> Array:
	
	var chosenAttackType:int = randi_range(0,7)
	var chosenAttackIndex:int
	
	var attackCount:int
	match chosenAttackIndex:
		0: attackCount = centralCount
		1: attackCount = diagonalCount
		2: attackCount = spiralCount
		3: attackCount = horizontalCount
		4: attackCount = pathedCount
		5: attackCount = rotationalCount
		6: attackCount = trackingCount
		7: attackCount = verticalCount
	
	chosenAttackIndex = 1
	chosenAttackIndex = randi_range(1, attackCount)
	var chosenAttack = [chosenAttackType, chosenAttackIndex]

	while currentSelection.has(chosenAttack):
		chosenAttack = roll_attack(currentSelection)
	
	return chosenAttack

func clear_shop():
	attackSelection = []
	end_shop.emit()

func _generate_shop():
	player0 = playerDirector.get_player(0)
	player1 = playerDirector.get_player(1)
	
	activeShop = shopScene.instantiate()
	activeShop2 = shopScene.instantiate()
	activeShop.global_position = Vector2(153,160)
	activeShop2.global_position = Vector2(487,160)
	for i in range(4):
		var rolledAttack = roll_attack(attackSelection)
		attackSelection.append(rolledAttack)
		var attack = AttackList.get_attack(rolledAttack[0],rolledAttack[1])
		activeShop.get_child(i).add_child(attack.instantiate()) 
		activeShop2.get_child(i).add_child(attack.instantiate()) 
	add_child(activeShop)
	add_child(activeShop2)
	attack_choice()
	
func attack_choice():
	var choiceTimer = $TempoEscolha
	var survivalTimer = $TempoSurvive
	
	var sharedAttack2 = roll_attack(attackSelection)
	attackSelection.append(sharedAttack2)
	var sharedAttack3 = roll_attack(attackSelection)
	
	set_attack.emit(2, sharedAttack3)
	set_attack.emit(2, sharedAttack2)
	
	choiceTimer.wait_time = 5
	choiceTimer.start()
	await choiceTimer.timeout

	
	player0chosenAttack = attackSelection[return_chosen_attack(player0.global_position,0)]
	player1chosenAttack = attackSelection[return_chosen_attack(player1.global_position,1)]
	

	set_attack.emit(0, player0chosenAttack)
	set_attack.emit(1, player1chosenAttack)

	
	await get_tree().create_timer(get_process_delta_time()).timeout
	activeShop.queue_free()
	activeShop2.queue_free()
	
	var attack0 = AttackList.get_attack(player0chosenAttack[0],player0chosenAttack[1]).instantiate()
	var attack1 = AttackList.get_attack(player1chosenAttack[0],player0chosenAttack[1]).instantiate()
	
	attack0.timeToExpire = 15
	attack1.timeToExpire = 15
	attack0.global_position = SCREEN_CENTER
	attack1.global_position = SCREEN_CENTER + Vector2(RIGHT_BORDER - LEFT_BORDER + 320,0)
	add_child(attack0)
	add_child(attack1)
	
	survivalTimer.wait_time = 15
	survivalTimer.start()
	
	await survivalTimer.timeout
	get_tree().call_group("Spawners", "stop_firing")
	await get_tree().create_timer(0,5).timeout
	blank_screen.emit(0,0)
	blank_screen.emit(1,0)
	await gameDirector.no_bullets
	await get_tree().create_timer(get_process_delta_time()).timeout
	if attack0:
		attack0.queue_free()
	if attack1:
		attack1.queue_free()
	
	clear_shop()



func return_chosen_attack(playerPosition: Vector2, playerSide:int)-> int:
	var adjustedPosition = playerPosition - SCREEN_CENTER + Vector2((RIGHT_BORDER - LEFT_BORDER + 320)*playerSide,0)
	
	if adjustedPosition.x >= 0:
		if adjustedPosition.y >= 0:
			return 3
		else:
			return 1
	else:
		if adjustedPosition.y >= 0:
			return 2
		else:
			return 0
