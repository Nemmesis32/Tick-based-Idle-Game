extends Control

const DIRECTIONS = [
	Vector2i(0, -1), # oben
	Vector2i(1, 0),  # rechts
	Vector2i(0, 1),  # unten
	Vector2i(-1, 0)  # links
]

var selected_building : BuildingDefinition

var reactor_grid = []

var grid_width = 22
var grid_height = 15

var research_points : BigNumber = BigNumber.from_float(0.0)

var stored_energy : BigNumber = BigNumber.from_float(0.0)
var max_storage : BigNumber = BigNumber.from_float(100.0)

var credits : BigNumber = BigNumber.from_float(5000000000000000.0)


var building_list_cache : Dictionary = {}

var upgrades : Array[UpgradeDefinition] = []

@onready var header_row = $"MarginContainer/RootVbox/HeaderRow"
@onready var nav_tabs = $"MarginContainer/RootVbox/NavTabs"
@onready var components_panel = $"MarginContainer/RootVbox/MainArea/ComponentsPanel"
@onready var energy_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/EnergyPerTickLabel"
@onready var credits_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/Credits"
@onready var stored_bar = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/StoreBar"
@onready var stored_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/StoredLabel"
@onready var reactor_grid_container = $"MarginContainer/RootVbox/MainArea/GridPanel/ReactorGrid"
@onready var building_list = $MarginContainer/RootVbox/MainArea/ComponentsPanel/BuildingList
@onready var tooltip_label = $MarginContainer/RootVbox/MainArea/ComponentsPanel/TooltipBox/TooltipLabel
@onready var category_tabs = $"MarginContainer/RootVbox/MainArea/ComponentsPanel/ComponentsContent/CategoryTabs"

@onready var upgrade_list = $MarginContainer/RootVbox/UpgradePanel/ScrollContainer/UpgradeList
@onready var upgrade_panel = $MarginContainer/RootVbox/UpgradePanel
@onready var power_plants_tab = $"MarginContainer/RootVbox/NavTabs/PowerPlantsTab"
@onready var upgrade_tab = $"MarginContainer/RootVbox/NavTabs/UpgradeTab"
@onready var main_area = $"MarginContainer/RootVbox/MainArea"

func _ready():
	reactor_grid_container.columns = grid_width
	create_grid_data()
	build_grid()
	upgrades = UpgradeDatabase.get_all_upgrades()
	power_plants_tab.pressed.connect(_on_nav_power_plants)
	upgrade_tab.pressed.connect(_on_nav_upgrades)

	building_list_cache = _build_building_list()
	selected_building = building_list_cache["Generatoren"][0][1]

	var tab_buttons = category_tabs.get_children()
	for btn in tab_buttons:
		btn.pressed.connect(_on_category_tab_pressed.bind(btn.text))

	_on_category_tab_pressed("Reaktoren")
	update_ui(get_total_energy_production(), get_effective_max_storage())


func create_grid_data():
	reactor_grid.clear()
	for i in range(grid_width * grid_height):
		reactor_grid.append(null)


func build_grid():
	for child in reactor_grid_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	var available_width = (
		get_viewport_rect().size.x
		- components_panel.size.x
		- 240
		- 20
	)
	var available_height = (
		get_viewport_rect().size.y
		- header_row.size.y
		- nav_tabs.size.y
		- 65
	)
	var cell_size = min(
		available_width / grid_width,
		available_height / grid_height
	)
	for i in range(grid_width * grid_height):
		var button = Button.new()
		button.custom_minimum_size = Vector2(cell_size, cell_size)
		button.set_meta("grid_index", i)
		button.gui_input.connect(_on_grid_button_input.bind(button))
		reactor_grid_container.add_child(button)

		var fill_bar = ProgressBar.new()
		fill_bar.name = "FillBar"
		fill_bar.custom_minimum_size = Vector2(cell_size - 8, 4)
		fill_bar.position = Vector2(4, cell_size - 14)
		fill_bar.show_percentage = false
		fill_bar.max_value = 100
		fill_bar.value = 0
		button.add_child(fill_bar)

		var life_bar = ProgressBar.new()
		life_bar.name = "LifeBar"
		life_bar.custom_minimum_size = Vector2(cell_size - 8, 4)
		life_bar.position = Vector2(4, cell_size - 8)
		life_bar.show_percentage = false
		life_bar.max_value = 100
		life_bar.value = 0
		button.add_child(life_bar)


