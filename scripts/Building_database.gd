extends RefCounted

class_name BuildingDatabase


#
# REAKTOREN 
#

static func create_solar_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.SOLAR_CELL
	def.display_name = "Solar Cell"
	def.cost = 100
	def.heat_production = 3.0
	def.max_heat = 3.0
	def.lifespan = 100
	return def


static func create_coal_burner() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.COAL_BURNER
	def.display_name = "Coal Burner"
	def.cost = 1000
	def.heat_production = 380.0
	def.max_heat = 380.0
	def.lifespan = 400
	return def

static func create_gas_burner() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GAS_BURNER
	def.display_name = "Gas Burner"
	def.cost = 40000000
	def.heat_production = 75000
	def.max_heat = 75000
	def.lifespan = 800
	return def

static func create_nuclear_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.NUCLEAR_CELL
	def.display_name = "Nuclear Cell"
	def.cost = 500000000
	def.heat_production = 1200000
	def.max_heat = 1200000
	def.lifespan = 800
	return def

static func create_thermonuclear_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.THERMONUCLEAR_CELL
	def.display_name = "Thermonuclear Cell"
	def.cost = 20000000000
	def.heat_production = 50000000
	def.max_heat = 50000000
	def.lifespan = 800
	return def

static func create_fusion_cell() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.FUSION_CELL
	def.display_name = "Fusion Cell"
	def.cost = 800000000000
	def.heat_production = 2500000000
	def.max_heat = 2500000000
	def.lifespan = 800
	return def


#
# GENERATOREN
#

static func create_wind_turbine() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WIND_TURBINE
	def.display_name = "Wind Turbine"
	def.cost = 1
	def.energy_production = 0.15
	def.lifespan = 10
	return def

static func create_basic_generator() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.BASIC_GENERATOR
	def.display_name = "Basic Generator"
	def.cost = 500
	def.max_heat = 25
	def.energy_processing = 3.0
	return def

static func create_generator2() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR2
	def.display_name = "Generator 2"
	def.cost = 2500000
	def.max_heat = 150
	def.energy_processing = 9.0
	def.max_water = 5000.0
	def.water_consumption = 1.0
	def.water_boost_amount = 100
	return def

static func create_generator3() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR3
	def.display_name = "Generator 3"
	def.cost = 10000000000000
	def.max_heat = 900
	def.energy_processing = 32.0
	def.max_water = 8000.0
	def.water_consumption = 1.0
	def.water_boost_amount = 200
	return def

static func create_generator4() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.GENERATOR4
	def.display_name = "Generator 4"
	def.cost = 50000000000000000
	def.max_heat = 2200
	def.energy_processing = 96.0
	def.max_water = 22000.0
	def.water_consumption = 1.0
	def.water_boost_amount = 400
	return def


#
# WATER MANAGEMENT
#

static func create_water_pump() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WATER_PUMP
	def.display_name = "Water Pump"
	def.cost = 25
	def.water_production = 5.0
	def.max_water = 50.0
	def.water_transfer_rate = 0.25
	return def


static func create_water_pipe() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WATER_PIPE
	def.display_name = "Water Pipe"
	def.cost = 35
	def.water_transfer_rate = 0.5
	def.max_water = 50
	return def


#
# HEAT MANAGEMENT
#

static func create_heat_pipe() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HEAT_PIPE
	def.display_name = "Heat Pipe"
	def.cost = 30
	def.max_heat = 50
	def.heat_transfer_rate = 0.3
	return def
