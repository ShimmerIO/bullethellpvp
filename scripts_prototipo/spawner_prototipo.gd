extends Node2D

#carrega o prefab da bala na memória, necessário pra poder instanciar balas
var bullet_scene = preload("res://cenas_prototipo/bala_prototipo.tscn")

#carrega o game-director, FEITO AUTOMATICAMENTE! NÃO COLOCAR NADA MANUAL, REPITO, NAAAAAADAAAAAA MANUALLLLLL 
#a não ser para teste
@export var GameDirector: Node

#Fala pro spawner qual lado do board ele tá, e qual player ele deveria pedir pro diretor, again, AUTOMÁTICO
#0 é o player da esquerda, 1 é o da direita, faz sentido? foda-se
var PlayerSide: int

#enum dos possíveis estados do spawner
enum movement_type {STILL, SPIN, TRACK}
enum bullet_spawn_type{SINGLE, BURST, SPREAD}
enum stopping_criteria{TIME, BULLETCAP, NONE}

#variáveis que seguram os estados do spawner
@export_category("Tipo de spawner")
@export_enum("STILL","SPIN", "TRACK") var _move_type: int  = movement_type.STILL
@export_enum("SINGLE","BURST", "SPREAD") var _spawn_type: int = bullet_spawn_type.SINGLE
@export_enum("TIME","BULLETCAP", "NONE") var _stops_type: int = stopping_criteria.TIME

@export_category("Caminhos e afins")
# se o spawner segue algum caminho ou não
@export var isPathed: bool = false
#caminho a seguir
@export var pathToFollow: PathFollow2D
#Velocidade que segue o caminho
@export var followSpeed: float


@export_category("opções SPIN")
#velocidade de rotação, em º/s
@export var rotationSpeed: int

@export_category("opções BURST")
#número de braços no spawner
@export var arms: int
#ângulo de skew dos braços, verificar os ângulos que tu quer antes de qualquer coisa
@export var skewArms: float

@export_category("opções SPREAD")
#número de balas
@export var spreadCount: int
@export var spreadAngle:float

#determina o que faz o spawner parar de atirar balas
@export_category("Critério de parada")
@export var timeToExpire:float
@export var bulletCap:int

@export_category("Velocidade de tiro")
#auto-explicativo, balas/segundo
@export var firingRate: float


@export_category("Opções de bala")
# variáveis que se relacionam à bala
var direction: float
@export var bullet_life: float
@export var bullet_SPEED: float

@export_category("Setting iniciais")
#pra poder dar um wakeup'e criar padrões em uma cena só 
@export var isSleeping: bool
@export var sleepingTime:float

#variáveis pra conta interna, não mexer
var firedBullets: int
var i = 0
var timer:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	#acha o game director e coloca ele na variável certa, comenta essa linha fora em caso de teste
	GameDirector = get_tree().get_nodes_in_group("Director")[0] 
	
	#faz os sprites do spawner sumirem
	$Bala.hide()
	$Polygon2D.hide()
	
	#se tiver dormindo, faz ele dormir pelo tempo de dormir, sei lá mano tá bem claro
	if(isSleeping):
		self.hide()
		#guarda a var da fire rate aqui, pra setar o fire rate em 0, isso efetivamente desabilita o spawner
		var storeFireRate = firingRate
		firingRate = 0
		await get_tree().create_timer(sleepingTime).timeout
		self.show()
		#retorna a var pro fire rate
		firingRate = storeFireRate
	
	if(_stops_type == stopping_criteria.TIME):
		#manda o comando stop_firing depois de firingTime segundos
		await get_tree().create_timer(timeToExpire).timeout
		stop_firing()


func _process(delta: float) -> void:
	
	#faz ele seguir o followSpeed% do path por segundo
	if(isPathed):
		pathToFollow.progress_ratio += followSpeed * delta
		position = pathToFollow.position
	
	#Verifica se o spawner é o tipo que gira ou não, e faz ele girar
	if(_move_type == movement_type.SPIN):
			self.rotation += (rotationSpeed*delta*PI)/180
	
	#código para dar track no player se o spawner for desse tipo
	if(_move_type == movement_type.TRACK):
		var currentPlayerPosition = GameDirector.get_player(PlayerSide).global_position
		var vectorToPlayer = currentPlayerPosition - global_position
		direction = Vector2.RIGHT.angle_to(vectorToPlayer) * 180.0 / PI

	#aumenta o timer a cada delta que se passa, usado pra atirar de acordo com o fire rate
	timer += delta 
	if(timer >= 1/firingRate):
		match _spawn_type:
			#se for do tipo single, só lança uma bala
			bullet_spawn_type.SINGLE: 
				fire_bullet()

			#se for do tipo burst, faz burst com arms braços
			bullet_spawn_type.BURST:
				while(i < arms):
					fire_bullet()
					direction += 360.0/arms + skewArms
					i += 1
					#mantém a direção entre 0 e 360, que é bom por que não tem chance nenhuma de memory leak
					if(direction >= 360):
						direction -= 360

			# Se for do tipo spread, faz um arco com abertura igual ao dobro do angulo selecionado
			bullet_spawn_type.SPREAD:
				if(_spawn_type == bullet_spawn_type.SPREAD):
					var addedAngle = 2 * spreadAngle /(spreadCount - 1)
					direction -= spreadAngle
					while(i < spreadCount):
						fire_bullet()
						direction += addedAngle
						i += 1

		#reseta as variáveis de timer e de contador
		i = 0
		timer = 0

func stop_firing():
	#espera a última bala gerada sumir, e deleta tudo
	firingRate = 0
	await get_tree().create_timer(bullet_life).timeout
	queue_free()
	get_parent().check_if_expired()

func fire_bullet():
	#se o tipo for bullet cap, ele calcula isso pra ver quando parar, e para de atirar balas
	if(_stops_type == stopping_criteria.BULLETCAP):
		firedBullets += 1
		if(firedBullets > bulletCap):
			stop_firing()
			return
			
	#gera a bala e coloca todos os critérios dela
	var bullet = bullet_scene.instantiate()
	bullet.direction = direction
	bullet.SPEED = bullet_SPEED
	bullet.bullet_life = bullet_life
	bullet.add_to_group("Bullets")
	add_child(bullet)