func _build_building_list() -> Dictionary:
	return {
		"Reaktoren": [
			["Solar Cell", BuildingDatabase.create_solar_cell()],
			["Coal Burner", BuildingDatabase.create_coal_burner()],
			["Gas Burner", BuildingDatabase.create_gas_burner()],
			["Nuclear Cell", BuildingDatabase.create_nuclear_cell()],
			["Thermonuclear Cell", BuildingDatabase.create_thermonuclear_cell()],
			["Fusion Cell", BuildingDatabase.create_fusion_cell()],
			["Thorium Cell", BuildingDatabase.create_thorium_cell()],
			["Protactium Cell", BuildingDatabase.create_protactium_cell()],
			["Curium Cell", BuildingDatabase.create_curium_cell()],
			["Balduranium Cell", BuildingDatabase.create_baldranium_cell()],
		],
		"Generatoren": [
			["Wind Turbine", BuildingDatabase.create_wind_turbine()],
			["Basic Generator", BuildingDatabase.create_basic_generator()],
			["Generator 2", BuildingDatabase.create_generator2()],
			["Generator 3", BuildingDatabase.create_generator3()],
			["Generator 4", BuildingDatabase.create_generator4()],
			["Generator 5", BuildingDatabase.create_generator5()],
		],
		"Hitze": [
			["Heat Pipe", BuildingDatabase.create_heat_pipe()],
			["Heat Sink", BuildingDatabase.create_heat_sink()],
			["Heat Inlet", BuildingDatabase.create_heat_inlet()],
			["Heat Outlet", BuildingDatabase.create_heat_outlet()],
		],
		"Wasser": [
			["Water Pump", BuildingDatabase.create_water_pump()],
			["Ground Water Pump", BuildingDatabase.create_ground_water_pump()],
			["Water Pipe", BuildingDatabase.create_water_pipe()],
		],
		"Verkauf": [
			["Home Office", BuildingDatabase.create_home_office()],
			["Small Office", BuildingDatabase.create_small_office()],
			["Medium Office", BuildingDatabase.create_medium_office()],
			["Large Office", BuildingDatabase.create_large_office()],
			["Huge Office", BuildingDatabase.create_huge_office()],
			["Boiler House", BuildingDatabase.create_boiler_house()],
			["Isolation", BuildingDatabase.create_isolation()],
			["Circulator", BuildingDatabase.create_circulator()],
			["Bank", BuildingDatabase.create_bank()],
			["Battery", BuildingDatabase.create_battery()],
		],
		"Forschung": [
			["Research Center", BuildingDatabase.create_research_center()],
			["Advanced Research Center", BuildingDatabase.create_advanced_research_center()],
			["Super Research Center", BuildingDatabase.create_super_research_center()],
		],
	}


func _on_category_tab_pressed(category: String) -> void:
	for child in building_list.get_children():
		child.queue_free()

	var category_buildings = building_list_cache.get(category, [])

	for entry in category_buildings:
		var btn = Button.new()
		var def = entry[1]
		btn.text = entry[0] + "  [" + def.cost.to_display_string() + "]"
		btn.custom_minimum_size = Vector2(200, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_building_select.bind(def))
		btn.mouse_entered.connect(_on_building_hover.bind(def))
		building_list.add_child(btn)


func _on_building_select(def: BuildingDefinition) -> void:
	selected_building = def


func _on_building_hover(def: BuildingDefinition) -> void:
	tooltip_label.text = (
		def.display_name
		+ "\nKosten: " + def.cost.to_display_string()
		+ "\nHitze: " + def.heat_production.to_display_string()
		+ "\nVerarbeitung: " + def.energy_processing.to_display_string()
	)


func index_to_coords(index: int) -> Vector2i:
	var x = index % grid_width
	@warning_ignore("integer_division")
	var y = int(index / grid_width)
	return Vector2i(x, y)


