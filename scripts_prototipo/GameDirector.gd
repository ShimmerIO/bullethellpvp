extends Node

#chama a lista de patterns, usado pra saber o que atirar
var PatternList = preload("res://scripts_prototipo/pattern_list.gd")

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

# Wave máxima, signifca que a gente tem que preparar pelo menos 50 waves a mão, parece bom
const MAXWAVE = 50

#Índices usado pra saber o que fazer
var waveIndex: int = 1
var patternIndex: int

#bloqueia iniciar o jogo infinitas vezes, importante certeza
var hasStarted: bool = false

func _ready() -> void:
	#TODO fazer isso daqui ser automático no game_start, não no ready do director
	#lê a primeira wave na variável, só pra error-catching eu acho
	currentWave = WaveList.get_wave(1,dificuldade.FÁCIL)


func _process(_delta: float) -> void:
	#inicia o jogo, NOTE isso é pra teste
	if Input.is_action_just_pressed("Start") and not hasStarted:
		send_wave()
		hasStarted = true

#se for 0 retorna o player 1(Player0) se for 1 retorna o player 2(Player1)
func get_player(index):
	if index == 0:
		return Player0
	elif index == 1:
		return Player1

#Função usada pra fazer os padrões em si
func make_pattern(index):
	#chama get_pattern, com o índice atual, currentPattern é uma array no qual a primeira entrada é as info
	#do pattern, na forma de array também, e a segunda entrada é o tempo que o pattern fica ativo
	var currentPattern = get_pattern(index)
	
	#coloca a instância dopadrão ativo em Active Pattern
	var ActivePattern = PatternList.get_pattern(currentPattern[0][0],currentPattern[0][1]).instantiate()
	add_child(ActivePattern)
	
	#espera o timeout do pattern, segundo a segunda entrada do currentPattern
	await get_tree().create_timer(currentPattern[1]).timeout
	
	#encontra o próximo pattern
	next_pattern(index)

func get_pattern(index):
	#send_pattern() retorna uma array de array de array. Cada array no retornado pelo send_pattern é um pattern
	return currentWave.send_pattern()[index]

#chama o próximo pattern, literalmente o nome
func next_pattern(index):
	#verifica se chegou no fim da wave, se sim, ele para de ler o resto e vai pra próxima wave
	if index >= currentWave.send_pattern().size()-1:
		next_wave()
		return
	
	#se ainda não chegou no fim da wave, continua lendo né porra trabaia ai make_pattern()
	#aumenta o indice e vai pro próximo
	patternIndex += 1
	make_pattern(patternIndex)

func next_wave():

	# TODO só lê as duas linhas a baixo tu vai entender oqq precisa fazer ainda
	#if condição_que_verifica_se_deveria_aumentar_dificuldade:
	# 	print("nossa aumenta ai")
	
	#se for a wave máxima começa os pattern random, que nem balão 
	if waveIndex == MAXWAVE:
		dunno_do_random_shit_i_guess()
		return
	
	# aumenta a wave, e busca a próxima, e envia a próxima
	waveIndex += 1
	currentWave = WaveList.get_wave(waveIndex,currentDifficulty)
	send_wave()

func send_wave():
	#coloca o índice dos patterns em 0, e começa de novo
	patternIndex = 0
	make_pattern(patternIndex)

#não sei faz bosta aleatória eu acho
func dunno_do_random_shit_i_guess():
	pass
