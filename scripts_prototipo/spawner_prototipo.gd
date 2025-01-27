extends Node2D

#carrega o prefab da bala na memória, necessário pra poder instanciar balas
var bullet_scene = preload("res://cenas_prototipo/bala_prototipo.tscn")

#enum dos possíveis estados do spawner
enum movement_type {STILL, SPIN}
enum bullet_spawn_type{SINGLE, BURST}
enum stopping_criteria{TIME, BULLETCAP, NONE}

#variáveis que seguram os estados do spawner
@export_category("Tipo de spawner")
@export_enum("STILL","SPIN") var _move_type: int  = movement_type.STILL
@export_enum("SINGLE","BURST") var _spawn_type: int = bullet_spawn_type.SINGLE
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
@export var arms: int = 8
#ângulo de skew dos braços, verificar os ângulos que tu quer antes de qualquer coisa
@export var skewArms: float

#determina o que faz o spawner parar de atirar balas
@export_category("Critério de parada")
@export var firingTime:float
@export var bulletCap:int

@export_category("Velocidade de tiro")
#auto-explicativo, balas/segundo
@export var firingRate: float


@export_category("Opções de bala")
# variáveis que se relacionam à bala
@export var direction: float
@export var bullet_life: float
@export var bullet_SPEED: float

#variáveis pra conta interna, não mexer
var firedBullets: int
var i = 0
var timer:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(isPathed):
		position = pathToFollow.position
	
	if(_stops_type == stopping_criteria.TIME):
		#manda o comando stop_firing depois de firingTime segundos
		await get_tree().create_timer(firingTime).timeout
		stop_firing()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(isPathed):
		pathToFollow.progress_ratio += followSpeed * delta
		position = pathToFollow.position
	
	#Verifica se o spawner é o tipo que gira ou não, e faz ele girar
	if(_move_type == movement_type.SPIN):
			self.rotation += (rotationSpeed*delta*PI)/180
	timer += delta
	if(timer >= 1/firingRate):
		#se for do tipo single, só lança uma bala
		if(_spawn_type == bullet_spawn_type.SINGLE):
			fire_bullet()
		
		#se for do tipo burst, faz burst com arms braços
		if(_spawn_type == bullet_spawn_type.BURST):
			while(i < arms):
				fire_bullet()
				direction += 360.0/arms + skewArms
				i += 1
				
				#mantém a direção entre 0 e 360, que é bom por que não tem chance nenhuma de memory leak
				if(direction >= 360):
					direction -= 360
		#reseta as variáveis de timer e de contador
		i = 0
		timer = 0

func stop_firing():
	#espera a última bala gerada sumir, e deleta tudo
	await get_tree().create_timer(bullet_life).timeout
	queue_free()

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
