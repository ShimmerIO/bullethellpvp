extends AnimatedSprite2D

var playerSide:int
var startPos:Vector2

func _ready() -> void:
	var ownerScene = get_parent().get_parent()
	startPos = ownerScene.global_position 
	var maxPos = Vector2(124,124)
	if ownerScene.scale != Vector2(1,1):
		maxPos = Vector2(59,59)
		global_position = global_position.clamp(startPos -maxPos, startPos + maxPos)
	else:
		global_position = global_position.clamp(startPos -maxPos, startPos + maxPos)
	

func _process(delta: float) -> void:
	self.global_rotation = 0
	
