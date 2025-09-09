extends PanelContainer

@onready var earnings_label: Label = %EarningsLabel
@onready var confirm_button: Button = %ConfirmButton

func _ready() -> void:
	confirm_button.pressed.connect(hide)


func set_earnings_text(amount_string: String) -> void:
	earnings_label.text = "You earned %s Harmony while away!" % amount_string
