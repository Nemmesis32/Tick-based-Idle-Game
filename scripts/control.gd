extends Control

var selected_building : BuildingDefinition
var building_list_cache : Dictionary = {}
var upgrade_mode : bool = false
var research_panel_instance = null
var research_panel_scene = preload("res://scenes/research_panel.tscn")
var upgrade_panel_instance = null
var upgrade_panel_scene = preload("res://scenes/upgrade_panel.tscn")
var map_overview_panel : Control = null
var map_overview_card_grid : GridContainer = null
var showing_overview : bool = true
var overlay_event_text : String = ""

var texture_grass = preload("res://assets/terrain/Gras Tile.png")
var texture_water = preload("res://assets/terrain/Water Tile (2).png")

# Shore-Autotile-Set: Name = Richtung, in der Wasser liegt (siehe get_shore_texture())
var texture_shore_n = preload("res://assets/terrain/shore/Shore top.png")
var texture_shore_s = preload("res://assets/terrain/shore/Shore down.png")
var texture_shore_e = preload("res://assets/terrain/shore/Shore right 5.png")
var texture_shore_w = preload("res://assets/terrain/shore/Shore left.png")
var texture_shore_ne = preload("res://assets/terrain/shore/Shore UpRight.png")
var texture_shore_nw = preload("res://assets/terrain/shore/Shore UpLeft.png")
var texture_shore_se = preload("res://assets/terrain/shore/Shore downRight.png")
var texture_shore_sw = preload("res://assets/terrain/shore/Shore down_left.png")
var texture_shore_ns = preload("res://assets/terrain/shore/Shore parallel.png")
var texture_shore_ew = preload("res://assets/terrain/shore/Shore parallel_UP.png")
var texture_shore_nes = preload("res://assets/terrain/shore/Shore U_right.png")
var texture_shore_esw = preload("res://assets/terrain/shore/Shore U_Down.png")
var texture_shore_nsw = preload("res://assets/terrain/shore/Shore U_left.png")
var texture_shore_new = preload("res://assets/terrain/shore/Shore U_Up.png")


@onready var header_row = $"MarginContainer/RootVbox/HeaderRow"
@onready var nav_tabs = $"MarginContainer/RootVbox/NavTabs"
@onready var components_panel = $"MarginContainer/RootVbox/MainArea/ComponentsPanel"
@onready var energy_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/EnergyPerTickLabel"
@onready var credits_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/Credits"
@onready var stored_bar = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/StoreBar"
@onready var stored_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/StoredLabel"
@onready var reactor_grid_container = $"MarginContainer/RootVbox/MainArea/GridPanel/ReactorGrid"
@onready var building_list = $"MarginContainer/RootVbox/MainArea/ComponentsPanel/BuildingList"
@onready var tooltip_label = $"MarginContainer/RootVbox/MainArea/ComponentsPanel/TooltipBox/TooltipLabel"
@onready var category_tabs = $"MarginContainer/RootVbox/MainArea/ComponentsPanel/ComponentsContent/CategoryTabs"
@onready var grid_panel = $"MarginContainer/RootVbox/MainArea/GridPanel"
@onready var main_area = $"MarginContainer/RootVbox/MainArea"
@onready var power_plants_tab = $"MarginContainer/RootVbox/NavTabs/PowerPlantsTab"
@onready var upgrade_tab = $"MarginContainer/RootVbox/NavTabs/UpgradeTab"
@onready var research_tab = $MarginContainer/RootVbox/NavTabs/ResearchTab
@onready var research_label = $MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/Research
@onready var tick_timer = $TickTimer
@onready var pause_button = $MarginContainer/RootVbox/HeaderRow/ControlBox/VBoxContainer/SpeedRow/Pause
@onready var fast_button = $MarginContainer/RootVbox/HeaderRow/ControlBox/VBoxContainer/SpeedRow/Fast
@onready var bonus_tick_label = $MarginContainer/RootVbox/HeaderRow/ControlBox/VBoxContainer/BonusTicksLabel
@onready var auto_rebuild_button = $MarginContainer/RootVbox/HeaderRow/ControlBox/VBoxContainer/HBoxContainer/Button
@onready var overlay_label = $"MarginContainer/RootVbox/HeaderRow/OverlayBox/OverlayLabel"


