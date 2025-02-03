extends Node

var FirstPlayer
var SecondPlayer

var gameDirector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameDirector = get_tree().get_first_node_in_group("Director")
	pass # Replace with function body.

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	var currentID = event.get_device()
	if MultiplayerInput.is_action_just_pressed(-1, "add_player"):
		currentID = -1
	if Input.is_action_just_pressed("add_player"):
		if FirstPlayer == null:
			FirstPlayer = currentID
			gameDirector.Player0.myID = currentID
			return
		elif SecondPlayer == null and currentID != FirstPlayer:
			SecondPlayer = currentID
			gameDirector.Player1.myID = currentID
			
