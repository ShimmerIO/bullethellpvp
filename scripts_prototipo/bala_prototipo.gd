extends Area2D
class_name Bullet

@export var SPEED: float
@export var bullet_life: float
@export var direction: float

#TODO colocar que a bala não afeta areas nos primeiros frames dela spawnar, isso arruma muitos conflitos que eu tô tendo
enum color {RED, BLUE}
enum size {SMALL, BIG}

var timeLived:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(bullet_life).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timeLived < 0.04:
		timeLived += delta
	self.position += Vector2(SPEED*delta,0).rotated(direction*PI/180)


func _on_area_entered(area: Area2D) -> void:
	if timeLived < 0.04:
		return
	if(not area.is_in_group("Bullets") or area.name == "Graze"):
		queue_free()
