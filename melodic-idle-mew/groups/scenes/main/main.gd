class_name Main
extends Node


signal harmony_changed

const MAX_SEQUENCE_LENGTH: int = 8
const KEY_SOUNDS: Dictionary[Key, Resource] = {
	KEY_A: preload("uid://c2iyxxlkl8dwi"),
	KEY_S: preload("uid://dw3yrejesx1k3"),
	KEY_D: preload("uid://cird6olpb5uf2"),
	KEY_F: preload("uid://ccaw1ma0won7n"),
	KEY_J: preload("uid://8qirlxdnt54"),
	KEY_K: preload("uid://pdpj6npijygl"),
	KEY_L: preload("uid://br7br87ricq5x"),
	KEY_SEMICOLON: preload("uid://br7br87ricq5x"),
}
const INPUT_KEYS: Dictionary[StringName, Key] = {
	&"A": KEY_A,
	&"S": KEY_S,
	&"D": KEY_D,
	&"F": KEY_F,
	&"J": KEY_J,
	&"K": KEY_K,
	&"L": KEY_L,
	&";": KEY_SEMICOLON,
}
const SOUND_PLAYER_SCENE: PackedScene = preload("uid://dogohd77h1fxg")
const SAVE_PATH: String = "user://savegame.cfg"
const FALLING_NOTE_SCENE: PackedScene = preload("uid://dfwfg5401ktkn")

static var instance: Main ## A globally-accessible reference to Main

var harmony_per_second: float = 1.0
var sequence: Array[Key] = []
var current_instrument_color: Color = Color.WHITE
var sequence_tween: Tween
var harmony: float = 0.0:
	set = set_harmony

@onready var harmony_label: Label = %HarmonyLabel
@onready var keypress_particles: GPUParticles2D = %KeypressParticles
@onready var combo_unlock_particles: GPUParticles2D = %ComboUnlockParticles
@onready var fps_label: Label = %FPSLabel
@onready var upgrades_display: VBoxContainer = %UpgradesDisplay
@onready var combo_reset_timer: Timer = %ComboResetTimer
@onready var sequence_label: Label = %SequenceLabel
@onready var pause_menu = $PauseMenu
@onready var offline_progress_popup = %OfflineProgressPopup


#region Static


static func get_harmony() -> float:
	return instance.harmony


#endregion


#region Ready


func _init() -> void:
	instance = self


func _ready() -> void:
	get_tree().root.close_requested.connect(save_game)
	
	var autosave_timer := Timer.new()
	autosave_timer.name = "AutosaveTimer"
	autosave_timer.wait_time = 30.0 
	autosave_timer.timeout.connect(save_game)
	add_child(autosave_timer)
	autosave_timer.start()
	
	_setup_harmony_label()
	Combo.create_combos()
	
	UpgradeDisplayRow.create_upgrade_rows()
	
	load_game() 
	
	_update_fps_label()
	
	pause_menu.quit_requested.connect(quit_to_main_menu)


func _setup_harmony_label() -> void:
	harmony_changed.connect(_update_harmony_label)
	_update_harmony_label()


#endregion


#region Setters


func set_harmony(new_harmony: float) -> void:
	if harmony == new_harmony:
		return
	harmony = new_harmony
	harmony_changed.emit()


#endregion


#region Signals


func _process(delta: float) -> void:
	_increment_harmony(delta)


func _unhandled_key_input(event: InputEvent) -> void:
	for action_name: StringName in INPUT_KEYS:
		if event.is_action_pressed(action_name, false, true):
			_add_to_sequence(INPUT_KEYS[action_name])
			break


func _on_combo_reset_timer_timeout() -> void:
	if sequence.is_empty():
		return
	
	var tween := create_tween()
	tween.tween_property(sequence_label, "modulate", Color.CRIMSON, 0.2)
	tween.tween_property(sequence_label, "modulate:a", 0.0, 0.3)
	
	await tween.finished
	
	print("Sequence reset due to timeout.")
	sequence.clear()
	_update_sequence_label()


#endregion


#region Control


func _update_fps_label() -> void:
	while true:
		fps_label.text = str(Engine.get_frames_per_second())
		await get_tree().create_timer(1.0).timeout


func _update_harmony_label() -> void:
	harmony_label.text = "Harmony: %s" % format_number(harmony)


func _increment_harmony(delta: float) -> void:
	harmony += harmony_per_second * delta


func _add_to_sequence(key: Key) -> void:
	var key_string := OS.get_keycode_string(key)
	_spawn_falling_note(key_string)
	
	get_viewport().set_input_as_handled()
	
	sequence.append(key)
	while sequence.size() > MAX_SEQUENCE_LENGTH:
		sequence.remove_at(0)
	
	Log.pr("Current sequence:", sequence.map(OS.get_keycode_string))
	_update_sequence_label()
	
	_play_key_sound(key)
	_play_particle_effect()
	_check_for_combo()
	combo_reset_timer.start()


