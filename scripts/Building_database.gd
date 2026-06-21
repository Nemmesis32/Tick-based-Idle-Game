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
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_gas_burner() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GAS_BURNER
	def.display_name = "Gas Burner"
	def.cost = BigNumber.from_float(40000000.0)
	def.heat_production = BigNumber.from_float(75000.0)
	def.max_heat = BigNumber.from_float(75000.0)
	def.lifespan = 800
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_nuclear_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.NUCLEAR_CELL
	def.display_name = "Nuclear Cell"
	def.cost = BigNumber.from_float(500000000.0)
	def.heat_production = BigNumber.from_float(1200000.0)
	def.max_heat = BigNumber.from_float(1200000.0)
	def.lifespan = 800
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_thermonuclear_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.THERMONUCLEAR_CELL
	def.display_name = "Thermonuclear Cell"
	def.cost = BigNumber.from_float(20000000000.0)
	def.heat_production = BigNumber.from_float(50000000.0)
	def.max_heat = BigNumber.from_float(50000000.0)
	def.lifespan = 800
	def.tags = ["heat_producer", "water_immune"]
	return def

static func create_fusion_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.FUSION_CELL
	def.display_name = "Fusion Cell"
	def.cost = BigNumber.from_float(800000000000.0)
	def.heat_production = BigNumber.from_float(2500000000.0)
	def.max_heat = BigNumber.from_float(2500000000.0)
	def.lifespan = 800
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
	def.tags = ["energy_producer", "heat_immune", "water_immune"]
	return def

static func create_basic_generator() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.BASIC_GENERATOR
	def.display_name = "Basic Generator"
	def.cost = BigNumber.from_float(500.0)
	def.max_heat = BigNumber.from_float(25.0)
	def.energy_processing = BigNumber.from_float(3.0)
	def.tags = ["heat_consumer", "energy_producer", "water_immune"]
	return def

static func create_generator2() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR2
	def.display_name = "Generator 2"
	def.cost = BigNumber.from_float(2500000.0)
	def.max_heat = BigNumber.from_float(150.0)
	def.energy_processing = BigNumber.from_float(9.0)
	def.max_water = BigNumber.from_float(5000.0)
	def.water_consumption = BigNumber.from_float(1.0)
	def.water_boost_amount = BigNumber.from_float(100.0)
	def.tags = ["heat_consumer", "energy_producer", "water_consumer"]
	return def

static func create_generator3() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR3
	def.display_name = "Generator 3"
	def.cost = BigNumber.from_float(10000000000000.0)
	def.max_heat = BigNumber.from_float(900.0)
	def.energy_processing = BigNumber.from_float(32.0)
	def.max_water = BigNumber.from_float(8000.0)
	def.water_consumption = BigNumber.from_float(1.0)
	def.water_boost_amount = BigNumber.from_float(200.0)
	def.tags = ["heat_consumer", "energy_producer", "water_consumer"]
	return def

static func create_generator4() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR4
	def.display_name = "Generator 4"
	def.cost = BigNumber.from_float(50000000000000000.0)
	def.max_heat = BigNumber.from_float(2200.0)
	def.energy_processing = BigNumber.from_float(96.0)
	def.max_water = BigNumber.from_float(22000.0)
	def.water_consumption = BigNumber.from_float(1.0)
	def.water_boost_amount = BigNumber.from_float(400.0)
	def.tags = ["heat_consumer", "energy_producer", "water_consumer"]
	return def

#
# HITZE
#
static func create_heat_pipe() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HEAT_PIPE
	def.display_name = "Heat Pipe"
	def.cost = BigNumber.from_float(30.0)
	def.max_heat = BigNumber.from_float(50.0)
	def.heat_transfer_rate = 0.3
	def.tags = ["heat_consumer", "heat_transfer", "water_immune"]
	return def

#
# WASSER
#
static func create_water_pump() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WATER_PUMP
	def.display_name = "Water Pump"
	def.cost = BigNumber.from_float(25.0)
	def.water_production = BigNumber.from_float(5.0)
	def.max_water = BigNumber.from_float(50.0)
	def.water_transfer_rate = 0.25
	def.tags = ["water_producer", "heat_immune"]
	return def

static func create_water_pipe() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WATER_PIPE
	def.display_name = "Water Pipe"
	def.cost = BigNumber.from_float(35.0)
	def.water_transfer_rate = 0.5
	def.max_water = BigNumber.from_float(50.0)
	def.tags = ["water_transfer", "heat_immune"]
	return def
