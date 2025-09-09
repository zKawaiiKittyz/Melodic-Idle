class_name PauseMenu
extends CanvasLayer


signal quit_requested

@onready var pause_buttons: VBoxContainer = %PauseButtons
@onready var settings_view: VBoxContainer = %SettingsView
@onready var volume_slider: HSlider = %VolumeSlider
@onready var particles_check_box: CheckBox = %ParticlesCheckBox


func _ready() -> void:
	settings_view.hide()
	_load_settings_into_ui()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel", false, true):
		if settings_view.visible:
			_on_settings_button_pressed()
			get_viewport().is_input_handled()
		else:
			_on_resume_button_pressed()
			get_viewport().is_input_handled()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_settings_button_pressed() -> void:
	pause_buttons.hide()
	settings_view.show()


func _on_back_button_pressed() -> void:
	settings_view.hide()
	pause_buttons.show()


func _load_settings_into_ui() -> void:
	var bus_idx: int = AudioServer.get_bus_index("SFX")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	particles_check_box.button_pressed = Settings.are_particles_enabled


func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	Settings.save_settings()


func _on_particles_toggled(is_on: bool) -> void:
	Settings.are_particles_enabled = is_on
	Settings.save_settings()


func _on_reset_save_button_pressed() -> void:
	var dir := DirAccess.open("user://")
	if dir.file_exists("savegame.cfg"):
		dir.remove("savegame.cfg")
		print("Save data reset!")


func _on_quit_button_pressed() -> void:
	quit_requested.emit()
