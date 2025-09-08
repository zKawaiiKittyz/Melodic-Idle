class_name UpgradeDisplayRow
extends Control


const UPGRADE_DISPLAY_ROW_SCENE: PackedScene = preload("uid://78mqrogxb8mt")
const UPGRADE_DISPLAY_ROW_SCRIPT: Script = preload("uid://dvv05fs1cbwk1")

var combo: Combo

@onready var instrument_name_label: Label = %InstrumentNameLabel
@onready var hint_label: Label = %HintLabel
@onready var cost_label: Label = %CostLabel
@onready var reward_label: Label = %RewardLabel


static func create_upgrade_rows() -> void:
	for _combo in Combo.list:
		var row: UpgradeDisplayRow = UPGRADE_DISPLAY_ROW_SCENE.instantiate()
		Main.instance.upgrades_display.add_child(row)


func _ready() -> void:
	combo = Combo.list[get_index()]
	Main.instance.harmony_changed.connect(update)


func update() -> void:
	if combo.unlocked:
		instrument_name_label.text = combo.name
		hint_label.text = "UNLOCKED"
		cost_label.text = "" 
		modulate = Color(1.0, 1.0, 1.0) 
	else:
		instrument_name_label.text = "?????????"
		hint_label.text = combo.hint
		cost_label.text = "Cost: %s" % combo.cost
		
		if Main.get_harmony() >= combo.cost:
			modulate = Color(0.7, 1.0, 0.7)
		else:
			modulate = Color(0.5, 0.5, 0.5)
