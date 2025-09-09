extends Node


const SETTINGS_PATH: String = "user://settings.cfg"

var are_particles_enabled: bool = true


func _ready() -> void:
	load_settings()


func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("Settings", "sfx_volume_db", AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	config.set_value("Settings", "particles_enabled", are_particles_enabled)
	config.save(SETTINGS_PATH)


func load_settings() -> void:
	var config = ConfigFile.new()
	if not FileAccess.file_exists(SETTINGS_PATH):
		return

	config.load(SETTINGS_PATH)
	var sfx_vol = config.get_value("Settings", "sfx_volume_db", 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_vol)

	are_particles_enabled = config.get_value("Settings", "particles_enabled", true)
