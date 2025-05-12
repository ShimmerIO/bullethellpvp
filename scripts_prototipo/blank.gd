extends Area2D

var maxRadius:int = 0
var counter:int = 0
var scalingFactor:float = 0.45
var playerSide:int = 1

func _process(delta: float) -> void:
	
	if maxRadius == 640 and counter > 240:
		self.call_deferred("queue_free")
	if counter < maxRadius*scalingFactor:
		self.scale += Vector2(0.2 / scalingFactor,0.2 / scalingFactor)
		counter += 1
	if counter >= maxRadius*scalingFactor:
		await get_tree().create_timer(0.2)
		self.call_deferred("queue_free")
