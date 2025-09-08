extends Control

@onready var volume_slider: HSlider = %VolumeSlider
@onready var particles_check_box: CheckBox = %ParticlesCheckBox

func _ready() -> void:
	%BackButton.pressed.connect(func(): get_tree().change_scene_to_file("uid://dwyv653jb45xi"))
	%ResetSaveButton.pressed.connect(_on_reset_save_pressed)
	
	volume_slider.value_changed.connect(_on_volume_changed)
	particles_check_box.toggled.connect(_on_particles_toggled)
	
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	
	particles_check_box.button_pressed = Global.are_particles_enabled


func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))


func _on_particles_toggled(is_on: bool) -> void:
	Global.are_particles_enabled = is_on


func _on_reset_save_pressed() -> void:
	var dir = DirAccess.open("user://")
	if dir.file_exists("savegame.cfg"):
		dir.remove("savegame.cfg")
		print("Save data reset!")
