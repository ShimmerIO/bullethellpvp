extends Label

@onready var choiceTimer = $"../TempoEscolha"
@onready var survivalTimer = $"../TempoSurvive"

func _process(delta: float) -> void:
	if not choiceTimer.is_stopped():
		self.text = str(snapped(choiceTimer.time_left,1))
		self.show()
	elif not survivalTimer.is_stopped():
		self.text = str(snapped(survivalTimer.time_left,1))
		self.show()
	else:
		self.hide()
