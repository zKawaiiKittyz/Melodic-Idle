extends RigidBody2D

func _ready() -> void:
	var life_timer := Timer.new()
	life_timer.wait_time = 45.0
	life_timer.one_shot = true
	life_timer.timeout.connect(queue_free)
	add_child(life_timer)
	life_timer.start()

func set_note_text(text: String) -> void:
	$Label.text = text
