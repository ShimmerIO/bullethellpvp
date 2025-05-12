extends Area2D

#determina a existência do sinal hit, usado pra conectar até o game-master eventualmente
signal hit

#determina a existência do sinal de graze
signal grazed


signal request_attack
signal request_blank
signal request_special

@onready var playerDirector = get_tree().get_first_node_in_group("PlayerDirector")
#velocidade do player
@export_category("Opções nave")
#235 é 425 * 5/9, 425 é o valor que o nando achou comfy em 1152x648 
@export var SPEED = 235.0
@export var acc:float
@export var acc_max:float
var isSlow: bool

var velocity = 0

#pega o tamanho da tela
var screen_size:Vector2

@export var playerSide:int

var isGrazing:bool
var timer: float
var timeToIncreaseGraze:float = 1

var myID
var currentID

var isInvulnerable:bool
@export var invulnerabilityTimer:float = 1

var isSleep:bool

var attack1:Array
var attack2:Array
var attack3:Array
var special_skill:int


const LEFT_BORDER = 13
const RIGHT_BORDER = 27
const UP_BORDER = 20
const DOWN_BORDER = 60

func _ready() -> void:
	
	playerDirector.connect("makeInvulnerable",make_invulnerable)
	if global_position.x > get_viewport_rect().size.x/2:
		playerSide = 1
	#pega o tamanho da tela, e faz magia nela, again, placeholder e hack por enquanto
	screen_size = get_viewport_rect().size
	screen_size -= Vector2(screen_size.x/2,0)

func _process(delta: float) -> void:
	if isSleep:
		return
	
	if isInvulnerable:
		timer+= delta
		$NaveTeste.self_modulate = Color(1,1,1,0.5)
		$CollisionShape2D.set_deferred("disabled",true)
		if timer > invulnerabilityTimer:
			$CollisionShape2D.set_deferred("disabled",false)
			isInvulnerable = false
			timer = 0
			$NaveTeste.self_modulate = Color(1,1,1,1)
	
	if isGrazing:
		$Graze/GrazeShape.show()
	elif not has_overlapping_areas():
		$Graze/GrazeShape.hide()
	
	var direction 
	#isso dá handle no input, não pedir input fora disso
	if myID != null:
			direction = MultiplayerInput.get_vector(myID,"custom_left", "custom_right","custom_up","custom_down")
			if MultiplayerInput.is_action_pressed(myID,"custom_slow"):
				isSlow = true
			else:
				isSlow = false
				
			if MultiplayerInput.is_action_just_pressed(myID, "custom_attack_1"):
				request_attack.emit(playerSide, 0)
			
			if MultiplayerInput.is_action_just_pressed(myID, "custom_attack_2"):
				request_attack.emit(playerSide, 1)
			
			if MultiplayerInput.is_action_just_pressed(myID, "custom_attack_3"):
				request_attack.emit(playerSide, 2)
			
			if MultiplayerInput.is_action_just_pressed(myID,"custom_attack_4") and isSlow:
				request_blank.emit(playerSide)
			
			elif MultiplayerInput.is_action_just_pressed(myID, "custom_attack_4"):
				request_special.emit(playerSide, special_skill)
		
	#move o personagem quando tu tá apertando alguma direção
	if direction:
		velocity = SPEED
		#movimentação precisa com o botão de slow segurado, atualmente shift
		if(isSlow):
			velocity = velocity * 2 / 3
		#lembra de física? isso aqui é literal S = vt, pq velocidade é direção * rapidez, e delta é tempo
		position += velocity * delta * direction
		
		#mantém o personagem na tela, CRITICAL PLACEHOLDER! ISSO ESTÁ AQUI ENQUANTO NÃO TEMOS OS SPRITES FINAIS!
		position = position.clamp(Vector2.ZERO + Vector2(23 + (1 + RIGHT_BORDER - LEFT_BORDER + screen_size.x)*playerSide, 20 + 10) , screen_size - (Vector2(RIGHT_BORDER + 9 - (1+ RIGHT_BORDER -LEFT_BORDER + screen_size.x) * playerSide,71)))

		
	if not direction: 
		velocity = 0
		
func sleep():
	isSleep = true
	self.hide()
	self.set_deferred("monitorable", false)
	self.set_deferred("monitoring", false)
	$Graze.set_deferred("monitoring",false)

func _on_area_entered(area: Area2D) -> void:
	#se colidir com uma bala, é pra emitir o sinal hit
	if(area.is_in_group("Bullets") and not isInvulnerable):
		hit.emit(playerSide)
	#isso aqui vai virar um elif eventualmente pra implementar outras zonas
	elif area.name == "zona":
		print("ah yes, zona")

#função interna que faz o efeito on_hit, usa isso aqui pra deixar invulnerável, MAS NÃO PRA VIDA, ISSO É O GAME MASTER QUEM FAZ
func _on_hit(player) -> void:
	isInvulnerable = true

func make_invulnerable():
	isInvulnerable = true
	invulnerabilityTimer = 5
	await get_tree().create_timer(5).timeout
	invulnerabilityTimer = 1

func _on_graze_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Bullets") and not isInvulnerable ):
		isGrazing = true
		grazed.emit(isGrazing, playerSide)

func _on_graze_area_exited(area: Area2D) -> void:
	if(area.is_in_group("Bullets")):
		isGrazing = false
		grazed.emit(isGrazing, playerSide)
