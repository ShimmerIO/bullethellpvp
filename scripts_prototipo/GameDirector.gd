extends Node

signal start_game

#chama a lista de patterns, usado pra saber o que atirar
var PatternList = preload("res://scripts_prototipo/pattern_list.gd")

#chama a lista de ataques, pra saber o que atacar
var AttackList = preload("res://scripts_prototipo/attack_list.gd")

#chama a lista de waves, usado pra saber quais patterns fazer
var WaveList = preload("res://scripts_prototipo/wave_list.gd")

#Chama o playerDirector pra saber informação dos players
@onready var playerDirector = get_tree().get_first_node_in_group("PlayerDirector")

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

#controla se está no endless, se sim, manda os padrões endless
@export var isEndless: bool = false

#peso de cada dificuldade, WARNING, tem que somar a 100! Se não somar a 100 tem um bagulho bem massa que acontece
@export var easyWeight:float
@export var mediumWeight: float
@export var hardWeight: float

#determina quantos patterns vai ter por wave aleatória, isso é setado a mão
#NOTE valores ideais a serem determinados via game-test
@export var minPatternCount: int
@export var maxPatternCount: int

#tempo entre waves, vai ser um aleatório entre esses dois
#NOTE valores ideais a serem determinados via game-test
@export var minTime:float
@export var maxTime:float

#número de cada tipo de pattern
@export var easyCount:int
@export var mediumCount: int
@export var hardCount: int

#variável pra guardar a wave aleatóriamente gerada
var currentRandomWave:Array

#dá halt no game-director inteiro se for verdadeiro
var stop:bool

func _ready() -> void:
	#lê a primeira wave na variável CurrentWave
	currentWave = WaveList.get_wave(1,dificuldade.FÁCIL)

func _process(_delta: float) -> void:
	#inicia o jogo, NOTE isso é pra teste
	if Input.is_action_just_pressed("Start") and not hasStarted:
		next_wave()
		start_game.emit()
		hasStarted = true

#Função usada pra fazer os padrões naturais em si
func make_natural_pattern(index):
	#chama get_pattern, com o índice atual, currentPattern é uma array no qual a primeira entrada é as info
	#do pattern, na forma de array também, e a segunda entrada é o tempo que o pattern fica ativo
	var currentPattern = get_natural_pattern(index)
	
	#coloca a instância dopadrão ativo em Active Pattern
	var ActivePattern = PatternList.get_pattern(currentPattern[0][0],currentPattern[0][1])
	
	#gera um pattern pra cada player
	var player0Pattern = ActivePattern.instantiate()
	var player1Pattern = ActivePattern.instantiate()

	#move o pattern do player1 por 960, pra ir pro lado dele da tela
	player1Pattern.position.x += 960
	
	#isso insere eles na cena
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
	#se for endless, a gente quer que mande as waves aleatórias
	else:
		return currentRandomWave[index]

#chama o próximo pattern, literalmente o nome
func next_pattern(index):
	#se mandou o stop, ele para 
	if stop:
		return
	
	#verifica se chegou no fim da wave, se sim, ele para de ler o resto e vai pra próxima wave
	#NOTE não dá pra dar merge com a função de baixo por que as waves endless não são lidas na
	#variável currentWave, currentWave é .gd, currentRandomWave é Array
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
	
	#wave atual é lida a partir da wave, e da dificudade
	currentWave = WaveList.get_wave(waveIndex,currentDifficulty)
	
	send_wave()

func send_wave():
	#aumenta o waveCount
	waveCount += 1
	#coloca o índice dos patterns em 0, e começa de novo
	patternIndex = 0
	make_natural_pattern(patternIndex)

#Função que gera a wave aleatória, retorna uma array contendo patterns, cada um desses patterns é por si
# uma array, com [[pattern_index, pattern_difficulty],time]

func generate_random_wave() -> Array:
	var arrayToSend:Array
	#gera um inteiro aleatório entre esses dois números
	var amountOfPatterns = randi_range(minPatternCount, maxPatternCount)
	
	#gera amountOfPatterns de padrões aleatórios
	for n in range(0, amountOfPatterns):
		arrayToSend.append(generate_random_pattern())
	
	#retorna a array
	return arrayToSend

func generate_random_pattern() -> Array:

	#roda um float entre 0 e 100, pra determinar a dificuldade
	var randomDifficulty = randf_range(0,100)
	#variáveis que vão ser mandadas, a dificuldade e o indice são vistas depois
	#mas o tempo pode ser feito agora sem problema algum
	var chosenDifficulty:int
	var chosenIndex: int
	var chosenTime: float = randf_range(minTime,maxTime)
	
	# ele vê se a dificuldade rodada for menor que a fácil, pra determinar o
	#pattern como um pattern fácil, caso contrário, ele vai pro próximo
	if randomDifficulty < easyWeight:
		chosenDifficulty = 0
		chosenIndex = randi_range(1, easyCount)
	#Idem ao anterior, mas aqui ele verifica se é menor que o medium e o easy
	elif randomDifficulty < easyWeight + mediumWeight:
		chosenDifficulty = 1
		chosenIndex = randi_range(1, mediumCount)
	#Idem ao anterior, mas aqui é pra ser menor que 100 idealmente
	#tipo, se falhou os outros dois, é automaticamente difícil
	elif randomDifficulty < easyWeight + mediumWeight + hardWeight:
		chosenDifficulty = 2
		chosenIndex = randi_range(1, hardCount)
	#se falhou os 3, manda o buraco negro e o spawner vira do tipo isFuckYou
	else:
		print("opa amigo, o float caiu fora do range, por favor faz os pesos somarem a 100, amigo")
		chosenDifficulty = 2
		chosenIndex = 420
		stop = true
	
	#retorna o pattern
	return [[chosenIndex,chosenDifficulty],chosenTime]

func make_attack(attackIndex:int, attackFolder:int, sendingPlayer:int):
	
	#carrega o pattern de ataque na variável, baseado no ataque que ele recebeu
	#suponho que o player em si vai chamar essa função a partir dele mesmo
	#NOTE adicionar aqui o custo de GRAZE, pra fazer isso ser server-side
	var attackingPattern = AttackList.get_attack(attackIndex,attackFolder)
	var attackedPlayer:int = 1 - sendingPlayer
	
	var attackInstance = attackingPattern.instantiate()
	attackInstance.global_position.x += 960 * attackedPlayer
	add_child(attackInstance)
