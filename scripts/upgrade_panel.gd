extends Control
signal back_pressed

@onready var grid_allgemein = $ScrollContainer/VBoxContainer/Grid_Allgemein
@onready var grid_wasser = $ScrollContainer/VBoxContainer/GridWasser
@onready var grid_reaktor = $ScrollContainer/VBoxContainer/GridReaktor
@onready var back_button = $PowerPlant
@onready var credits_label = $CreditsLabel

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	grid_allgemein.columns = 2
	grid_wasser.columns = 2
	grid_reaktor.columns = 2

func setup(upgrades: Array, credits: BigNumber, on_purchase: Callable, on_sell: Callable, research: Array) -> void:
	credits_label.text = "Credits: " + credits.to_display_string()
	for child in grid_allgemein.get_children():
		child.queue_free()
	for child in grid_wasser.get_children():
		child.queue_free()
	for child in grid_reaktor.get_children():
		child.queue_free()

	var allgemein_ids = [
		"office_sell_power", "research_center_production", "boiler_house_sell", "power_battery_size"
	]
	var wasser_ids = [
		"generator_max_heat", "generator_effectiveness", "generator_max_water",
		"heat_exchanger_max_heat", "heat_sink_max_heat", "heat_pipe_transfer",
		"heat_inlet_outlet_max_heat", "water_pump_production", "ground_water_pump_production",
		"water_pipe_transfer", "water_elem_max_water", "isolation_effectiveness", "circulator_water_buff"
	]
	var reaktor_order = [
		"balduranium_cell_heat", "balduranium_cell_lifetime",
		"curium_cell_heat", "curium_cell_lifetime",
		"protactium_cell_heat", "protactium_cell_lifetime",
		"thorium_cell_heat", "thorium_cell_lifetime",
		"fusion_cell_heat", "fusion_cell_lifetime",
		"thermonuclear_cell_heat", "thermonuclear_cell_lifetime",
		"nuclear_cell_heat", "nuclear_cell_lifetime",
		"gas_burner_heat", "gas_burner_lifetime",
		"coal_burner_heat", "coal_burner_lifetime",
		"solar_cell_heat", "solar_cell_lifetime",
		"wind_turbine_heat", "wind_turbine_lifetime",
	]

	for upgrade in upgrades:
		if upgrade.required_research != "" and not _is_researched(upgrade.required_research, research):
			continue
		if upgrade.id in allgemein_ids:
			_add_upgrade_entry(upgrade, grid_allgemein, on_purchase, on_sell)
		elif upgrade.id in wasser_ids:
			_add_upgrade_entry(upgrade, grid_wasser, on_purchase, on_sell)

	for id in reaktor_order:
		for upgrade in upgrades:
			if upgrade.id == id:
				if upgrade.required_research == "" or _is_researched(upgrade.required_research, research):
					_add_upgrade_entry(upgrade, grid_reaktor, on_purchase, on_sell)
				break

func _add_upgrade_entry(upgrade: UpgradeDefinition, grid: GridContainer, on_purchase: Callable, on_sell: Callable) -> void:
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
	grid.add_child(container)

func _is_researched(research_id: String, research: Array) -> bool:
	for item in research:
		if item.id == research_id and item.is_purchased:
			return true
	return false

func _on_back_pressed() -> void:
	emit_signal("back_pressed")