func _ready() -> void:
	MapManager.add_map("main", "Hauptinsel", 24, 13, "main")
	var second_map = MapManager.add_map("second", "Zweite Insel", 24, 13, "second")
	second_map.is_unlocked = false
	second_map.unlock_cost = BigNumber.from_float(100000000.0)
	reactor_grid_container.columns = active_map().grid_width
	build_grid()
	power_plants_tab.pressed.connect(_on_nav_power_plants)
	upgrade_tab.pressed.connect(_on_nav_upgrades)
	research_tab.pressed.connect(_on_nav_research)
	building_list_cache = _build_building_list()
	selected_building = building_list_cache["Generatoren"][0][1]
	pause_button.pressed.connect(_on_pause_pressed)
	fast_button.pressed.connect(_on_fast_pressed)
	auto_rebuild_button.pressed.connect(_on_auto_rebuild_pressed)
	var tab_buttons = category_tabs.get_children()
	for btn in tab_buttons:
		btn.pressed.connect(_on_category_tab_pressed.bind(btn.text))
	_on_category_tab_pressed("Reaktoren")
	var save_timer = Timer.new()
	add_child(save_timer)
	save_timer.wait_time = 60.0
	save_timer.autostart = true
	save_timer.timeout.connect(save_game)
	save_timer.start()
	var bonus_timer = Timer.new()
	bonus_timer.name = "BonusTimer"
	add_child(bonus_timer)
	bonus_timer.wait_time = 1.0 / 30.0
	bonus_timer.timeout.connect(_on_bonus_tick)
	var overlay_event_timer = Timer.new()
	overlay_event_timer.name = "OverlayEventTimer"
	overlay_event_timer.one_shot = true
	add_child(overlay_event_timer)
	overlay_event_timer.timeout.connect(_on_overlay_event_expired)
	get_tree().set_auto_accept_quit(false)
	await get_tree().process_frame
	load_game()
	build_map_overview_panel()
	update_ui(get_total_energy_production(), get_effective_max_storage())
	_on_nav_power_plants()


func active_map() -> MapState:
	return MapManager.get_active_map()


func _is_water_at(map: MapState, x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= map.grid_width or y >= map.grid_height:
		return true  # außerhalb vom Grid zählt als Wasser (Insel-Rand)
	return map.grid_terrain[map.coords_to_index(x, y)] == MapState.TileType.WATER


func get_shore_texture(map: MapState, index: int) -> Texture2D:
	var pos = map.index_to_coords(index)
	var water_n = _is_water_at(map, pos.x, pos.y - 1)
	var water_e = _is_water_at(map, pos.x + 1, pos.y)
	var water_s = _is_water_at(map, pos.x, pos.y + 1)
	var water_w = _is_water_at(map, pos.x - 1, pos.y)

	var mask = 0
	if water_n:
		mask |= 1
	if water_e:
		mask |= 2
	if water_s:
		mask |= 4
	if water_w:
		mask |= 8

	match mask:
		1: return texture_shore_n
		2: return texture_shore_e
		4: return texture_shore_s
		8: return texture_shore_w
		3: return texture_shore_ne
		9: return texture_shore_nw
		6: return texture_shore_se
		12: return texture_shore_sw
		5: return texture_shore_ns
		10: return texture_shore_ew
		7: return texture_shore_nes
		14: return texture_shore_esw
		13: return texture_shore_nsw
		11: return texture_shore_new
		_: return texture_shore_n  # Rand-Fall: 0 oder 4 Wasser-Nachbarn, kein passendes Sprite


func build_map_overview_panel() -> void:
	if map_overview_panel != null:
		map_overview_panel.queue_free()
		map_overview_panel = null
		map_overview_card_grid = null

	map_overview_panel = Control.new()
	map_overview_panel.name = "MapOverviewPanel"
	map_overview_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_overview_panel.visible = false

	var background = ColorRect.new()
	background.color = Color(0.14, 0.14, 0.16)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_overview_panel.add_child(background)

	get_tree().root.add_child.call_deferred(map_overview_panel)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 40)
	map_overview_panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "Deine Maps"
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	map_overview_card_grid = GridContainer.new()
	map_overview_card_grid.columns = 3
	map_overview_card_grid.add_theme_constant_override("h_separation", 20)
	map_overview_card_grid.add_theme_constant_override("v_separation", 20)
	vbox.add_child(map_overview_card_grid)

	for map in MapManager.maps:
		map_overview_card_grid.add_child(_build_map_card(map))


