extends Control

signal back_pressed

@onready var grid_container = $ScrollContainer/GridContainer
@onready var back_button = $PowerPlant
@onready var credits_label = $CreditsLabel

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func setup(upgrades: Array, credits: BigNumber, on_purchase: Callable, on_sell: Callable) -> void:
	credits_label.text = "Credits: " + credits.to_display_string()

	for child in grid_container.get_children():
		child.queue_free()

	for upgrade in upgrades:
		var container = PanelContainer.new()
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var hbox = HBoxContainer.new()
		container.add_child(hbox)

		var info = Label.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.text = (
			upgrade.display_name
			+ "  [Stufe " + str(upgrade.current_level) + "]"
			+ "\n" + upgrade.description
			+ "\nKosten: " + upgrade.base_cost.multiply_float(
				pow(upgrade.cost_multiplier, upgrade.current_level)
			).to_display_string()
		)
		hbox.add_child(info)

		# Sell-Button nur für Reaktor Heat-Production Upgrades
		if upgrade.stat == UpgradeDefinition.stat_type.HEAT_PRODUCTION and upgrade.current_level > 0:
			var sell_btn = Button.new()
			sell_btn.text = "SELL"
			sell_btn.custom_minimum_size = Vector2(80, 0)
			sell_btn.modulate = Color.RED
			sell_btn.pressed.connect(on_sell.bind(upgrade))
			hbox.add_child(sell_btn)

		var buy_btn = Button.new()
		buy_btn.text = "BUY"
		buy_btn.custom_minimum_size = Vector2(80, 0)
		buy_btn.pressed.connect(on_purchase.bind(upgrade))
		hbox.add_child(buy_btn)

		grid_container.add_child(container)

func _on_back_pressed() -> void:
	emit_signal("back_pressed")