func _play_key_sound(key: Key) -> void:
	var sound_player_instance: AudioStreamPlayer = SOUND_PLAYER_SCENE.instantiate()
	add_child(sound_player_instance)
	
	sound_player_instance.stream = KEY_SOUNDS[key]
	sound_player_instance.play()


func _check_for_combo():
	for _combo: Combo in Combo.list:
		if _combo.sequence_matches(sequence):
			Log.pr(_combo.name, "combo!")
			
			var can_trigger_combo: bool = (
					not _combo.unlocked
					and harmony >= _combo.cost)
			
			if can_trigger_combo:
				_trigger_combo(_combo)
				break


func _trigger_combo(combo: Combo) -> void:
	combo_reset_timer.start()
	_play_sequence_success_animation()
	harmony -= combo.cost
	harmony_per_second += combo.reward
	combo.unlocked = true
	current_instrument_color = combo.color
	combo_unlock_particles.emitting = true
	Log.pr("Unlocked %s!" % combo.name)
	_update_fps_label()


func _play_particle_effect() -> void:
	if not Settings.are_particles_enabled: return
	keypress_particles.modulate = current_instrument_color
	keypress_particles.emitting = true


func _update_sequence_label() -> void:
	if is_instance_valid(sequence_tween):
		sequence_tween.kill()
	var sequence_as_strings = sequence.map(func(key_enum): return OS.get_keycode_string(key_enum))
	sequence_label.text = " ".join(sequence_as_strings)

	sequence_label.modulate = Color.WHITE


func _play_sequence_success_animation() -> void:
	if is_instance_valid(sequence_tween):
		sequence_tween.kill()
	
	sequence_tween = create_tween()
	sequence_tween.tween_property(sequence_label, "modulate", Color.GOLD, 0.15)
	sequence_tween.tween_property(sequence_label, "modulate", Color.WHITE, 0.4)


func format_number(num: float) -> String:
	var s = "%d" % num 
	var str_len = s.length()
	if str_len <= 3:
		return s
	
	var mod = str_len % 3
	var res = ""
	if mod != 0:
		res += s.substr(0, mod) + ","
	
	for i in range(mod, str_len, 3):
		res += s.substr(i, 3) + ","
	
	return res.left(res.length() - 1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = true 
		pause_menu.show()


func _spawn_falling_note(key_as_string: String) -> void:
	var note = FALLING_NOTE_SCENE.instantiate()
	
	var spawn_pos = get_viewport().get_visible_rect().size / 2.0
	spawn_pos.x += randf_range(-50.0, 50.0)
	note.position = spawn_pos
	
	note.set_note_text(key_as_string)
	
	add_child(note)


#endregion


#region SaveLoad


func save_game() -> void:
	Log.pr("Saving game...")
	
	var start_time: int = Time.get_ticks_msec()
	var config := ConfigFile.new()
	
	config.set_value("PlayerData", "harmony", harmony)
	config.set_value("PlayerData", "harmony_per_second", harmony_per_second)
	config.set_value("PlayerData", "instrument_color", current_instrument_color)
	config.set_value("PlayerData", "last_session_time", Time.get_unix_time_from_system())
	
	for _combo: Combo in Combo.list:
		var section: String = "Combo_%s" % _combo.type
		config.set_value(section, "unlocked", _combo.unlocked)
	
	var error := config.save(SAVE_PATH)
	if error != OK:
		Log.pr("Error saving game!")
		return
	
	# Using start_time, this tells you how long this function took! (useful on bigger functions)
	Log.pr("Game saved in", Time.get_ticks_msec() - start_time, "ms")


func quit_to_main_menu() -> void:
	save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file(MainMenu.UID)
	queue_free()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		Log.pr("No save file found.")
		return
	
	Log.pr("Loading game...")
	var config := ConfigFile.new()
	
	var error := config.load(SAVE_PATH)
	if error != OK:
		Log.pr("Error loading game!")
		return
	
	harmony = config.get_value("PlayerData", "harmony", 0.0)
	harmony_per_second = config.get_value("PlayerData", "harmony_per_second", 1.0)
	current_instrument_color = config.get_value("PlayerData", "instrument_color", Color.WHITE)
	
	var last_time = config.get_value("PlayerData", "last_session_time", 0)
	if last_time > 0:
		var current_time = Time.get_unix_time_from_system()
		var seconds_offline = current_time - last_time
		# offline cap 7 days
		seconds_offline = min(seconds_offline, 60 * 60 * 24 * 7) 
		
		var harmony_earned_offline = seconds_offline * harmony_per_second
		
		if harmony_earned_offline > 1:
			harmony += harmony_earned_offline
			offline_progress_popup.set_earnings_text(format_number(harmony_earned_offline))
			offline_progress_popup.show()
	
	for _combo: Combo in Combo.list:
		var section: String = "Combo_%s" % _combo.type
		_combo.unlocked = config.get_value(section, "unlocked", false)



#endregion