func coords_to_index(x: int, y: int) -> int:
	return y * grid_width + x


func get_neighbor_indices(index: int) -> Array[int]:
	var neighbors : Array[int] = []
	var pos = index_to_coords(index)

	for dir in DIRECTIONS:
		var check_pos = pos + dir
		if check_pos.x < 0:
			continue
		if check_pos.y < 0:
			continue
		if check_pos.x >= grid_width:
			continue
		if check_pos.y >= grid_height:
			continue
		neighbors.append(
			coords_to_index(
				check_pos.x,
				check_pos.y
			)
		)
	return neighbors


func process_heat():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.heat_production.is_zero():
			continue

		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []

		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.tags.has("heat_producer"):
				continue
			if neighbor.definition.tags.has("heat_immune"):
				continue
			valid_neighbors.append(neighbor_index)

		if valid_neighbors.is_empty():
			building.current_heat = building.current_heat.add(building.definition.heat_production)
			continue

		# Schritt 1: Type-Upgrade auf Basiswert
		var upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.HEAT_PRODUCTION
		)
		var upgraded_production = building.definition.heat_production.multiply_float(upgrade_mult)

		# Schritt 2: Nachbar-Boost (Isolatoren) obendrauf
		var boost = get_boost_for_building(i, "booster", "heat_boost")
		var final_production = upgraded_production.multiply_float(1.0 + boost)

		var heat_share = final_production.divide_float(valid_neighbors.size())

		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			neighbor.current_heat = neighbor.current_heat.add(heat_share)


func process_overheat():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.max_heat.is_zero():
			continue
		if building.current_heat.is_greater_or_equal(building.definition.max_heat):
			print("Überhitzung bei Index", i, "-", building.definition.display_name)
			reactor_grid[i] = null


func process_water():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.water_production.is_zero() and building.definition.water_transfer_rate <= 0:
			continue
		if building.definition.tags.has("water_transfer"):
			continue

		if not building.definition.water_production.is_zero():
			building.current_water = building.current_water.add(building.definition.water_production).min_with(building.definition.max_water)

		if building.current_water.is_zero():
			continue

		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.max_water.is_zero():
				continue
			if neighbor.definition.tags.has("water_producer"):
				continue
			if neighbor.current_water.is_greater_or_equal(neighbor.definition.max_water):
				continue
			valid_neighbors.append(neighbor_index)

		if valid_neighbors.is_empty():
			continue

		var total_transfer = building.definition.max_water.multiply_float(building.definition.water_transfer_rate).min_with(building.current_water)
		var water_share = total_transfer.divide_float(valid_neighbors.size())

		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			var room_left = neighbor.definition.max_water.subtract(neighbor.current_water)
			var actual_share = water_share.min_with(room_left)
			neighbor.current_water = neighbor.current_water.add(actual_share)
			building.current_water = building.current_water.subtract(actual_share)

func process_heat_pipes():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.heat_transfer_rate <= 0:
			continue
		if building.current_heat.is_zero():
			continue

		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.max_heat.is_zero():
				continue
			if neighbor.definition.tags.has("heat_producer"):
				continue
			if neighbor.current_heat.is_greater_or_equal(building.current_heat):
				continue
			valid_neighbors.append(neighbor_index)

		if valid_neighbors.is_empty():
			continue

		var transfer_amount = building.definition.max_heat.multiply_float(building.definition.heat_transfer_rate).min_with(building.current_heat)
		var heat_share = transfer_amount.divide_float(valid_neighbors.size())

		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			neighbor.current_heat = neighbor.current_heat.add(heat_share).min_with(neighbor.definition.max_heat)

		building.current_heat = building.current_heat.subtract(transfer_amount)


