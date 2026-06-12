extends RefCounted

class_name BuildingDatabase

static func create_wind_turbine() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WIND_TURBINE
	def.display_name = "Wind Turbine"
	def.cost = 1
	def.energy_production = 0.15
	def.lifespan = 10
	return def

static func create_micro_reactor() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.MICRO_REACTOR
	def.display_name = "Micro Reactor"
	def.cost = 10
	def.heat_production = 5.0
	def.max_heat = 5.0
	def.lifespan = 50
	return def

static func create_water_pump() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WATER_PUMP
	def.display_name = "Water Pump"
	def.cost = 25
	def.water_production = 5.0
	def.max_water = 50.0
	def.water_transfer_rate = 0.25
	return def

static func create_basic_generator() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.BASIC_GENERATOR
	def.display_name = "Basic Generator"
	def.cost = 50
	def.max_heat = 20
	def.energy_processing = 5.0
	def.max_water = 20.0
	def.water_consumption = 10.0
	return def
	
static func create_water_pipe() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.WATER_PIPE
	def.display_name = "Water Pipe"
	def.cost = 35
	def.water_transfer_rate = 0.5
	def.max_water = 50
	return def

static func create_heat_pipe() -> BuildingDefinition:
	var def = BuildingDefinition.new()
	def.building_type = BuildingDefinition.type.HEAT_PIPE
	def.display_name = "Heat Pipe"
	def.cost = 30
	def.max_heat = 50
	def.heat_transfer_rate = 0.3
	return def
