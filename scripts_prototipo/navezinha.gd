extends Area2D

#determina a existência do sinal hit, usado pra conectar até o game-master eventualmente
signal hit

#determina a existência do sinal de graze
signal grazed

#velocidade do player
@export_category("Opções nave")
#700 é 425 * 5/3, 425 é o valor que o nando achou comfy em 1152x648 
@export var SPEED = 700.0
@export var acc:float
@export var acc_max:float
var isSlow: bool

var velocity = 0

#pega o tamanho da tela
var screen_size:Vector2

@export var playerSide:int

var isGrazing:bool
var grazeMeter:int
var timer: float
var timeToIncreaseGraze:float = 1

var myID
var currentID

func _ready() -> void:
	if global_position.x > 960:
		playerSide = 1
	#pega o tamanho da tela, e faz magia nela, again, placeholder e hack por enquanto
	screen_size = get_viewport_rect().size
	screen_size -= Vector2(screen_size.x/2,0)

func _process(delta: float) -> void:
	if isGrazing:
		$Graze/GrazeShape.show()
	elif not has_overlapping_areas():
		$Graze/GrazeShape.hide()
	
	var direction 
	if myID != null:
			direction = MultiplayerInput.get_vector(myID,"custom_left", "custom_right","custom_up","custom_down")
			if MultiplayerInput.is_action_pressed(myID,"custom_slow"):
				isSlow = true
			else:
				isSlow = false
		
	#move o personagem quando tu tá apertando alguma direção
	if direction:
		velocity = SPEED
		#movimentação precisa com o botão de slow segurado, atualmente shift
		if(isSlow):
			velocity = velocity * 2 / 3
		#lembra de física? isso aqui é literal S = vt, pq velocidade é direção * rapidez, e delta é tempo
		position += velocity * delta * direction
		
		#mantém o personagem na tela, CRITICAL PLACEHOLDER! ISSO ESTÁ AQUI ENQUANTO NÃO TEMOS OS SPRITES FINAIS!
		position = position.clamp(Vector2.ZERO + Vector2(19 + 960*playerSide, 24) , screen_size - (Vector2(19 - 960 * playerSide,13)))

		
	if not direction: 
		velocity = 0

func _on_area_entered(area: Area2D) -> void:
	#se colidir com uma bala, é pra emitir o sinal hit
	if(area.is_in_group("Bullets")):
		hit.emit()
	#isso aqui vai virar um elif eventualmente pra implementar outras zonas
	else:
		print("ah yes, zona")

#função interna que faz o efeito on_hit, usa isso aqui pra deixar invulnerável, MAS NÃO PRA VIDA, ISSO É O GAME MASTER QUEM FAZ
func _on_hit() -> void:
	print("ai meu pancreas")

func _on_graze_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Bullets")):
		isGrazing = true
		grazed.emit(isGrazing, playerSide)

func _on_graze_area_exited(area: Area2D) -> void:
	if(area.is_in_group("Bullets")):
		isGrazing = false
		grazed.emit(isGrazing, playerSide)