func _build_map_card(map: MapState) -> Control:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(240, 150)

	var inner = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	card.add_child(inner)

	var name_label = Label.new()
	name_label.text = map.display_name
	name_label.add_theme_font_size_override("font_size", 18)
	inner.add_child(name_label)

	if not map.is_unlocked:
		var lock_label = Label.new()
		lock_label.name = "LockLabel"
		lock_label.text = "🔒 Gesperrt"
		inner.add_child(lock_label)

		var cost_label = Label.new()
		cost_label.name = "CostLabel"
		cost_label.text = "Kosten: " + map.unlock_cost.to_display_string()
		inner.add_child(cost_label)

		var unlock_btn = Button.new()
		unlock_btn.name = "ActionButton"
		unlock_btn.text = "Freischalten"
		unlock_btn.disabled = GameState.credits.is_less_than(map.unlock_cost)
		unlock_btn.pressed.connect(_on_map_unlock_pressed.bind(map.id))
		inner.add_child(unlock_btn)
	else:
		var energy_label = Label.new()
		energy_label.name = "EnergyLabel"
		energy_label.text = "Energie/Tick: " + map.last_total_production.to_display_string()
		inner.add_child(energy_label)

		var research_label = Label.new()
		research_label.name = "ResearchLabel"
		research_label.text = "Forschung/Tick: " + map.last_research_production.to_display_string()
		inner.add_child(research_label)

		var enter_btn = Button.new()
		enter_btn.name = "ActionButton"
		enter_btn.text = "Öffnen"
		enter_btn.pressed.connect(_on_map_card_pressed.bind(map.id))
		inner.add_child(enter_btn)

	return card


func _on_map_unlock_pressed(map_id: String) -> void:
	var map = MapManager.get_map_by_id(map_id)
	if map == null or map.is_unlocked:
		return
	if GameState.credits.is_less_than(map.unlock_cost):
		return
	GameState.credits = GameState.credits.subtract(map.unlock_cost)
	map.is_unlocked = true
	build_map_overview_panel()
	map_overview_panel.visible = true
	show_overlay_event(map.display_name + " freigeschaltet!")


func refresh_map_overview_cards() -> void:
	if map_overview_panel == null or not map_overview_panel.visible:
		return
	var cards = map_overview_card_grid.get_children()
	for i in range(MapManager.maps.size()):
		var map = MapManager.maps[i]
		var inner = cards[i].get_child(0)
		if map.is_unlocked:
			inner.get_node("EnergyLabel").text = "Energie/Tick: " + map.last_total_production.to_display_string()
			inner.get_node("ResearchLabel").text = "Forschung/Tick: " + map.last_research_production.to_display_string()
		else:
			inner.get_node("ActionButton").disabled = GameState.credits.is_less_than(map.unlock_cost)


func _on_map_card_pressed(map_id: String) -> void:
	if not MapManager.set_active_map_by_id(map_id):
		return
	showing_overview = false
	map_overview_panel.visible = false
	get_node("MarginContainer").visible = true
	reactor_grid_container.columns = active_map().grid_width
	build_grid()
	await get_tree().process_frame
	refresh_grid_visuals()
	update_ui(get_total_energy_production(), get_effective_max_storage())


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		get_tree().quit()


