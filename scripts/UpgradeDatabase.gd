extends RefCounted
class_name UpgradeDatabase

static func get_all_upgrades() -> Array[UpgradeDefinition]:
	return [
		# Offices
		create_office_sell_power(),
		create_research_center_production(),
		create_boiler_house_sell(),
		# Generatoren
		create_generator_max_heat(),
		create_generator_effectiveness(),
		create_generator_max_water(),
		# Hitze
		create_heat_exchanger_max_heat(),
		create_heat_sink_max_heat(),
		create_heat_pipe_transfer(),
		create_heat_inlet_outlet_max_heat(),
		# Wasser
		create_water_pump_production(),
		create_ground_water_pump_production(),
		create_water_pipe_transfer(),
		create_water_elem_max_water(),
		# Booster
		create_power_battery_size(),
		create_isolation_effectiveness(),
		create_circulator_water_buff(),
		# Reaktoren
		create_solar_cell_heat(),
		create_solar_cell_lifetime(),
		create_wind_turbine_heat(),
		create_wind_turbine_lifetime(),
		create_coal_burner_heat(),
		create_coal_burner_lifetime(),
		create_gas_burner_heat(),
		create_gas_burner_lifetime(),
		create_nuclear_cell_heat(),
		create_nuclear_cell_lifetime(),
		create_thermonuclear_cell_heat(),
		create_thermonuclear_cell_lifetime(),
		create_fusion_cell_heat(),
		create_fusion_cell_lifetime(),
		create_thorium_cell_heat(),
		create_thorium_cell_lifetime(),
		create_protactium_cell_heat(),
		create_protactium_cell_lifetime(),
		create_curium_cell_heat(),
		create_curium_cell_lifetime(),
		create_balduranium_cell_heat(),
		create_balduranium_cell_lifetime(),
	]

# ─── OFFICES ───────────────────────────────────────────────

static func create_office_sell_power() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "office_sell_power"
	def.display_name = "Office Sell Power"
	def.description = "Increases power sell amount by 100%"
	def.base_cost = BigNumber.from_float(1000.0)
	def.cost_multiplier = 10.0
	def.target = UpgradeDefinition.target_type.TAG
	def.target_tag = "energy_seller"
	def.stat = UpgradeDefinition.stat_type.SELL_AMOUNT
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "home_office"
	return def

static func create_research_center_production() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "research_center_production"
	def.display_name = "Research Center"
	def.description = "Increases research production by 25%"
	def.base_cost = BigNumber.from_float(25000.0)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.RESEARCH_CENTER
	def.stat = UpgradeDefinition.stat_type.RESEARCH_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "research_center_bought"
	return def

static func create_boiler_house_sell() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "boiler_house_sell"
	def.display_name = "Boiler House Sell Amount"
	def.description = "Increases heat sell amount by 40%"
	def.base_cost = BigNumber.from_notation(5.0, 7)
	def.cost_multiplier = 2.8
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.BOILER_HOUSE
	def.stat = UpgradeDefinition.stat_type.SELL_AMOUNT
	def.multiplier = 0.4
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "boiler_house"
	return def

# ─── GENERATOREN ───────────────────────────────────────────

static func create_generator_max_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "generator_max_heat"
	def.display_name = "Generator Max Heat"
	def.description = "Increases max heat by 100%"
	def.base_cost = BigNumber.from_float(1000.0)
	def.cost_multiplier = 3.7
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.BASIC_GENERATOR
	def.stat = UpgradeDefinition.stat_type.MAX_HEAT
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "generator_1"
	return def

static func create_generator_effectiveness() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "generator_effectiveness"
	def.display_name = "Generator Effectiveness"
	def.description = "Increases heat to power conversion by 25%"
	def.base_cost = BigNumber.from_float(400.0)
	def.cost_multiplier = 1.5
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.BASIC_GENERATOR
	def.stat = UpgradeDefinition.stat_type.ENERGY_PROCESSING
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "generator_1"
	return def

static func create_generator_max_water() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "generator_max_water"
	def.display_name = "Generators Max Water"
	def.description = "Increases max water by 25%"
	def.base_cost = BigNumber.from_notation(2.0, 10)
	def.cost_multiplier = 1.45
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.BASIC_GENERATOR
	def.stat = UpgradeDefinition.stat_type.MAX_WATER
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "generator_2"
	return def

# ─── HITZE ─────────────────────────────────────────────────

static func create_heat_exchanger_max_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "heat_exchanger_max_heat"
	def.display_name = "Heat Exchanger Max Heat"
	def.description = "Increases max heat by 100%"
	def.base_cost = BigNumber.from_notation(2.0, 6)
	def.cost_multiplier = 2.6
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.HEAT_PIPE
	def.stat = UpgradeDefinition.stat_type.MAX_HEAT
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "heat_exchanger"
	return def

