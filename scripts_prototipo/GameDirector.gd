extends Node

#chama a lista de patterns, usado pra saber o que atirar
var PatternList = preload("res://scripts_prototipo/pattern_list.gd")

#chama a lista de ataques, pra saber o que atacar
var AttackList = preload("res://scripts_prototipo/attack_list.gd")

#chama a lista de waves, usado pra saber quais patterns fazer
var WaveList = preload("res://scripts_prototipo/wave_list.gd")

#player 1 e player 2
@export var Player0:Area2D
@export var Player1:Area2D

#enum de dificuldade, não sei o que tu quer
enum dificuldade {FÁCIL, MÉDIO, DIFÍCIL}

#variável pra contar qual a wave e qual a dificuldade dela
var currentWave:GDScript
var currentDifficulty: int

#Índices usado pra saber o que fazer
var waveIndex: int = 0
var patternIndex: int

# número de waves já mandados, diferente de waveIndex porque ele é resetado, esse daqui não
var waveCount = 0
#bloqueia iniciar o jogo infinitas vezes, importante certeza
var hasStarted: bool = false

@export_category("Endless Settings")
# Wave máxima, signifca que a gente tem que preparar pelo menos 50 waves a mão, parece bom
@export var maxWave = 50

@export var isEndless: bool = false

@export var easyWeight:float
@export var mediumWeight: float
@export var hardWeight: float

@export var minPatternCount: int
@export var maxPatternCount: int

@export var minTime:float
@export var maxTime:float

@export var easyCount:int
@export var mediumCount: int
@export var hardCount: int

var currentRandomWave:Array
var stop:bool

func _ready() -> void:
	#TODO fazer isso daqui ser automático no game_start, não no ready do director
	#lê a primeira wave na variável, só pra error-catching eu acho
	currentWave = WaveList.get_wave(1,dificuldade.FÁCIL)

func _process(_delta: float) -> void:
	#inicia o jogo, NOTE isso é pra teste
	if Input.is_action_just_pressed("Start") and not hasStarted:
		next_wave()
		hasStarted = true

#se for 0 retorna o player 1(Player0) se for 1 retorna o player 2(Player1)
func get_player(index):
	if index == 0:
		return Player0
	elif index == 1:
		return Player1

#Função usada pra fazer os padrões naturais em si
func make_natural_pattern(index):
	#chama get_pattern, com o índice atual, currentPattern é uma array no qual a primeira entrada é as info
	#do pattern, na forma de array também, e a segunda entrada é o tempo que o pattern fica ativo
	var currentPattern = get_natural_pattern(index)
	
	#coloca a instância dopadrão ativo em Active Pattern
	var ActivePattern = PatternList.get_pattern(currentPattern[0][0],currentPattern[0][1])
	
	var player0Pattern = ActivePattern.instantiate()
	var player1Pattern = ActivePattern.instantiate()

	player1Pattern.position.x += 960
	
	add_child(player0Pattern)
	add_child(player1Pattern)
	
	#espera o timeout do pattern, segundo a segunda entrada do currentPattern
	await get_tree().create_timer(currentPattern[1]).timeout
	
	#encontra o próximo pattern
	next_pattern(index)

func get_natural_pattern(index):
	#send_pattern() retorna uma array de array de array. Cada array no retornado pelo send_pattern é um pattern
	if(not isEndless):
		return currentWave.send_pattern()[index]
	else:
		return currentRandomWave[index]

#chama o próximo pattern, literalmente o nome
func next_pattern(index):
	#verifica se chegou no fim da wave, se sim, ele para de ler o resto e vai pra próxima wave
	if stop:
		return
	
	if index >= currentWave.send_pattern().size()-1 and not isEndless:
		next_wave()
		return
	
	if index >= currentRandomWave.size()-1 and isEndless:
		next_wave()
		return
	
	#se ainda não chegou no fim da wave, continua lendo né porra trabaia ai make_pattern()
	#aumenta o indice e vai pro próximo
	patternIndex += 1
	make_natural_pattern(patternIndex)

func next_wave():
	
	#se for a wave máxima começa os pattern random, que nem balão 
	if isEndless or waveCount >= maxWave:
		isEndless = true
		currentRandomWave = generate_random_wave()
		send_wave()
		return
	
	# aumenta a wave
	waveIndex += 1

	#se a wave não existe, aumenta a dificuldade e reseta o índice de volta pra 1
	if WaveList.get_wave(waveIndex,currentDifficulty) == null:
		currentDifficulty += 1
		waveIndex = 1

	currentWave = WaveList.get_wave(waveIndex,currentDifficulty)
	
	send_wave()

func send_wave():
	#aumenta o waveCount
	waveCount += 1
	#coloca o índice dos patterns em 0, e começa de novo
	patternIndex = 0
	make_natural_pattern(patternIndex)

func generate_random_wave() -> Array:
	var arrayToSend:Array
	
	var amountOfPatterns = randi_range(minPatternCount, maxPatternCount)
	
	for n in range(0, amountOfPatterns):
		arrayToSend.append(generate_random_pattern())
	
	return arrayToSend

func generate_random_pattern() -> Array:

	var randomDifficulty = randf_range(0,100)
	var chosenDifficulty:int
	var chosenIndex: int
	var chosenTime: float = randf_range(minTime,maxTime)
	
	if randomDifficulty < easyWeight:
		chosenDifficulty = 0
		chosenIndex = randi_range(1, easyCount)
	elif randomDifficulty < easyWeight + mediumWeight:
		chosenDifficulty = 1
		chosenIndex = randi_range(1, mediumCount)
	elif randomDifficulty < easyWeight + mediumWeight + hardWeight:
		chosenDifficulty = 2
		chosenIndex = randi_range(1, hardCount)
	else:
		print("opa amigo, o float caiu fora do range, por favor faz os pesos somarem a 100, amigo")
		chosenDifficulty = 2
		chosenIndex = 420
		stop = true
	
	return [[chosenIndex,chosenDifficulty],chosenTime]

func make_attack(attackIndex:int, attackFolder:int, sendingPlayer:int):
	
	var attackingPattern = AttackList.get_attack(attackIndex,attackFolder)
	var attackedPlayer:int
	
	match sendingPlayer:
		0: attackedPlayer = 1
		1: attackedPlayer = 0
	
	var attackInstance = attackingPattern.instantiate()
	attackInstance.global_position.x += 960 * attackedPlayer
	add_child(attackInstance)

func _on_player_grazed(isGrazing:bool, playerSide:int) -> void:
	if (isGrazing):
		get_player(playerSide).grazeMeter += 1
		print("Aumentado!", playerSide, get_player(playerSide).grazeMeter)
