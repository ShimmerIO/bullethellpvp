extends Node2D

var bullet_scene = preload("res://bala_prototipo.tscn")

enum spawner_type {STRAIGHT, SPIN}
@export var firingRate: float
var timer:float

@export var direction: float
@export var bullet_life: float
@export var bullet_SPEED: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	if(timer >= 1/firingRate):
		fire_bullet()
		timer = 0
	

func fire_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.direction = direction
	bullet.SPEED = bullet_SPEED
	bullet.bullet_life = bullet_life
	bullet.position = position
	add_child(bullet)
	pass