static func create_heat_sink_max_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "heat_sink_max_heat"
	def.display_name = "Heat Sink Max Heat"
	def.description = "Increases max heat by 100%"
	def.base_cost = BigNumber.from_notation(2.0, 7)
	def.cost_multiplier = 4.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.HEAT_SINK
	def.stat = UpgradeDefinition.stat_type.MAX_HEAT
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "heat_sink"
	return def

static func create_heat_pipe_transfer() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "heat_pipe_transfer"
	def.display_name = "Heat Pipe Max Transfer"
	def.description = "Increases max heat transfer by additional 10%"
	def.base_cost = BigNumber.from_float(250000.0)
	def.cost_multiplier = 10.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.HEAT_PIPE
	def.stat = UpgradeDefinition.stat_type.HEAT_TRANSFER_RATE
	def.multiplier = 0.1
	def.mode = UpgradeDefinition.upgrade_mode.ADDITIVE
	def.required_research = "heat_exchanger"
	return def

static func create_heat_inlet_outlet_max_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "heat_inlet_outlet_max_heat"
	def.display_name = "Heat Inlet & Outlet Max Heat"
	def.description = "Increases max heat by 100%"
	def.base_cost = BigNumber.from_notation(1.0, 15)
	def.cost_multiplier = 2.7
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.HEAT_INLET
	def.stat = UpgradeDefinition.stat_type.MAX_HEAT
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "heat_inlet"
	return def

# ─── WASSER ────────────────────────────────────────────────

static func create_water_pump_production() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "water_pump_production"
	def.display_name = "Water Pump Production"
	def.description = "Increases water production by 50%"
	def.base_cost = BigNumber.from_notation(8.0, 10)
	def.cost_multiplier = 1.98
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.WATER_PUMP
	def.stat = UpgradeDefinition.stat_type.WATER_PRODUCTION
	def.multiplier = 0.5
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "water_pump"
	return def

static func create_ground_water_pump_production() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "ground_water_pump_production"
	def.display_name = "Groundwater Pump Production"
	def.description = "Increases water production by 50%"
	def.base_cost = BigNumber.from_notation(6.4, 11)
	def.cost_multiplier = 2.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.G_WATER_PUMP
	def.stat = UpgradeDefinition.stat_type.WATER_PRODUCTION
	def.multiplier = 0.5
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "groundwater_pump"
	return def

static func create_water_pipe_transfer() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "water_pipe_transfer"
	def.display_name = "Water Pipe Max Transfer"
	def.description = "Increases max water transfer by additional 10%"
	def.base_cost = BigNumber.from_float(100000.0)
	def.cost_multiplier = 10.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.WATER_PIPE
	def.stat = UpgradeDefinition.stat_type.WATER_TRANSFER_RATE
	def.multiplier = 0.1
	def.mode = UpgradeDefinition.upgrade_mode.ADDITIVE
	def.required_research = "water_pipe"
	return def

static func create_water_elem_max_water() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "water_elem_max_water"
	def.display_name = "Water Elem. Max Water"
	def.description = "Increases max water by 50%"
	def.base_cost = BigNumber.from_notation(3.0, 10)
	def.cost_multiplier = 2.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.WATER_PUMP
	def.stat = UpgradeDefinition.stat_type.MAX_WATER
	def.multiplier = 0.5
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "water_pump"
	return def

# ─── BOOSTER ───────────────────────────────────────────────

static func create_power_battery_size() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "power_battery_size"
	def.display_name = "Power Battery Size"
	def.description = "Increases max stored from batteries by 100%"
	def.base_cost = BigNumber.from_float(300.0)
	def.cost_multiplier = 2.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.BATTERY
	def.stat = UpgradeDefinition.stat_type.ADDITIONAL_STORAGE
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "batteries"
	return def

static func create_isolation_effectiveness() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "isolation_effectiveness"
	def.display_name = "Isolation Effectiveness"
	def.description = "Increases isolation effectiveness by additional 5%"
	def.base_cost = BigNumber.from_float(50000.0)
	def.cost_multiplier = 10.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.ISOLATION
	def.stat = UpgradeDefinition.stat_type.HEAT_BOOST
	def.multiplier = 0.05
	def.mode = UpgradeDefinition.upgrade_mode.ADDITIVE
	def.required_research = "isolation"
	return def

static func create_circulator_water_buff() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "circulator_water_buff"
	def.display_name = "Circulator Water Buff"
	def.description = "Increases max water of surrounding generators by additional 25%"
	def.base_cost = BigNumber.from_notation(1.0, 18)
	def.cost_multiplier = 2.1
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.CIRCULATOR
	def.stat = UpgradeDefinition.stat_type.WATER_BOOST
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.ADDITIVE
	def.required_research = "circulator"
	return def

# ─── REAKTOREN ─────────────────────────────────────────────

static func create_solar_cell_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "solar_cell_heat"
	def.display_name = "Solar Cells"
	def.description = "Increases heat production by 50%"
	def.base_cost = BigNumber.from_float(1000.0)
	def.cost_multiplier = 3.165
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.SOLAR_CELL
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.5
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "solar_cell"
	return def

