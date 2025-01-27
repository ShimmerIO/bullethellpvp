extends Area2D

#determina a existência do sinal hit, usado pra conectar até o game-master eventualmente
signal hit

#velocidade do player
@export_category("Opções nave")
@export var SPEED = 450.0
@export var acc:float

var velocity = 0

#pega o tamanho da tela
var screen_size:Vector2

func _ready() -> void:
	screen_size = get_viewport_rect().size
	screen_size -= Vector2(screen_size.x/2,0)

func _process(delta: float) -> void:
	#gera um vetor normalizado baseado no input, muito bom
	var direction := Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	
	#move o personagem quando tu tá apertando alguma direção
	if direction:
		velocity += acc * delta
		velocity = clamp(velocity, 0, 200)
		#lembra de física? isso aqui é literal S = vt, pq velocidade é direção * rapidez, e delta é tempo
		position +=  (SPEED + velocity) * delta * direction
		position = position.clamp(Vector2.ZERO + Vector2(19, 24) , screen_size - (Vector2(19,13)))
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
