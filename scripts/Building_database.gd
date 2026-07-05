extends RefCounted
class_name BuildingDatabase

#
# REAKTOREN
#

static func create_solar_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.SOLAR_CELL
	def.display_name = "Solar Cell"
	def.cost = BigNumber.from_float(100.0)
	def.heat_production = BigNumber.from_float(3.0)
	def.max_heat = BigNumber.from_float(3.0)
	def.lifespan = 100
	def.required_research = "solar_cell"
	def.manager_research_id = "solar_cell_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_coal_burner() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.COAL_BURNER
	def.display_name = "Coal Burner"
	def.cost = BigNumber.from_float(1000.0)
	def.heat_production = BigNumber.from_float(380.0)
	def.max_heat = BigNumber.from_float(380.0)
	def.lifespan = 400
	def.required_research = "coal_burner"
	def.manager_research_id = "coal_burner_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_gas_burner() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GAS_BURNER
	def.display_name = "Gas Burner"
	def.cost = BigNumber.from_notation(4.0, 7)
	def.heat_production = BigNumber.from_float(75000.0)
	def.max_heat = BigNumber.from_float(75000.0)
	def.lifespan = 800
	def.required_research = "gas_burner"
	def.manager_research_id = "gas_burner_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_nuclear_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.NUCLEAR_CELL
	def.display_name = "Nuclear Cell"
	def.cost = BigNumber.from_notation(5.0, 8)
	def.heat_production = BigNumber.from_notation(1.2, 6)
	def.max_heat = BigNumber.from_notation(1.2, 6)
	def.lifespan = 800
	def.required_research = "nuclear_cell"
	def.manager_research_id = "nuclear_cell_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_thermonuclear_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.THERMONUCLEAR_CELL
	def.display_name = "Thermonuclear Cell"
	def.cost = BigNumber.from_notation(2.0, 10)
	def.heat_production = BigNumber.from_notation(5.0, 7)
	def.max_heat = BigNumber.from_notation(5.0, 7)
	def.lifespan = 800
	def.required_research = "thermonuclear_cell"
	def.manager_research_id = "thermonuclear_cell_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_fusion_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.FUSION_CELL
	def.display_name = "Fusion Cell"
	def.cost = BigNumber.from_notation(8.0, 11)
	def.heat_production = BigNumber.from_notation(2.5, 9)
	def.max_heat = BigNumber.from_notation(2.5, 9)
	def.lifespan = 800
	def.required_research = "fusion_cell"
	def.manager_research_id = "fusion_cell_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_thorium_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.THORIUM_CELL
	def.display_name = "Thorium Cell"
	def.cost = BigNumber.from_notation(8.0, 11)
	def.heat_production = BigNumber.from_notation(2.5, 9)
	def.max_heat = BigNumber.from_notation(2.5, 9)
	def.lifespan = 800
	def.required_research = "thorium_cell"
	def.manager_research_id = "thorium_cell_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_protactium_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.PROTACTIUM_CELL
	def.display_name = "Protactium Cell"
	def.cost = BigNumber.from_notation(8.0, 11)
	def.heat_production = BigNumber.from_notation(2.5, 9)
	def.max_heat = BigNumber.from_notation(2.5, 9)
	def.lifespan = 800
	def.required_research = "protactium_cell"
	def.manager_research_id = "protactium_cell_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_curium_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.CURIUM_CELL
	def.display_name = "Curium Cell"
	def.cost = BigNumber.from_notation(8.0, 11)
	def.heat_production = BigNumber.from_notation(2.5, 9)
	def.max_heat = BigNumber.from_notation(2.5, 9)
	def.lifespan = 800
	def.required_research = "curium_cell"
	def.manager_research_id = "curium_cell_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_baldranium_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.BALDRANIUM_CELL
	def.display_name = "Baldranium Cell"
	def.cost = BigNumber.from_notation(8.0, 11)
	def.heat_production = BigNumber.from_notation(2.5, 9)
	def.max_heat = BigNumber.from_notation(2.5, 9)
	def.lifespan = 800
	def.required_research = "balduranium_cell"
	def.manager_research_id = "balduranium_cell_manager"
	def.tags = ["heat_producer", "water_immune"]
	return def

#
# GENERATOREN
#

static func create_wind_turbine() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WIND_TURBINE
	def.display_name = "Wind Turbine"
	def.cost = BigNumber.from_float(1.0)
	def.energy_production = BigNumber.from_float(0.15)
	def.lifespan = 10
	def.required_research = ""
	def.manager_research_id = "wind_turbine_manager"
	def.tags = ["energy_producer", "heat_immune", "water_immune"]
	return def