func process_water_pipes():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.water_transfer_rate <= 0:
			continue
		if not building.definition.tags.has("water_transfer"):
			continue
		if building.current_water.is_zero():
			continue

		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.max_water.is_zero():
				continue
			if neighbor.definition.tags.has("water_producer"):
				continue
			if neighbor.current_water.is_greater_or_equal(neighbor.definition.max_water):
				continue
			valid_neighbors.append(neighbor_index)

		if valid_neighbors.is_empty():
			continue

		var transfer_amount = building.definition.max_water.multiply_float(building.definition.water_transfer_rate).min_with(building.current_water)
		var water_share = transfer_amount.divide_float(valid_neighbors.size())

		var actually_transferred = BigNumber.from_float(0.0)
		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			var room_left = neighbor.definition.max_water.subtract(neighbor.current_water)
			var actual_share = water_share.min_with(room_left)
			neighbor.current_water = neighbor.current_water.add(actual_share)
			actually_transferred = actually_transferred.add(actual_share)
		building.current_water = building.current_water.subtract(actually_transferred)


func process_generators() -> BigNumber:
	var generated = BigNumber.from_float(0.0)
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.energy_processing.is_zero():
			continue

		# Schritt 1: Type-Upgrades auf Basiswerte
		var processing_upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.ENERGY_PROCESSING
		)
		var max_heat_upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.MAX_HEAT
		)
		var max_water_upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.MAX_WATER
		)

		var processing_capacity = building.definition.energy_processing.multiply_float(processing_upgrade_mult)
		var effective_max_heat = building.definition.max_heat.multiply_float(max_heat_upgrade_mult)
		var effective_max_water = building.definition.max_water.multiply_float(max_water_upgrade_mult)

		# Schritt 2: Circulator-Boost auf max_water obendrauf (bereits upgrade-aware)
		var water_boost = get_boost_for_building(i, "booster", "water_boost")
		effective_max_water = effective_max_water.multiply_float(1.0 + water_boost)

		while (
			building.current_heat.is_greater_than(processing_capacity)
			and not building.definition.water_consumption.is_zero()
			and building.current_water.is_greater_or_equal(building.definition.water_consumption)
		):
			building.current_water = building.current_water.subtract(building.definition.water_consumption)
			processing_capacity = processing_capacity.add(building.definition.water_boost_amount)

		# effective_max_heat als Obergrenze für processable
		var processable = building.current_heat.min_with(processing_capacity).min_with(effective_max_heat)
		building.current_heat = building.current_heat.subtract(processable)
		generated = generated.add(processable)

	return generated


func process_heat_sink():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if not building.definition.tags.has("heat_sink"):
			continue
		if building.current_heat.is_zero():
			continue
		var dissipated = building.current_heat.multiply_float(building.definition.energy_loss)
		building.current_heat = building.current_heat.subtract(dissipated)


func get_total_sell_capacity() -> BigNumber:
	var total = BigNumber.from_float(0.0)
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if not building.definition.tags.has("energy_seller"):
			continue

		# Schritt 1: Type-Upgrade auf sell_amount
		var upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.SELL_AMOUNT
		)
		var upgraded_sell = building.definition.sell_amount.multiply_float(upgrade_mult)

		# Schritt 2: Bank-Boost obendrauf (bereits upgrade-aware)
		var boost = get_boost_for_building(i, "booster", "sell_amount_boost")
		var effective_sell = upgraded_sell.multiply_float(1.0 + boost)

		total = total.add(effective_sell)
	return total


func process_research():
	for building in reactor_grid:
		if building == null:
			continue
		if not building.definition.tags.has("research_producer"):
			continue
		research_points = research_points.add(building.definition.research_production)


