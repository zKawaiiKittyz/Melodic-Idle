class_name Main
extends Node


signal harmony_changed

enum ComboType {
	FLUTE,
	PIANO,
	ORGAN,
	SCHLONGO,
}
const MAX_SEQUENCE_LENGTH: int = 8
const KEY_SOUNDS: Dictionary[Key, Resource] = {
	KEY_A: preload("res://sounds/c4.ogg"),
	KEY_S: preload("res://sounds/d4.ogg"),
	KEY_D: preload("res://sounds/e4.ogg"),
	KEY_F: preload("res://sounds/f4.ogg"),
	KEY_J: preload("res://sounds/g4.ogg"),
	KEY_K: preload("res://sounds/a4.ogg"),
	KEY_L: preload("res://sounds/b4.ogg"),
	KEY_SEMICOLON: preload("res://sounds/c5.ogg"),
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
const SOUND_PLAYER_SCENE: PackedScene = preload("uid://nmbacrjhvq4e")
const UPGRADE_DISPLAY_ROW_SCENE: PackedScene = preload("uid://78mqrogxb8mt")

var harmony_per_second: float = 1.0
var sequence: Array[Key] = []
var combos: Array[Combo] = []
var harmony: float = 0.0:
	set = set_harmony

@onready var harmony_label: Label = %HarmonyLabel
@onready var keypress_particles: GPUParticles2D = %KeypressParticles
@onready var fps_label: Label = %FPSLabel
@onready var upgrades_display: VBoxContainer = %UpgradesDisplay


#region Ready


func _ready() -> void:
	_setup_harmony_label()
	_create_combos()
	_create_upgrade_rows()
	_update_upgrades_display()
	harmony_changed.connect(_update_upgrades_display)
	_update_fps_label()


func _setup_harmony_label() -> void:
	harmony_changed.connect(_update_harmony_label)
	_update_harmony_label()


func _create_combos() -> void:
	for combo_type: ComboType in ComboType.values():
		var new_combo: Combo = Combo.new(combo_type)
		combos.append(new_combo)


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


#endregion


#region Control


func _update_fps_label() -> void:
	while true:
		fps_label.text = str(Engine.get_frames_per_second())
		await get_tree().create_timer(1.0).timeout


func _update_harmony_label() -> void:
	harmony_label.text = "Harmony: %s" % str(harmony).pad_decimals(2)


func _increment_harmony(delta: float) -> void:
	harmony += harmony_per_second * delta


func _add_to_sequence(key: Key) -> void:
	get_viewport().set_input_as_handled()
	
	sequence.append(key)
	while sequence.size() > MAX_SEQUENCE_LENGTH:
		sequence.remove_at(0)
	
	print("Current sequence: ", sequence.map(OS.get_keycode_string))
	
	_play_key_sound(key)
	_play_particle_effect()
	_check_for_combo()


func _play_key_sound(key: Key) -> void:
	var sound_player_instance: AudioStreamPlayer = SOUND_PLAYER_SCENE.instantiate()
	add_child(sound_player_instance)
	
	sound_player_instance.stream = KEY_SOUNDS[key]
	sound_player_instance.play()


func _check_for_combo():
	for combo: Combo in combos:
		if combo.sequence_matches(sequence):
			print("%s combo!" % combo.name)
			
			var can_trigger_combo: bool = (
				not combo.unlocked
				and harmony >= combo.cost
			)
			
			if can_trigger_combo:
				_trigger_combo(combo)
				
				break


func _trigger_combo(combo: Combo) -> void:
	harmony -= combo.cost
	harmony_per_second += combo.reward
	combo.unlocked = true
	print("Unlocked %s!" % combo.name)
	_update_fps_label()


func _play_particle_effect() -> void:
	#keypress_particles.global_position = get_viewport_rect().size / 2.0
	keypress_particles.emitting = true


func _create_upgrade_rows() -> void:
	for combo in combos:
		var row: Control = UPGRADE_DISPLAY_ROW_SCENE.instantiate()
		upgrades_display.add_child(row)


func _update_upgrades_display() -> void:
	for i in combos.size():
		var combo: Combo = combos[i]
		var row = upgrades_display.get_child(i)

		var name_label = row.get_node("%InstrumentNameLabel")
		var hint_label = row.get_node("%HintLabel")
		var cost_label = row.get_node("%CostLabel")

		if combo.unlocked:
			name_label.text = combo.name
			hint_label.text = "UNLOCKED"
			cost_label.text = "" 
			row.modulate = Color(1.0, 1.0, 1.0) 
		else:
			name_label.text = "?????????"
			hint_label.text = combo.hint
			cost_label.text = "Cost: %s" % combo.cost

			if harmony >= combo.cost:
				row.modulate = Color(0.7, 1.0, 0.7) 
			else:
				row.modulate = Color(0.5, 0.5, 0.5) 


#endregion


#region Sub-Classes


class Combo:
	var name: String
	var cost: int
	var reward: int
	var unlocked: bool = false
	var combo_sequence: Array[Key] = []
	var hint: String
	
	
	func _init(_type: ComboType) -> void:
		name = ComboType.keys()[_type].capitalize()
		
		match _type:
			ComboType.FLUTE:
				cost = 50
				reward = 5
				combo_sequence = [KEY_A, KEY_S, KEY_D, KEY_F]
				hint = "A S _ _"
			ComboType.PIANO:
				cost = 250
				reward = 25
				combo_sequence = [KEY_L, KEY_K, KEY_J, KEY_SEMICOLON]
				hint = "L K _ ;"
			ComboType.ORGAN:
				cost = 1000
				reward = 150
				combo_sequence = [KEY_A, KEY_D, KEY_L, KEY_J]
				hint = "A _ L _"
			ComboType.SCHLONGO:
				cost = 5000
				reward = 600
				combo_sequence = [
					KEY_A, KEY_S, KEY_D, KEY_F, 
					KEY_J, KEY_K, KEY_L, KEY_SEMICOLON,
				]
				hint = "A S D F _ _ _ ;"
	
	
	## Checks whether this combo contains the player's played sequence
	func sequence_matches(played_sequence: Array[Key]) -> bool:
		var combo_sequence_size: int = combo_sequence.size()
		 
		if played_sequence.size() < combo_sequence_size:
			return false
		
		var sliced: Array[Key] =played_sequence.slice(
			-combo_sequence_size,
			played_sequence.size()
		)
		
		return combo_sequence == sliced


#endregion