static func create_basic_generator() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.BASIC_GENERATOR
	def.display_name = "Basic Generator"
	def.cost = BigNumber.from_float(500.0)
	def.max_heat = BigNumber.from_float(25.0)
	def.energy_processing = BigNumber.from_float(3.0)
	def.required_research = "generator_1"
	def.tags = ["heat_consumer", "energy_producer", "water_immune"]
	return def

static func create_generator2() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR2
	def.display_name = "Generator 2"
	def.cost = BigNumber.from_notation(2.5, 6)
	def.max_heat = BigNumber.from_float(150.0)
	def.energy_processing = BigNumber.from_float(9.0)
	def.max_water = BigNumber.from_float(5000.0)
	def.water_consumption = BigNumber.from_float(1.0)
	def.water_boost_amount = BigNumber.from_float(100.0)
	def.required_research = "generator_2"
	def.tags = ["heat_consumer", "energy_producer", "water_consumer"]
	return def

static func create_generator3() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR3
	def.display_name = "Generator 3"
	def.cost = BigNumber.from_notation(1.0, 13)
	def.max_heat = BigNumber.from_float(900.0)
	def.energy_processing = BigNumber.from_float(32.0)
	def.max_water = BigNumber.from_float(8000.0)
	def.water_consumption = BigNumber.from_float(1.0)
	def.water_boost_amount = BigNumber.from_float(200.0)
	def.required_research = "generator_3"
	def.tags = ["heat_consumer", "energy_producer", "water_consumer"]
	return def

static func create_generator4() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR4
	def.display_name = "Generator 4"
	def.cost = BigNumber.from_notation(5.0, 16)
	def.max_heat = BigNumber.from_float(2200.0)
	def.energy_processing = BigNumber.from_float(96.0)
	def.max_water = BigNumber.from_float(22000.0)
	def.water_consumption = BigNumber.from_float(1.0)
	def.water_boost_amount = BigNumber.from_float(400.0)
	def.required_research = "generator_4"
	def.tags = ["heat_consumer", "energy_producer", "water_consumer"]
	return def

static func create_generator5() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR5
	def.display_name = "Generator 5"
	def.cost = BigNumber.from_notation(1.25, 16)
	def.max_heat = BigNumber.from_float(4400.0)
	def.energy_processing = BigNumber.from_float(288.0)
	def.max_water = BigNumber.from_float(22000.0)
	def.water_consumption = BigNumber.from_float(1.0)
	def.water_boost_amount = BigNumber.from_float(800.0)
	def.required_research = "generator_5"
	def.tags = ["heat_consumer", "energy_producer", "water_consumer"]
	return def

#
# HITZE
#

static func create_heat_pipe() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HEAT_PIPE
	def.display_name = "Heat Pipe"
	def.cost = BigNumber.from_notation(1.5, 12)
	def.max_heat = BigNumber.from_float(15000.0)
	def.heat_transfer_rate = 0.3
	def.required_research = "heat_exchanger"
	def.tags = ["heat_consumer", "heat_transfer", "water_immune"]
	return def

static func create_heat_sink() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HEAT_SINK
	def.display_name = "Heat Sink"
	def.cost = BigNumber.from_notation(2.5, 9)
	def.max_heat = BigNumber.from_notation(1.0, 10)
	def.energy_loss = 0.05
	def.required_research = "heat_sink"
	def.tags = ["heat_consumer", "heat_sink", "water_immune"]
	return def

static func create_heat_inlet() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HEAT_INLET
	def.display_name = "Heat Inlet"
	def.cost = BigNumber.from_notation(2.5, 9)
	def.max_heat = BigNumber.from_notation(1.0, 10)
	def.required_research = "heat_inlet"
	def.tags = ["heat_consumer", "water_immune"]
	return def

static func create_heat_outlet() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HEAT_OUTLET
	def.display_name = "Heat Outlet"
	def.cost = BigNumber.from_notation(2.5, 9)
	def.max_heat = BigNumber.from_notation(1.0, 10)
	def.required_research = "heat_outlet"
	def.tags = ["heat_consumer", "water_immune"]
	return def

#
# WASSER
#

