class_name ResearchDatabase
extends Node


static func get_all_research() -> Array[ResearchDefinition]:
	var list: Array[ResearchDefinition] = []

	list.append(create_research_center_unlock())
	# --- Einstieg (direkt nach Research Center Kauf) ---
	list.append(create_solar_cell())
	list.append(create_wind_turbine())
	list.append(create_chromatic_boost_1())
	list.append(create_home_office())

	# --- Von Wind Turbine ---
	list.append(create_batteries())
	list.append(create_wind_turbine_manager())

	# --- Von Solar Cell ---
	list.append(create_generator_1())
	list.append(create_isolation())
	list.append(create_solar_cell_manager())
	list.append(create_coal_burner())

	# --- Von Coal Burner ---
	list.append(create_heat_exchanger())
	list.append(create_coal_burner_manager())
	list.append(create_gas_burner())
	list.append(create_small_office())

	# --- Von Gas Burner ---
	list.append(create_heat_sink())
	list.append(create_advanced_research_center())
	list.append(create_gas_burner_manager())
	list.append(create_nuclear_cell())

	# --- Von Heat Sink ---
	list.append(create_boiler_house())

	# --- Von Nuclear Cell ---
	list.append(create_water_pump())
	list.append(create_water_pipe())
	list.append(create_generator_2())
	list.append(create_medium_office())
	list.append(create_nuclear_cell_manager())
	list.append(create_thermonuclear_cell())

	# --- Von Thermonuclear Cell ---
	list.append(create_thermonuclear_cell_manager())
	list.append(create_fusion_cell())

	# --- Von Fusion Cell ---
	list.append(create_generator_3())
	list.append(create_groundwater_pump())
	list.append(create_large_office())
	list.append(create_bank())
	list.append(create_fusion_cell_manager())
	list.append(create_thorium_cell())

	# --- Von Thorium Cell ---
	list.append(create_generator_4())
	list.append(create_heat_inlet())
	list.append(create_heat_outlet())
	list.append(create_huge_office())
	list.append(create_thorium_cell_manager())
	list.append(create_protactium_cell())

	# --- Von Protactium Cell ---
	list.append(create_generator_5())
	list.append(create_circulator())
	list.append(create_super_research_center())
	list.append(create_protactium_cell_manager())
	list.append(create_curium_cell())

	# --- Von Curium Cell ---
	list.append(create_curium_cell_manager())
	list.append(create_balduranium_cell())

	# --- Von Balduranium Cell ---
	list.append(create_balduranium_cell_manager())

	# --- Chromatic Boost Kette ---
	list.append(create_chromatic_boost_2())
	list.append(create_chromatic_boost_3())
	list.append(create_chromatic_boost_4())
	list.append(create_chromatic_boost_5())

	return list


# ==============================================================
# EINSTIEG
# ==============================================================
static func create_research_center_unlock() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "research_center_bought"
	def.display_name = "Research Center"
	def.cost = BigNumber.from_float(100.0)
	def.cost_in_credits = true
	def.requires = []
	return def


static func create_solar_cell() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "solar_cell"
	def.display_name = "Solar Cell"
	def.cost = BigNumber.from_float(2500.0)
	def.requires = ["research_center_bought"]
	return def


static func create_wind_turbine() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "wind_turbine"
	def.display_name = "Wind Turbine"
	def.cost = BigNumber.from_float(100.0)
	def.requires = [""]
	return def


static func create_chromatic_boost_1() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "chromatic_1"
	def.display_name = "Chromatic Boost 1/5"
	def.cost = BigNumber.from_float(10000.0)
	def.requires = ["research_center_bought"]
	return def


static func create_home_office() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "home_office"
	def.display_name = "Home Office"
	def.cost = BigNumber.from_float(250.0)
	def.requires = ["research_center_bought"]
	return def


# ==============================================================
# VON WIND TURBINE
# ==============================================================

static func create_batteries() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "batteries"
	def.display_name = "Batteries"
	def.cost = BigNumber.from_float(250.0)
	def.requires = ["wind_turbine"]
	return def


static func create_wind_turbine_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "wind_turbine_manager"
	def.display_name = "Wind Turbine Manager"
	def.cost = BigNumber.from_float(100.0)
	def.requires = ["research_center_bought"]
	return def


# ==============================================================
# VON SOLAR CELL
# ==============================================================

static func create_generator_1() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "generator_1"
	def.display_name = "Generator 1"
	def.cost = BigNumber.from_float(0.0)
	def.requires = ["solar_cell"]
	return def


static func create_isolation() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "isolation"
	def.display_name = "Isolation"
	def.cost = BigNumber.from_float(12000.0)
	def.requires = ["solar_cell"]
	return def


static func create_solar_cell_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "solar_cell_manager"
	def.display_name = "Solar Cell Manager"
	def.cost = BigNumber.from_float(1000.0)
	def.requires = ["solar_cell"]
	return def


