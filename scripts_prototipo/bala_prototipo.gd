extends Area2D
class_name Bullet

#Propriedades internas da bala
var SPEED: float
var bullet_life: float
var direction: float

#Propriedades visíveis da bala
enum color {RED, BLUE}
enum size {SMALL, BIG}

#tempo que a bala ficou viva
var timeLived:float

func _ready() -> void:
	#chama um timer de tamanho bullet_life e espera ele acabar pra remover a bala
	await get_tree().create_timer(bullet_life).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#0.04 é um número que eu achei que não causa problema, isso faz a bala aumentar o tempo vivido enquanto
	#for menor que 0.04, isso é mais eficiente do que só aumentar sem condição nenhuma
	if timeLived < 0.04:
		timeLived += delta
	
	#move a bala pela velocidade na direção que a bala tem que ir, coisa matemática
	self.position += Vector2(SPEED*delta,0).rotated(direction*PI/180)


func _on_area_entered(area: Area2D) -> void:
	#enquanto tiver vivido menos que 0.04 segundos, não faz NADA
	if timeLived < 0.04:
		return
	#se não for uma bala, ou uma zona de graze, delete yourself, NOW
	if(not area.is_in_group("Bullets") or area.name == "Graze"):
		queue_free()
