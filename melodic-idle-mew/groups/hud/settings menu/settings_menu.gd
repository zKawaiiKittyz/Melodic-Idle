extends Control


@onready var volume_slider: HSlider = %VolumeSlider
@onready var particles_check_box: CheckBox = %ParticlesCheckBox


func _ready() -> void:
	var bus_idx: int = AudioServer.get_bus_index("SFX")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	particles_check_box.button_pressed = Settings.are_particles_enabled


func _on_volume_changed(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	Settings.save_settings()


func _on_particles_toggled(is_on: bool) -> void:
	Settings.are_particles_enabled = is_on
	Settings.save_settings()


func _on_reset_save_pressed() -> void:
	var dir := DirAccess.open("user://")
	if dir.file_exists("savegame.cfg"):
		dir.remove("savegame.cfg")
		print("Save data reset!")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MainMenu.UID)