static func create_coal_burner() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "coal_burner"
	def.display_name = "Coal Burner"
	def.cost = BigNumber.from_float(50000.0)
	def.requires = ["solar_cell"]
	return def


# ==============================================================
# VON COAL BURNER
# ==============================================================

static func create_heat_exchanger() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "heat_exchanger"
	def.display_name = "Heat Exchanger"
	def.cost = BigNumber.from_float(150000.0)
	def.requires = ["coal_burner"]
	return def


static func create_coal_burner_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "coal_burner_manager"
	def.display_name = "Coal Burner Manager"
	def.cost = BigNumber.from_float(15000.0)
	def.requires = ["coal_burner"]
	return def


static func create_gas_burner() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "gas_burner"
	def.display_name = "Gas Burner"
	def.cost = BigNumber.from_notation(2.0, 6)
	def.requires = ["coal_burner"]
	return def


static func create_small_office() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "small_office"
	def.display_name = "Small Office"
	def.cost = BigNumber.from_float(50000.0)
	def.requires = ["coal_burner"]
	return def

# ==============================================================
# VON GAS BURNER
# ==============================================================

static func create_heat_sink() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "heat_sink"
	def.display_name = "Heat Sink"
	def.cost = BigNumber.from_notation(1.0, 6)
	def.requires = ["gas_burner"]
	return def


static func create_advanced_research_center() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "advanced_research_center"
	def.display_name = "Advanced Research Center"
	def.cost = BigNumber.from_notation(3.0, 6)
	def.requires = ["gas_burner"]
	return def


static func create_gas_burner_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "gas_burner_manager"
	def.display_name = "Gas Burner Manager"
	def.cost = BigNumber.from_notation(1.0, 6)
	def.requires = ["gas_burner"]
	return def


static func create_nuclear_cell() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "nuclear_cell"
	def.display_name = "Nuclear Cell"
	def.cost = BigNumber.from_notation(2.0, 8)
	def.requires = ["gas_burner"]
	return def


# ==============================================================
# VON HEAT SINK
# ==============================================================

static func create_boiler_house() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "boiler_house"
	def.display_name = "Boiler House"
	def.cost = BigNumber.from_notation(5.0, 6)
	def.requires = ["heat_sink"]
	return def


# ==============================================================
# VON NUCLEAR CELL
# ==============================================================

static func create_water_pump() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "water_pump"
	def.display_name = "Water Pump"
	def.cost = BigNumber.from_notation(6.0, 6)
	def.requires = ["nuclear_cell"]
	return def


static func create_water_pipe() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "water_pipe"
	def.display_name = "Water Pipe"
	def.cost = BigNumber.from_notation(6.0, 6)
	def.requires = ["nuclear_cell"]
	return def


static func create_generator_2() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "generator_2"
	def.display_name = "Generator 2"
	def.cost = BigNumber.from_float(0.0)
	def.requires = ["nuclear_cell"]
	return def


static func create_medium_office() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "medium_office"
	def.display_name = "Medium Office"
	def.cost = BigNumber.from_notation(5.0, 7)
	def.requires = ["nuclear_cell"]
	return def


static func create_nuclear_cell_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "nuclear_cell_manager"
	def.display_name = "Nuclear Cell Manager"
	def.cost = BigNumber.from_notation(1.0, 8)
	def.requires = ["nuclear_cell"]
	return def


static func create_thermonuclear_cell() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "thermonuclear_cell"
	def.display_name = "Thermonuclear Cell"
	def.cost = BigNumber.from_notation(5.0, 9)
	def.requires = ["nuclear_cell"]
	return def


# ==============================================================
# VON THERMONUCLEAR CELL
# ==============================================================

static func create_thermonuclear_cell_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "thermonuclear_cell_manager"
	def.display_name = "Thermonuclear Cell Manager"
	def.cost = BigNumber.from_notation(2.0, 9)
	def.requires = ["thermonuclear_cell"]
	return def


static func create_fusion_cell() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "fusion_cell"
	def.display_name = "Fusion Cell"
	def.cost = BigNumber.from_notation(5.0, 11)
	def.requires = ["thermonuclear_cell"]
	return def


# ==============================================================
# VON FUSION CELL
# ==============================================================

static func create_generator_3() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "generator_3"
	def.display_name = "Generator 3"
	def.cost = BigNumber.from_notation(2.5, 10)
	def.requires = ["fusion_cell"]
	return def


static func create_groundwater_pump() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "groundwater_pump"
	def.display_name = "Groundwater Pump"
	def.cost = BigNumber.from_notation(8.0, 9)
	def.requires = ["fusion_cell"]
	return def


static func create_large_office() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "large_office"
	def.display_name = "Large Office"
	def.cost = BigNumber.from_notation(4.0, 11)
	def.requires = ["fusion_cell"]
	return def