func build_grid() -> void:
	for child in reactor_grid_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	var map := active_map()
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
		available_width / map.grid_width,
		available_height / map.grid_height
	)
	for i in range(map.grid_width * map.grid_height):
		var button = Button.new()
		button.custom_minimum_size = Vector2(cell_size, cell_size)
		button.set_meta("grid_index", i)
		button.gui_input.connect(_on_grid_button_input.bind(button))
		button.mouse_entered.connect(_on_grid_button_hover.bind(button))
		button.mouse_exited.connect(_on_grid_button_unhover)
		button.text = ""
		var style = StyleBoxTexture.new()
		match map.grid_terrain[i]:
			MapState.TileType.GRASS:
				style.texture = texture_grass
			MapState.TileType.WATER:
				style.texture = texture_water
			MapState.TileType.SHORE:
				style.texture = get_shore_texture(map, i)
			MapState.TileType.MOUNTAIN:
				style.texture = texture_grass  # TODO: eigenes Mountain-Sprite, sobald vorhanden
		style.texture_margin_left = 0
		style.texture_margin_right = 0
		style.texture_margin_top = 0
		style.texture_margin_bottom = 0
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
		button.add_theme_stylebox_override("disabled", style)
		button.add_theme_stylebox_override("focus", style)
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
		var def = entry[1]
		# Gesperrte Gebäude nicht anzeigen
		if def.required_research != "" and not GameState.is_researched(def.required_research):
			continue
		var btn = Button.new()
		btn.text = entry[0] + "  [" + def.cost.to_display_string() + "]"
		btn.custom_minimum_size = Vector2(200, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(_on_building_select.bind(def))
		btn.mouse_entered.connect(_on_building_hover.bind(def))
		building_list.add_child(btn)


func _on_building_select(def: BuildingDefinition) -> void:
	selected_building = def


func _on_building_hover(def: BuildingDefinition) -> void:
	tooltip_label.text = _build_building_tooltip(def)


func _build_building_tooltip(def: BuildingDefinition) -> String:
	var stats = active_map().get_effective_building_stats(def)
	var lines : Array[String] = []
	lines.append(def.display_name)
	lines.append("Kosten: " + def.cost.to_display_string())

	if stats.has("lifespan"):
		lines.append("Lebensdauer: " + str(stats["lifespan"]) + " Ticks")

	if stats.has("heat_production"):
		lines.append("Hitze-Produktion: " + stats["heat_production"].to_display_string() + "/Tick")
	if stats.has("max_heat"):
		lines.append("Max. Hitze: " + stats["max_heat"].to_display_string())
	if stats.has("heat_transfer_rate"):
		lines.append("Hitze-Transfer: " + str(int(stats["heat_transfer_rate"] * 100)) + "%/Tick")

	if stats.has("water_production"):
		lines.append("Wasser-Produktion: " + stats["water_production"].to_display_string() + "/Tick")
	if stats.has("max_water"):
		lines.append("Max. Wasser: " + stats["max_water"].to_display_string())
	if stats.has("water_transfer_rate"):
		lines.append("Wasser-Transfer: " + str(int(stats["water_transfer_rate"] * 100)) + "%/Tick")
	if stats.has("water_consumption"):
		lines.append("Wasser-Verbrauch: " + stats["water_consumption"].to_display_string() + "/Tick")
	if stats.has("water_boost_amount"):
		lines.append("Wasser-Boost-Kapazität: +" + stats["water_boost_amount"].to_display_string())

	if stats.has("energy_production"):
		lines.append("Energie-Produktion: " + stats["energy_production"].to_display_string() + "/Tick")
	if stats.has("energy_processing"):
		lines.append("Verarbeitung: " + stats["energy_processing"].to_display_string() + "/Tick")
	if stats.has("energy_loss"):
		lines.append("Hitze-Vernichtung: " + str(int(stats["energy_loss"] * 100)) + "%/Tick")

	if stats.has("research_production"):
		lines.append("Forschung: " + stats["research_production"].to_display_string() + "/Tick")

	if stats.has("sell_amount"):
		lines.append("Verkauf: " + stats["sell_amount"].to_display_string() + "/Tick")

	if stats.has("heat_boost"):
		lines.append("Hitze-Boost Nachbarn: +" + str(int(stats["heat_boost"] * 100)) + "%")
	if stats.has("water_boost"):
		lines.append("Wasser-Boost Nachbarn: +" + str(int(stats["water_boost"] * 100)) + "%")
	if stats.has("sell_amount_boost"):
		lines.append("Verkaufs-Boost Nachbarn: +" + str(int(stats["sell_amount_boost"] * 100)) + "%")
	if stats.has("additional_storage"):
		lines.append("Zusatz-Speicher: +" + str(int(stats["additional_storage"] * 100)))

	if def.requires_shore:
		lines.append("⚓ Nur auf Shore bebaubar")

	if not def.tags.is_empty():
		lines.append("Tags: " + ", ".join(def.tags))

	return "\n".join(lines)


func refresh_grid_visuals() -> void:
	var map := active_map()
	var buttons = reactor_grid_container.get_children()
	var fill_bar_types = [
		BuildingDefinition.type.WATER_PUMP,
		BuildingDefinition.type.WATER_PIPE,
		BuildingDefinition.type.HEAT_PIPE,
	]
	for i in range(map.reactor_grid.size()):
		var button = buttons[i]
		var building = map.reactor_grid[i]
		var fill_bar = button.get_node("FillBar")
		var life_bar = button.get_node("LifeBar")

		# Terrain-Textur immer als Hintergrund setzen
		var style = StyleBoxTexture.new()
		match map.grid_terrain[i]:
			MapState.TileType.GRASS:
				style.texture = texture_grass
			MapState.TileType.WATER:
				style.texture = texture_water
			MapState.TileType.SHORE:
				style.texture = get_shore_texture(map, i)
			MapState.TileType.MOUNTAIN:
				style.texture = texture_grass  # TODO: eigenes Mountain-Sprite, sobald vorhanden
		style.texture_margin_left = 0
		style.texture_margin_right = 0
		style.texture_margin_top = 0
		style.texture_margin_bottom = 0
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
		button.add_theme_stylebox_override("disabled", style)
		button.add_theme_stylebox_override("focus", style)

		if building == null:
			button.text = ""
			fill_bar.visible = false
			life_bar.visible = false
			continue
		if building.is_ghost:
			button.modulate = Color(1, 1, 1, 0.3)
			fill_bar.visible = false
			life_bar.visible = false
			continue
		button.modulate = Color(1, 1, 1, 1.0)
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
		if building.definition.lifespan == -1:
			life_bar.visible = false
		else:
			life_bar.visible = true
			var effective_lifespan = map.get_effective_lifespan(building)
			life_bar.value = (1.0 - float(building.age) / float(effective_lifespan)) * 100
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


func _on_grid_button_input(event: InputEvent, button: Button) -> void:
	var index = button.get_meta("grid_index")
	handle_grid_click(event, index)


func _on_grid_button_hover(button: Button) -> void:
	var index = button.get_meta("grid_index")
	var building = active_map().reactor_grid[index]
	if building == null:
		return
	overlay_label.text = _build_building_status(building)


func _on_grid_button_unhover() -> void:
	overlay_label.text = overlay_event_text


func _build_building_status(building: Building) -> String:
	var parts : Array[String] = []
	parts.append(building.definition.display_name)
	if not building.definition.max_heat.is_zero():
		parts.append("Hitze: " + building.current_heat.to_display_string() + " / " + building.definition.max_heat.to_display_string())
	if not building.definition.max_water.is_zero():
		parts.append("Wasser: " + building.current_water.to_display_string() + " / " + building.definition.max_water.to_display_string())
	if building.definition.lifespan != -1:
		var effective_lifespan = active_map().get_effective_lifespan(building)
		var remaining = max(effective_lifespan - building.age, 0)
		parts.append("Restlaufzeit: " + str(remaining) + " Ticks")
	if building.is_ghost:
		parts.append("⚠ Ausgelaufen")
	return " | ".join(parts)


func show_overlay_event(text: String, duration: float = 4.0) -> void:
	overlay_event_text = text
	overlay_label.text = overlay_event_text
	$OverlayEventTimer.stop()
	$OverlayEventTimer.wait_time = duration
	$OverlayEventTimer.start()


func _on_overlay_event_expired() -> void:
	overlay_event_text = ""
	overlay_label.text = ""


func _on_sell_energy_pressed() -> void:
	var map := active_map()
	GameState.credits = GameState.credits.add(map.stored_energy)
	map.stored_energy = BigNumber.from_float(0.0)
	update_ui(get_total_energy_production(), get_effective_max_storage())


func _on_tick_timer_timeout() -> void:
	var tick_results = MapManager.tick_all()
	var map := active_map()
	var result = tick_results.get(map.id, {})
	var total_production = result.get("total_production", BigNumber.from_float(0.0))
	var effective_storage = result.get("effective_storage", BigNumber.from_float(0.0))
	var events = result.get("events", [])
	if not events.is_empty():
		show_overlay_event(", ".join(events))

	if upgrade_panel_instance != null and upgrade_panel_instance.visible:
		upgrade_panel_instance.setup(map.upgrades, GameState.credits, _on_upgrade_pressed, _on_sell_upgrade_pressed, GameState.research)
	if research_panel_instance != null and research_panel_instance.visible:
		research_panel_instance.update_rp(GameState.research_points)
	refresh_map_overview_cards()
	refresh_grid_visuals()
	update_ui(total_production, effective_storage)


func get_total_energy_production() -> BigNumber:
	return active_map().get_total_energy_production()


func get_effective_max_storage() -> BigNumber:
	return active_map().get_effective_max_storage()


func place_building(index: int) -> void:
	if active_map().place_building(index, selected_building):
		refresh_grid_visuals()
		update_ui(get_total_energy_production(), get_effective_max_storage())


func handle_grid_click(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if not upgrade_mode:
					place_building(index)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				remove_building(index)


func remove_building(index: int) -> void:
	if active_map().remove_building(index):
		refresh_grid_visuals()
		update_ui(get_total_energy_production(), get_effective_max_storage())


func _on_sell_upgrade_pressed(upgrade: UpgradeDefinition) -> void:
	active_map().sell_upgrade(upgrade)
	if upgrade_panel_instance != null:
		upgrade_panel_instance.setup(active_map().upgrades, GameState.credits, _on_upgrade_pressed, _on_sell_upgrade_pressed, GameState.research)
	update_ui(get_total_energy_production(), get_effective_max_storage())


func _on_nav_upgrades() -> void:
	if upgrade_panel_instance == null:
		upgrade_panel_instance = upgrade_panel_scene.instantiate()
		get_tree().root.add_child(upgrade_panel_instance)
		upgrade_panel_instance.back_pressed.connect(_on_nav_back)
	upgrade_panel_instance.setup(
		active_map().upgrades,
		GameState.credits,
		_on_upgrade_pressed,
		_on_sell_upgrade_pressed,
		GameState.research
			)
	upgrade_panel_instance.visible = true
	upgrade_panel_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_node("MarginContainer").visible = false


func _on_nav_power_plants() -> void:
	if upgrade_panel_instance != null:
		upgrade_panel_instance.visible = false
	if research_panel_instance != null:
		research_panel_instance.visible = false
	get_node("MarginContainer").visible = false
	showing_overview = true
	map_overview_panel.visible = true
	refresh_map_overview_cards()


func _on_nav_back() -> void:
	if upgrade_panel_instance != null:
		upgrade_panel_instance.visible = false
	if research_panel_instance != null:
		research_panel_instance.visible = false
	if showing_overview:
		map_overview_panel.visible = true
		refresh_map_overview_cards()
	else:
		get_node("MarginContainer").visible = true
		refresh_grid_visuals()
		update_ui(get_total_energy_production(), get_effective_max_storage())


func _on_upgrade_pressed(upgrade: UpgradeDefinition) -> void:
	active_map().purchase_upgrade(upgrade)
	if upgrade_panel_instance != null:
		upgrade_panel_instance.setup(active_map().upgrades, GameState.credits, _on_upgrade_pressed, _on_sell_upgrade_pressed, GameState.research)
	update_ui(get_total_energy_production(), get_effective_max_storage())


func _on_nav_research() -> void:
	if research_panel_instance == null:
		research_panel_instance = research_panel_scene.instantiate()
		get_tree().root.add_child(research_panel_instance)
		research_panel_instance.back_pressed.connect(_on_nav_back)
	research_panel_instance.setup(GameState.research, GameState.research_points, GameState.credits, _on_research_pressed)
	research_panel_instance.visible = true
	research_panel_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	get_node("MarginContainer").visible = false


func _on_research_pressed(item: ResearchDefinition) -> void:
	if not GameState.purchase_research(item):
		return
	tick_timer.wait_time = 1.0 / GameState.ticks_per_second
	research_panel_instance.setup(GameState.research, GameState.research_points, GameState.credits, _on_research_pressed)
	update_ui(get_total_energy_production(), get_effective_max_storage())


func save_game() -> void:
	SaveManager.save()


func load_game() -> void:
	var data = SaveManager.load_save()
	if data.is_empty():
		return

	GameState.credits = BigNumber.from_notation(data["credits"]["m"], data["credits"]["e"])
	GameState.research_points = BigNumber.from_notation(data["research_points"]["m"], data["research_points"]["e"])
	for item in GameState.research:
		if data["research_purchased"].has(item.id):
			item.is_purchased = true
	GameState.ticks_per_second = data.get("ticks_per_second", 1)
	tick_timer.wait_time = 1.0 / GameState.ticks_per_second
	GameState.bonus_ticks = data.get("bonus_ticks", 0)

	for map_data in data.get("maps", []):
		var map = MapManager.get_map_by_id(map_data["id"])
		if map == null:
			map = MapManager.add_map(
				map_data["id"],
				map_data["display_name"],
				map_data["grid_width"],
				map_data["grid_height"],
				map_data.get("terrain_id", "main")
			)
		map.stored_energy = BigNumber.from_notation(map_data["stored_energy"]["m"], map_data["stored_energy"]["e"])
		map.max_storage = BigNumber.from_notation(map_data["max_storage"]["m"], map_data["max_storage"]["e"])
		map.is_unlocked = map_data.get("is_unlocked", true)
		if map_data.has("unlock_cost"):
			map.unlock_cost = BigNumber.from_notation(map_data["unlock_cost"]["m"], map_data["unlock_cost"]["e"])

		for entry in map_data.get("upgrades", []):
			for upgrade in map.upgrades:
				if upgrade.id == entry["id"]:
					upgrade.current_level = entry["level"]
					break

		var grid_data = map_data["grid"]
		for i in range(grid_data.size()):
			if grid_data[i] == null:
				map.reactor_grid[i] = null
			else:
				var entry = grid_data[i]
				var def = BuildingDatabase.get_definition_by_type(entry["type"])
				if def == null:
					continue
				var building = Building.new(def)
				building.age = entry["age"]
				building.is_ghost = entry.get("is_ghost", false)
				building.current_heat = BigNumber.from_notation(entry["current_heat"]["m"], entry["current_heat"]["e"])
				building.current_water = BigNumber.from_notation(entry["current_water"]["m"], entry["current_water"]["e"])
				map.reactor_grid[i] = building

	if data.has("active_map_index") and data["active_map_index"] < MapManager.maps.size():
		MapManager.active_map_index = data["active_map_index"]

	if data.has("timestamp"):
		var elapsed_seconds = Time.get_unix_time_from_system() - data["timestamp"]
		var offline_ticks = int(elapsed_seconds * GameState.ticks_per_second)
		var max_ticks = 12 * 3600 * GameState.ticks_per_second  # 12h Cap
		GameState.bonus_ticks += min(offline_ticks, max_ticks)

	reactor_grid_container.columns = active_map().grid_width
	build_grid()
	await get_tree().process_frame
	refresh_grid_visuals()
	update_ui(get_total_energy_production(), get_effective_max_storage())


func _on_pause_pressed() -> void:
	GameState.is_paused = !GameState.is_paused
	if GameState.is_paused:
		tick_timer.stop()
		pause_button.text = "Resume"
	else:
		tick_timer.start()
		pause_button.text = "Pause"
		if GameState.is_fast:
			tick_timer.wait_time = 1.0 / (GameState.ticks_per_second * 3)
		else:
			tick_timer.wait_time = 1.0 / GameState.ticks_per_second


func _on_fast_pressed() -> void:
	if GameState.bonus_ticks <= 0:
		return
	GameState.bonus_ticks_running = !GameState.bonus_ticks_running
	if GameState.bonus_ticks_running:
		$BonusTimer.start()
		fast_button.add_theme_color_override("font_color", Color.GREEN)
	else:
		$BonusTimer.stop()
		fast_button.remove_theme_color_override("font_color")


func _on_bonus_tick() -> void:
	if GameState.bonus_ticks <= 0:
		GameState.bonus_ticks = 0
		$BonusTimer.stop()
		GameState.bonus_ticks_running = false
		return
	GameState.bonus_ticks -= 1
	_on_tick_timer_timeout()
	update_ui(get_total_energy_production(), get_effective_max_storage())


func _on_auto_rebuild_pressed() -> void:
	GameState.auto_rebuild_enabled = !GameState.auto_rebuild_enabled
	if GameState.auto_rebuild_enabled:
		auto_rebuild_button.text = "AN"
	else:
		auto_rebuild_button.text = "AUS"


func update_ui(total_production: BigNumber, effective_storage: BigNumber) -> void:
	var map := active_map()
	credits_label.text = "Credits: " + GameState.credits.to_display_string()
	energy_label.text = "Energy/Tick: " + total_production.to_display_string()
	stored_label.text = "Stored: " + map.stored_energy.to_display_string() + " / " + effective_storage.to_display_string()
	stored_bar.value = map.stored_energy.divide(effective_storage).to_float() * 100
	research_label.text = "Research Points: " + GameState.research_points.to_display_string()
	bonus_tick_label.text = "Bonus Ticks: " + str(GameState.bonus_ticks)