func get_boost_for_building(index: int, boost_tag: String, boost_field: String) -> float:
	var total_boost := 0.0
	var neighbors = get_neighbor_indices(index)
	for neighbor_index in neighbors:
		var neighbor = reactor_grid[neighbor_index]
		if neighbor == null:
			continue
		if not neighbor.definition.tags.has("booster"):
			continue
		match boost_field:
			"heat_boost":
				if neighbor.definition.heat_boost > 0:
					# Isolator-Upgrade anwenden
					var upgrade_mult = get_upgrade_multiplier(
						UpgradeDefinition.target_type.BUILDING_TYPE,
						neighbor.definition.building_type,
						UpgradeDefinition.stat_type.HEAT_BOOST
					)
					total_boost += neighbor.definition.heat_boost * upgrade_mult
			"water_boost":
				if neighbor.definition.water_boost > 0:
					var upgrade_mult = get_upgrade_multiplier(
						UpgradeDefinition.target_type.BUILDING_TYPE,
						neighbor.definition.building_type,
						UpgradeDefinition.stat_type.WATER_BOOST
					)
					total_boost += neighbor.definition.water_boost * upgrade_mult
			"sell_amount_boost":
				if neighbor.definition.sell_amount_boost > 0:
					var upgrade_mult = get_upgrade_multiplier(
						UpgradeDefinition.target_type.BUILDING_TYPE,
						neighbor.definition.building_type,
						UpgradeDefinition.stat_type.SELL_AMOUNT_BOOST
					)
					total_boost += neighbor.definition.sell_amount_boost * upgrade_mult
	return total_boost


func get_effective_max_storage() -> BigNumber:
	var total = max_storage

	# Global-Upgrade auf Storage
	var upgrade_mult = get_upgrade_multiplier(
		UpgradeDefinition.target_type.GLOBAL,
		BuildingDefinition.type.NONE,
		UpgradeDefinition.stat_type.ADDITIONAL_STORAGE
	)
	total = total.multiply_float(upgrade_mult)

	for building in reactor_grid:
		if building == null:
			continue
		if building.definition.additional_storage <= 0:
			continue
		total = total.add(BigNumber.from_float(building.definition.additional_storage * 100.0))
	return total


func refresh_grid_visuals():
	var buttons = reactor_grid_container.get_children()

	var fill_bar_types = [
		BuildingDefinition.type.WATER_PUMP,
		BuildingDefinition.type.WATER_PIPE,
		BuildingDefinition.type.HEAT_PIPE,
	]

	for i in range(reactor_grid.size()):
		var button = buttons[i]
		var building = reactor_grid[i]
		var fill_bar = button.get_node("FillBar")
		var life_bar = button.get_node("LifeBar")

		if building == null:
			button.text = "[ ]"
			fill_bar.visible = false
			life_bar.visible = false
			continue

		# Fill-Balken: nur für explizit erlaubte Typen
		if building.definition.building_type in fill_bar_types:
			if building.definition.tags.has("heat_transfer"):
				fill_bar.visible = true
				fill_bar.value = building.current_heat.divide(building.definition.max_heat).to_float() * 100
				fill_bar.modulate = Color.RED
			elif building.definition.tags.has("water_producer") or building.definition.tags.has("water_transfer"):
				fill_bar.visible = true
				fill_bar.value = building.current_water.divide(building.definition.max_water).to_float() * 100
				fill_bar.modulate = Color.BLUE
		else:
			fill_bar.visible = false

		# Life-Balken: nur wenn lifespan einen echten Wert hat
		if building.definition.lifespan == -1:
			life_bar.visible = false
		else:
			life_bar.visible = true
			life_bar.value = (float(building.age) / float(building.definition.lifespan)) * 100
			life_bar.modulate = Color.YELLOW

		match building.definition.building_type:
			BuildingDefinition.type.WIND_TURBINE:
				button.text = "[WT]"
			BuildingDefinition.type.SOLAR_CELL:
				button.text = "[R]"
			BuildingDefinition.type.COAL_BURNER:
				button.text = "[C]"
			BuildingDefinition.type.GAS_BURNER:
				button.text = "[GB]"
			BuildingDefinition.type.NUCLEAR_CELL:
				button.text = "[N]"
			BuildingDefinition.type.THERMONUCLEAR_CELL:
				button.text = "[TN]"
			BuildingDefinition.type.FUSION_CELL:
				button.text = "[F]"
			BuildingDefinition.type.WATER_PUMP:
				button.text = "[W]"
			BuildingDefinition.type.BASIC_GENERATOR:
				button.text = "[G]"
			BuildingDefinition.type.GENERATOR2:
				button.text = "[G2]"
			BuildingDefinition.type.GENERATOR3:
				button.text = "[G3]"
			BuildingDefinition.type.GENERATOR4:
				button.text = "[G4]"
			BuildingDefinition.type.WATER_PIPE:
				button.text = "[wP]"
			BuildingDefinition.type.HEAT_PIPE:
				button.text = "[hP]"
			BuildingDefinition.type.THORIUM_CELL:
				button.text = "[Th]"
			BuildingDefinition.type.PROTACTIUM_CELL:
				button.text = "[Pa]"
			BuildingDefinition.type.CURIUM_CELL:
				button.text = "[Cm]"
			BuildingDefinition.type.BALDRANIUM_CELL:
				button.text = "[Bd]"
			BuildingDefinition.type.GENERATOR5:
				button.text = "[G5]"
			BuildingDefinition.type.G_WATER_PUMP:
				button.text = "[GW]"
			BuildingDefinition.type.HEAT_SINK:
				button.text = "[HS]"
			BuildingDefinition.type.HEAT_INLET:
				button.text = "[HI]"
			BuildingDefinition.type.HEAT_OUTLET:
				button.text = "[HO]"
			BuildingDefinition.type.HOME_OFFICE:
				button.text = "[Ho]"
			BuildingDefinition.type.SMALL_OFFICE:
				button.text = "[So]"
			BuildingDefinition.type.MEDIUM_OFFICE:
				button.text = "[Mo]"
			BuildingDefinition.type.LARGE_OFFICE:
				button.text = "[Lo]"
			BuildingDefinition.type.HUGE_OFFICE:
				button.text = "[HO]"
			BuildingDefinition.type.BOILER_HOUSE:
				button.text = "[BH]"
			BuildingDefinition.type.RESEARCH_CENTER:
				button.text = "[RC]"
			BuildingDefinition.type.ADVANCED_RESEARCH_CENTER:
				button.text = "[AR]"
			BuildingDefinition.type.SUPER_RESEARCH_CENTER:
				button.text = "[SR]"
			BuildingDefinition.type.ISOLATION:
				button.text = "[Is]"
			BuildingDefinition.type.CIRCULATOR:
				button.text = "[Ci]"
			BuildingDefinition.type.BANK:
				button.text = "[Bk]"
			BuildingDefinition.type.BATTERY:
				button.text = "[Ba]"


