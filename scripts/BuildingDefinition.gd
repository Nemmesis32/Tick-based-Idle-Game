extends RefCounted

class_name BuildingDefinition

enum type {
	NONE,
	WIND_TURBINE,
	MICRO_REACTOR,
	WATER_PUMP,
	WATER_PIPE,
	HEAT_PIPE,
	BASIC_GENERATOR,
	
}

var building_type : type = type.NONE

var display_name : String = ""
var cost : int = 0

# Heat
var heat_production : float = 0.0
var max_heat : float = 0.0
var heat_transfer_rate : float = 0.0

# Water
var water_production : float = 0.0
var max_water : float = 0.0
var water_transfer_rate : float = 0.0
var water_consumption : float = 0.0

# Energy
var energy_production : float = 0.0
var energy_processing : float = 0.0

# Lifetime
var lifespan : int = - 1
