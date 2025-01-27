extends Area2D
class_name Bullet

@export var SPEED: float
@export var bullet_life: float
@export var direction: float
enum TYPE {pequena_vermelha, pequena_azul, grande_roxa}
var spawn_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_position = position
	await get_tree().create_timer(bullet_life).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position += Vector2(SPEED*delta,0).rotated(direction*PI/180)
	

func _on_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Player")):
		queue_free()