static func create_bank() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "bank"
	def.display_name = "Bank"
	def.cost = BigNumber.from_notation(3.0, 11)
	def.requires = ["fusion_cell"]
	return def


static func create_fusion_cell_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "fusion_cell_manager"
	def.display_name = "Fusion Cell Manager"
	def.cost = BigNumber.from_notation(2.0, 9)
	def.requires = ["fusion_cell"]
	return def


static func create_thorium_cell() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "thorium_cell"
	def.display_name = "Thorium Cell"
	def.cost = BigNumber.from_notation(5.0, 13)
	def.requires = ["fusion_cell"]
	return def


# ==============================================================
# VON THORIUM CELL
# ==============================================================

static func create_generator_4() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "generator_4"
	def.display_name = "Generator 4"
	def.cost = BigNumber.from_notation(6.25, 11)
	def.requires = ["thorium_cell"]
	return def


static func create_heat_inlet() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "heat_inlet"
	def.display_name = "Heat Inlet"
	def.cost = BigNumber.from_notation(2.0, 11)
	def.requires = ["thorium_cell"]
	return def


static func create_heat_outlet() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "heat_outlet"
	def.display_name = "Heat Outlet"
	def.cost = BigNumber.from_notation(2.0, 11)
	def.requires = ["thorium_cell"]
	return def


static func create_huge_office() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "huge_office"
	def.display_name = "Huge Office"
	def.cost = BigNumber.from_notation(4.0, 10)
	def.requires = ["thorium_cell"]
	return def


static func create_thorium_cell_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "thorium_cell_manager"
	def.display_name = "Thorium Cell Manager"
	def.cost = BigNumber.from_notation(8.0, 11)
	def.requires = ["thorium_cell"]
	return def


static func create_protactium_cell() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "protactium_cell"
	def.display_name = "Protactium Cell"
	def.cost = BigNumber.from_notation(5.0, 15)
	def.requires = ["thorium_cell"]
	return def


# ==============================================================
# VON PROTACTIUM CELL
# ==============================================================

static func create_generator_5() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "generator_5"
	def.display_name = "Generator 5"
	def.cost = BigNumber.from_float(0.0)
	def.requires = ["protactium_cell"]
	return def


static func create_circulator() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "circulator"
	def.display_name = "Circulator"
	def.cost = BigNumber.from_notation(2.0, 12)
	def.requires = ["protactium_cell"]
	return def


static func create_super_research_center() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "super_research_center"
	def.display_name = "Super Research Center"
	def.cost = BigNumber.from_notation(2.0, 14)
	def.requires = ["protactium_cell"]
	return def


static func create_protactium_cell_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "protactium_cell_manager"
	def.display_name = "Protactium Cell Manager"
	def.cost = BigNumber.from_notation(8.0, 13)
	def.requires = ["protactium_cell"]
	return def


static func create_curium_cell() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "curium_cell"
	def.display_name = "Curium Cell"
	def.cost = BigNumber.from_notation(5.0, 17)
	def.requires = ["protactium_cell"]
	return def


# ==============================================================
# VON CURIUM CELL
# ==============================================================

static func create_curium_cell_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "curium_cell_manager"
	def.display_name = "Curium Cell Manager"
	def.cost = BigNumber.from_notation(8.0, 15)
	def.requires = ["curium_cell"]
	return def


static func create_balduranium_cell() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "balduranium_cell"
	def.display_name = "Balduranium Cell"
	def.cost = BigNumber.from_notation(5.0, 18)
	def.requires = ["curium_cell"]
	return def


# ==============================================================
# VON BALDURANIUM CELL
# ==============================================================

static func create_balduranium_cell_manager() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "balduranium_cell_manager"
	def.display_name = "Balduranium Cell Manager"
	def.cost = BigNumber.from_notation(8.0, 18)
	def.requires = ["balduranium_cell"]
	return def


# ==============================================================
# CHROMATIC BOOST KETTE
# ==============================================================

static func create_chromatic_boost_2() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "chromatic_2"
	def.display_name = "Chromatic Boost 2/5"
	def.cost = BigNumber.from_notation(1.0, 7)
	def.requires = ["chromatic_1"]
	return def


static func create_chromatic_boost_3() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "chromatic_3"
	def.display_name = "Chromatic Boost 3/5"
	def.cost = BigNumber.from_notation(1.0, 10)
	def.requires = ["chromatic_2"]
	return def


static func create_chromatic_boost_4() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "chromatic_4"
	def.display_name = "Chromatic Boost 4/5"
	def.cost = BigNumber.from_notation(1.0, 13)
	def.requires = ["chromatic_3"]
	return def


static func create_chromatic_boost_5() -> ResearchDefinition:
	var def = ResearchDefinition.new()
	def.id = "chromatic_5"
	def.display_name = "Chromatic Boost 5/5"
	def.cost = BigNumber.from_notation(1.0, 16)
	def.requires = ["chromatic_4"]
	return def
