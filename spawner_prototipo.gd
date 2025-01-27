extends Node2D

#carrega o prefab da bala na memória, necessário pra poder instanciar balas
var bullet_scene = preload("res://bala_prototipo.tscn")

#enum dos possíveis estados do spawner
enum movement_type {STILL, SPIN}
enum bullet_spawn_type{SINGLE, BURST}

#variáveis que seguram os estados do spawner
@export var _move_type: int  = movement_type.STILL
@export var _spawn_type: int = bullet_spawn_type.BURST

# se o spawner segue algum caminho ou não
var isPathed: bool

#velocidade de rotação, em º/s
@export var rotationSpeed: int

#número de braços no spawner
@export var arms: int = 8

@export var skewArms: float

#auto-explicativo, balas/segundo
@export var firingRate: float

# variáveis que se relacionam à bala
@export var direction: float
@export var bullet_life: float
@export var bullet_SPEED: float

#variáveis pra conta interna, não mexer
var i = 0
var timer:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
				if(direction >= 360):
					direction -= 360
		
		#reseta as variáveis de timer e de contador
		i = 0
		timer = 0
	

func fire_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.direction = direction
	bullet.SPEED = bullet_SPEED
	bullet.bullet_life = bullet_life
	bullet.add_to_group("Bullets")
	add_child(bullet)