static func create_solar_cell_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "solar_cell_lifetime"
	def.display_name = "Solar Cells Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_float(10000.0)
	def.cost_multiplier = 10.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.SOLAR_CELL
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "solar_cell"
	return def

static func create_wind_turbine_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "wind_turbine_heat"
	def.display_name = "Wind Turbine"
	def.description = "Increases energy production by 50%"
	def.base_cost = BigNumber.from_float(250.0)
	def.cost_multiplier = 2.8
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.WIND_TURBINE
	def.stat = UpgradeDefinition.stat_type.ENERGY_PRODUCTION
	def.multiplier = 0.5
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = ""
	return def

static func create_wind_turbine_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "wind_turbine_lifetime"
	def.display_name = "Wind Turbine Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_float(15.0)
	def.cost_multiplier = 12.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.WIND_TURBINE
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = ""
	return def

static func create_coal_burner_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "coal_burner_heat"
	def.display_name = "Coal Burner"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_float(125000.0)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.COAL_BURNER
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "coal_burner"
	return def

static func create_coal_burner_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "coal_burner_lifetime"
	def.display_name = "Coal Burner Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(5.0, 6)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.COAL_BURNER
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "coal_burner"
	return def

static func create_gas_burner_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "gas_burner_heat"
	def.display_name = "Gas Burner"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_notation(8.0, 7)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.GAS_BURNER
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "gas_burner"
	return def

static func create_gas_burner_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "gas_burner_lifetime"
	def.display_name = "Gas Burner Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(2.5, 8)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.GAS_BURNER
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "gas_burner"
	return def

static func create_nuclear_cell_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "nuclear_cell_heat"
	def.display_name = "Nuclear Cell"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_notation(1.0, 10)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.NUCLEAR_CELL
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "nuclear_cell"
	return def

static func create_nuclear_cell_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "nuclear_cell_lifetime"
	def.display_name = "Nuclear Cell Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(5.0, 10)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.NUCLEAR_CELL
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "nuclear_cell"
	return def

static func create_thermonuclear_cell_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "thermonuclear_cell_heat"
	def.display_name = "Thermonuclear Cell"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_notation(1.0, 11)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.THERMONUCLEAR_CELL
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "thermonuclear_cell"
	return def

static func create_thermonuclear_cell_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "thermonuclear_cell_lifetime"
	def.display_name = "Thermonuclear Cell Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(5.0, 11)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.THERMONUCLEAR_CELL
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "thermonuclear_cell"
	return def

static func create_fusion_cell_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "fusion_cell_heat"
	def.display_name = "Fusion Cell"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_notation(1.0, 14)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.FUSION_CELL
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "fusion_cell"
	return def

static func create_fusion_cell_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "fusion_cell_lifetime"
	def.display_name = "Fusion Cell Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(5.0, 14)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.FUSION_CELL
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "fusion_cell"
	return def

static func create_thorium_cell_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "thorium_cell_heat"
	def.display_name = "Thorium Cell"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_notation(1.0, 16)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.THORIUM_CELL
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "thorium_cell"
	return def

static func create_thorium_cell_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "thorium_cell_lifetime"
	def.display_name = "Thorium Cell Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(5.0, 16)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.THORIUM_CELL
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "thorium_cell"
	return def

static func create_protactium_cell_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "protactium_cell_heat"
	def.display_name = "Protactium Cell"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_notation(1.0, 18)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.PROTACTIUM_CELL
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "protactium_cell"
	return def

static func create_protactium_cell_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "protactium_cell_lifetime"
	def.display_name = "Protactium Cell Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(5.0, 18)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.PROTACTIUM_CELL
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "protactium_cell"
	return def

static func create_curium_cell_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "curium_cell_heat"
	def.display_name = "Curium Cell"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_notation(1.0, 20)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.CURIUM_CELL
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "curium_cell"
	return def

static func create_curium_cell_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "curium_cell_lifetime"
	def.display_name = "Curium Cell Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(5.0, 20)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.CURIUM_CELL
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "curium_cell"
	return def

static func create_balduranium_cell_heat() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "balduranium_cell_heat"
	def.display_name = "Balduranium Cell"
	def.description = "Increases heat production by 25%"
	def.base_cost = BigNumber.from_notation(1.0, 22)
	def.cost_multiplier = 1.78
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.BALDRANIUM_CELL
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "balduranium_cell"
	return def

static func create_balduranium_cell_lifetime() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "balduranium_cell_lifetime"
	def.display_name = "Balduranium Cell Lifetime"
	def.description = "Increases lifetime by 100%"
	def.base_cost = BigNumber.from_notation(5.0, 22)
	def.cost_multiplier = 8.0
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.BALDRANIUM_CELL
	def.stat = UpgradeDefinition.stat_type.LIFESPAN
	def.multiplier = 1.0
	def.mode = UpgradeDefinition.upgrade_mode.MULTIPLICATIVE
	def.required_research = "balduranium_cell"
	return def
