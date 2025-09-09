extends CanvasLayer

@onready var pause_buttons = %PauseButtons
@onready var settings_view = %SettingsView
@onready var volume_slider: HSlider = %VolumeSlider
@onready var particles_check_box: CheckBox = %ParticlesCheckBox

func _ready() -> void:
	%ResumeButton.pressed.connect(on_resume_pressed)
	%SettingsButton.pressed.connect(on_settings_pressed)
	%QuitButton.pressed.connect(func(): get_tree().paused = false; get_tree().change_scene_to_file("uid://dwyv653jb45xi"))
	
	settings_view.get_node("%BackButton").pressed.connect(on_settings_back_pressed)
	%ResetSaveButton.pressed.connect(_on_reset_save_pressed)
	volume_slider.value_changed.connect(_on_volume_changed)
	particles_check_box.toggled.connect(_on_particles_toggled)
	
	settings_view.hide()
	
	_load_settings_into_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if settings_view.visible:
			on_settings_back_pressed()
		else:
			on_resume_pressed()


func on_resume_pressed() -> void:
	get_tree().paused = false
	hide()


func on_settings_pressed() -> void:
	pause_buttons.hide()
	settings_view.show()


func on_settings_back_pressed() -> void:
	settings_view.hide()
	pause_buttons.show()


func _load_settings_into_ui() -> void:
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	particles_check_box.button_pressed = Global.are_particles_enabled


func _on_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
	Global.save_settings()


func _on_particles_toggled(is_on: bool) -> void:
	Global.are_particles_enabled = is_on
	Global.save_settings()


func _on_reset_save_pressed() -> void:
	var dir = DirAccess.open("user://")
	if dir.file_exists("savegame.cfg"):
		dir.remove("savegame.cfg")
		print("Save data reset!")
