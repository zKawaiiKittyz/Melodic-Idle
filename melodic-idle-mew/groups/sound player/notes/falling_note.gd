class_name FallingNote
extends RigidBody2D


func _ready() -> void:
	get_tree().create_timer(45.0).timeout.connect(queue_free)


func set_note_text(text: String) -> void:
	$Label.text = text