static func create_water_pump() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WATER_PUMP
	def.display_name = "Water Pump"
	def.cost = BigNumber.from_notation(5.0, 12)
	def.water_production = BigNumber.from_float(25000.0)
	def.max_water = BigNumber.from_float(150000.0)
	def.water_transfer_rate = 1.0
	def.required_research = "water_pump"
	def.tags = ["water_producer", "heat_immune"]
	return def

static func create_ground_water_pump() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.G_WATER_PUMP
	def.display_name = "Ground Water Pump"
	def.cost = BigNumber.from_notation(4.0, 13)
	def.water_production = BigNumber.from_float(67500.0)
	def.max_water = BigNumber.from_float(250000.0)
	def.water_transfer_rate = 1.0
	def.required_research = "groundwater_pump"
	def.tags = ["water_producer", "heat_immune"]
	return def

static func create_water_pipe() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WATER_PIPE
	def.display_name = "Water Pipe"
	def.cost = BigNumber.from_notation(1.5, 12)
	def.water_transfer_rate = 0.5
	def.max_water = BigNumber.from_float(150000.0)
	def.required_research = "water_pipe"
	def.tags = ["water_transfer", "heat_immune"]
	return def

#
# AUTO SELLER
#

static func create_home_office() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HOME_OFFICE
	def.display_name = "Home Office"
	def.cost = BigNumber.from_float(50.0)
	def.max_heat = BigNumber.from_float(10.0)
	def.sell_amount = BigNumber.from_float(5.0)
	def.required_research = "home_office"
	def.tags = ["energy_seller", "water_immune"]
	return def

static func create_small_office() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.SMALL_OFFICE
	def.display_name = "Small Office"
	def.cost = BigNumber.from_float(100000.0)
	def.max_heat = BigNumber.from_float(10.0)
	def.sell_amount = BigNumber.from_float(100.0)
	def.required_research = "small_office"
	def.tags = ["energy_seller", "water_immune"]
	return def

static func create_medium_office() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.MEDIUM_OFFICE
	def.display_name = "Medium Office"
	def.cost = BigNumber.from_notation(8.0, 8)
	def.max_heat = BigNumber.from_float(10.0)
	def.sell_amount = BigNumber.from_float(2500.0)
	def.required_research = "medium_office"
	def.tags = ["energy_seller", "water_immune"]
	return def

static func create_large_office() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.LARGE_OFFICE
	def.display_name = "Large Office"
	def.cost = BigNumber.from_notation(1.0, 10)
	def.max_heat = BigNumber.from_float(10.0)
	def.sell_amount = BigNumber.from_float(60000.0)
	def.required_research = "large_office"
	def.tags = ["energy_seller", "water_immune"]
	return def

static func create_huge_office() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HUGE_OFFICE
	def.display_name = "Huge Office"
	def.cost = BigNumber.from_notation(1.0, 15)
	def.max_heat = BigNumber.from_float(10.0)
	def.sell_amount = BigNumber.from_float(900000.0)
	def.required_research = "huge_office"
	def.tags = ["energy_seller", "water_immune"]
	return def

static func create_boiler_house() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.BOILER_HOUSE
	def.display_name = "Boiler House"
	def.cost = BigNumber.from_notation(8.0, 8)
	def.max_heat = BigNumber.from_float(10.0)
	def.sell_amount = BigNumber.from_float(2500.0)
	def.required_research = "boiler_house"
	def.tags = ["energy_seller", "water_immune"]
	return def

#
# RESEARCH
#

static func create_research_center() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.RESEARCH_CENTER
	def.display_name = "Research Center"
	def.cost = BigNumber.from_float(100.0)
	def.max_heat = BigNumber.from_float(10.0)
	def.research_production = BigNumber.from_float(1.0)
	def.required_research = "research_center_bought"
	def.tags = ["research_producer", "water_immune"]
	return def

static func create_advanced_research_center() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.ADVANCED_RESEARCH_CENTER
	def.display_name = "Advanced Research Center"
	def.cost = BigNumber.from_notation(1.0, 7)
	def.max_heat = BigNumber.from_float(10.0)
	def.research_production = BigNumber.from_float(8.0)
	def.required_research = "advanced_research_center"
	def.tags = ["research_producer", "water_immune"]
	return def

static func create_super_research_center() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.SUPER_RESEARCH_CENTER
	def.display_name = "Super Research Center"
	def.cost = BigNumber.from_notation(2.52, 16)
	def.max_heat = BigNumber.from_float(10.0)
	def.research_production = BigNumber.from_float(40.0)
	def.required_research = "super_research_center"
	def.tags = ["research_producer", "water_immune"]
	return def

