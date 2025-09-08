class_name Combo
extends RefCounted


enum Type {
	FLUTE,
	PIANO,
	ORGAN,
	SCHLONGO,
}

static var list: Array[Combo]

var type: Type
var name: String
var cost: int
var reward: int
var unlocked: bool = false
var combo_sequence: Array[Key] = []
var hint: String
var color: Color


static func create_combos() -> void:
	for combo_type: Type in Type.values():
		var new_combo: Combo = Combo.new(combo_type)
		list.append(new_combo)


func _init(_type: Type) -> void:
	type = _type
	name = Type.keys()[_type].capitalize()
	
	match _type:
		Type.FLUTE:
			cost = 50
			reward = 5
			combo_sequence = [KEY_A, KEY_S, KEY_D, KEY_F]
			hint = "A S _ _"
			color = Color.SKY_BLUE
		Type.PIANO:
			cost = 250
			reward = 25
			combo_sequence = [KEY_L, KEY_K, KEY_J, KEY_SEMICOLON]
			hint = "L K _ ;"
			color = Color.GOLD
		Type.ORGAN:
			cost = 1000
			reward = 150
			combo_sequence = [KEY_A, KEY_D, KEY_L, KEY_J]
			hint = "A _ L _"
			color = Color.MEDIUM_PURPLE
		Type.SCHLONGO:
			cost = 5000
			reward = 600
			combo_sequence = [
				KEY_A, KEY_S, KEY_D, KEY_F, 
				KEY_J, KEY_K, KEY_L, KEY_SEMICOLON,
			]
			hint = "A S D F _ _ _ ;"
			color = Color.CRIMSON


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
