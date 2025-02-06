extends Node

#guarda as variáveis dos players, usado pra ordem de player
var FirstPlayer
var SecondPlayer

#chama o player director pra setar propriedades sobre os players
var playerDirector

func _ready() -> void:
	#chama o game director achando ele no grupo
	playerDirector = get_tree().get_first_node_in_group("PlayerDirector")

func _input(event: InputEvent) -> void:
	#ID atual do controle
	var currentID 
	
	#Se tiver controle conectado, o ID é setado a partir disso, causa crash caso contrário!
	#basicamente get_connected_joypads() retorna nulo se não tiver nada, e isso conta como "false"
	if Input.get_connected_joypads():
		currentID = event.get_device()
	
	#se o teclado, que sempre tem index -1, apertou "add_player", o ID é -1
	if MultiplayerInput.is_action_just_pressed(-1, "add_player"):
		currentID = -1
	
	#previne crash
	if currentID == null:
		return
	
	#Se não tiver primeiro player, seta o player que apertou o botão de entrar como player
	# Se não tiver segundo player, e o ID não for o do primerio, seta o segundo
	#NOTE isso aqui é pra teste e será mudado com o sistmea de seleção de personagem
	if MultiplayerInput.is_action_just_pressed(currentID, "add_player"):
		if FirstPlayer == null:
			FirstPlayer = currentID
			playerDirector.Player0.myID = currentID
			return
		elif SecondPlayer == null and currentID != FirstPlayer:
			SecondPlayer = currentID
			playerDirector.Player1.myID = currentID