#
# BOOSTER
#

static func create_isolation() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.ISOLATION
	def.display_name = "Isolation"
	def.cost = BigNumber.from_float(100.0)
	def.heat_boost = 0.05
	def.required_research = "isolation"
	def.tags = ["booster", "water_immune", "heat_immune"]
	return def

static func create_circulator() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.CIRCULATOR
	def.display_name = "Circulator"
	def.cost = BigNumber.from_float(100.0)
	def.water_boost = 0.9
	def.required_research = "circulator"
	def.tags = ["booster", "water_immune", "heat_immune"]
	return def

static func create_bank() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.BANK
	def.display_name = "Bank"
	def.cost = BigNumber.from_float(100.0)
	def.max_heat = BigNumber.from_float(10.0)
	def.sell_amount_boost = 2.5
	def.required_research = "bank"
	def.tags = ["booster", "water_immune"]
	return def

static func create_battery() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.BATTERY
	def.display_name = "Battery"
	def.cost = BigNumber.from_float(100.0)
	def.additional_storage = 1.0
	def.required_research = "batteries"
	def.tags = ["booster", "water_immune", "heat_immune"]
	return def


static func get_definition_by_type(t: BuildingDefinition.type) -> BuildingDefinition:
	match t:
		BuildingDefinition.type.SOLAR_CELL:
			return create_solar_cell()
		BuildingDefinition.type.COAL_BURNER:
			return create_coal_burner()
		BuildingDefinition.type.GAS_BURNER:
			return create_gas_burner()
		BuildingDefinition.type.NUCLEAR_CELL:
			return create_nuclear_cell()
		BuildingDefinition.type.THERMONUCLEAR_CELL:
			return create_thermonuclear_cell()
		BuildingDefinition.type.FUSION_CELL:
			return create_fusion_cell()
		BuildingDefinition.type.THORIUM_CELL:
			return create_thorium_cell()
		BuildingDefinition.type.PROTACTIUM_CELL:
			return create_protactium_cell()
		BuildingDefinition.type.CURIUM_CELL:
			return create_curium_cell()
		BuildingDefinition.type.BALDRANIUM_CELL:
			return create_baldranium_cell()
		BuildingDefinition.type.WIND_TURBINE:
			return create_wind_turbine()
		BuildingDefinition.type.BASIC_GENERATOR:
			return create_basic_generator()
		BuildingDefinition.type.GENERATOR2:
			return create_generator2()
		BuildingDefinition.type.GENERATOR3:
			return create_generator3()
		BuildingDefinition.type.GENERATOR4:
			return create_generator4()
		BuildingDefinition.type.GENERATOR5:
			return create_generator5()
		BuildingDefinition.type.WATER_PUMP:
			return create_water_pump()
		BuildingDefinition.type.G_WATER_PUMP:
			return create_ground_water_pump()
		BuildingDefinition.type.WATER_PIPE:
			return create_water_pipe()
		BuildingDefinition.type.HEAT_PIPE:
			return create_heat_pipe()
		BuildingDefinition.type.HEAT_SINK:
			return create_heat_sink()
		BuildingDefinition.type.HEAT_INLET:
			return create_heat_inlet()
		BuildingDefinition.type.HEAT_OUTLET:
			return create_heat_outlet()
		BuildingDefinition.type.HOME_OFFICE:
			return create_home_office()
		BuildingDefinition.type.SMALL_OFFICE:
			return create_small_office()
		BuildingDefinition.type.MEDIUM_OFFICE:
			return create_medium_office()
		BuildingDefinition.type.LARGE_OFFICE:
			return create_large_office()
		BuildingDefinition.type.HUGE_OFFICE:
			return create_huge_office()
		BuildingDefinition.type.BOILER_HOUSE:
			return create_boiler_house()
		BuildingDefinition.type.RESEARCH_CENTER:
			return create_research_center()
		BuildingDefinition.type.ADVANCED_RESEARCH_CENTER:
			return create_advanced_research_center()
		BuildingDefinition.type.SUPER_RESEARCH_CENTER:
			return create_super_research_center()
		BuildingDefinition.type.ISOLATION:
			return create_isolation()
		BuildingDefinition.type.CIRCULATOR:
			return create_circulator()
		BuildingDefinition.type.BANK:
			return create_bank()
		BuildingDefinition.type.BATTERY:
			return create_battery()
		_:
			return null