func _on_grid_button_input(
	event: InputEvent,
	button: Button
) -> void:
	var index = button.get_meta("grid_index")
	handle_grid_click(event, index)


func _on_sell_energy_pressed() -> void:
	credits = credits.add(stored_energy)
	stored_energy = BigNumber.from_float(0.0)
	update_ui(get_total_energy_production(), get_effective_max_storage())


func _on_tick_timer_timeout() -> void:
	process_heat()
	process_water()
	process_heat_pipes()
	process_water_pipes()
	process_heat_sink()
	process_research()
	var generated = process_generators()
	process_overheat()

	# Einmal berechnen, überall benutzen
	var total_production = get_total_energy_production().add(generated)
	var effective_storage = get_effective_max_storage()
	var sell_capacity = get_total_sell_capacity()

	var sold_from_production = total_production.min_with(sell_capacity)
	credits = credits.add(sold_from_production)
	var remaining_energy = total_production.subtract(sold_from_production)

	var room_left = effective_storage.subtract(stored_energy)
	stored_energy = stored_energy.add(remaining_energy.min_with(room_left))

	var remaining_capacity = sell_capacity.subtract(sold_from_production)
	if remaining_capacity.is_greater_than(BigNumber.from_float(0.0)):
		var sold_from_storage = stored_energy.min_with(remaining_capacity)
		credits = credits.add(sold_from_storage)
		stored_energy = stored_energy.subtract(sold_from_storage)

	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		building.age += 1
		if building.definition.lifespan == -1:
			continue
		if building.age >= building.definition.lifespan:
			print(building.definition.display_name, " expired")
			reactor_grid[i] = null

	refresh_grid_visuals()
	update_ui(total_production, effective_storage)


func get_total_energy_production() -> BigNumber:
	var total = BigNumber.from_float(0.0)
	for building in reactor_grid:
		if building == null:
			continue
		total = total.add(building.definition.energy_production)
	return total


func place_building(index: int) -> void:
	if reactor_grid[index] != null:
		return
	if credits.is_less_than(selected_building.cost):
		return
	credits = credits.subtract(selected_building.cost)
	var building = Building.new(selected_building)
	reactor_grid[index] = building
	refresh_grid_visuals()
	update_ui(get_total_energy_production(), get_effective_max_storage())


func handle_grid_click(
	event: InputEvent,
	index: int,
) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				place_building(index)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				remove_building(index)


func remove_building(index: int) -> void:
	if reactor_grid[index] == null:
		return
	reactor_grid[index] = null
	refresh_grid_visuals()
	update_ui(get_total_energy_production(), get_effective_max_storage())


func get_upgrade_cost(upgrade: UpgradeDefinition) -> BigNumber:
	var exponent = upgrade.current_level
	var multiplier = pow(upgrade.cost_multiplier, exponent)
	return upgrade.base_cost.multiply_float(multiplier)


func purchase_upgrade(upgrade: UpgradeDefinition) -> void:
	if not can_purchase_upgrade(upgrade):
		return
	var cost = get_upgrade_cost(upgrade)
	credits = credits.subtract(cost)
	upgrade.current_level += 1
	update_ui(get_total_energy_production(), get_effective_max_storage())


func can_purchase_upgrade(upgrade: UpgradeDefinition) -> bool:
	# Vorgänger gekauft?
	if upgrade.requires != "":
		var required = get_upgrade_by_id(upgrade.requires)
		if required == null or required.current_level == 0:
			return false
	# Genug Credits?
	if credits.is_less_than(get_upgrade_cost(upgrade)):
		return false
	return true


func get_upgrade_by_id(id: String) -> UpgradeDefinition:
	for upgrade in upgrades:
		if upgrade.id == id:
			return upgrade
	return null


func get_upgrade_multiplier(
	target: UpgradeDefinition.target_type,
	building_type: BuildingDefinition.type,
	stat: UpgradeDefinition.stat_type
) -> float:
	var total := 1.0
	for upgrade in upgrades:
		if upgrade.current_level == 0:
			continue
		if upgrade.target != target:
			continue
		if upgrade.target == UpgradeDefinition.target_type.BUILDING_TYPE:
			if upgrade.building_type != building_type:
				continue
		if upgrade.stat != stat:
			continue
		total += upgrade.multiplier * upgrade.current_level
	return total


func _on_nav_power_plants() -> void:
	main_area.visible = true
	upgrade_panel.visible = false


func _on_nav_upgrades() -> void:
	main_area.visible = false
	upgrade_panel.visible = true
	refresh_upgrade_ui()


func refresh_upgrade_ui() -> void:
	for child in upgrade_list.get_children():
		child.queue_free()

	for upgrade in upgrades:
		# Abhängigkeit prüfen
		var is_locked = false
		if upgrade.requires != "":
			var required = get_upgrade_by_id(upgrade.requires)
			if required == null or required.current_level == 0:
				is_locked = true

		var cost = get_upgrade_cost(upgrade)

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 60)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.disabled = is_locked or credits.is_less_than(cost)

		if is_locked:
			btn.text = (
				"🔒 " + upgrade.display_name
				+ "\nBenötigt: " + upgrade.requires
			)
		else:
			btn.text = (
				upgrade.display_name
				+ "  [Stufe " + str(upgrade.current_level) + "]"
				+ "\n" + upgrade.description
				+ "\nKosten: " + cost.to_display_string()
			)

		btn.pressed.connect(_on_upgrade_pressed.bind(upgrade))
		upgrade_list.add_child(btn)


func _on_upgrade_pressed(upgrade: UpgradeDefinition) -> void:
	purchase_upgrade(upgrade)
	refresh_upgrade_ui()


func update_ui(total_production: BigNumber, effective_storage: BigNumber):
	credits_label.text = "Credits: " + credits.to_display_string()
	energy_label.text = "Energy/Tick: " + total_production.to_display_string()
	stored_label.text = "Stored: " + stored_energy.to_display_string() + " / " + effective_storage.to_display_string()
	stored_bar.value = stored_energy.divide(effective_storage).to_float() * 100
