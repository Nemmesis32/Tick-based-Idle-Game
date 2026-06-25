extends RefCounted
class_name UpgradeDefinition

enum target_type {
	GLOBAL,
	BUILDING_TYPE,
}

enum stat_type {
	HEAT_PRODUCTION,
	MAX_HEAT,
	MAX_WATER,
	WATER_PRODUCTION,
	ENERGY_PROCESSING,
	SELL_AMOUNT,
	HEAT_BOOST,
	WATER_BOOST,
	SELL_AMOUNT_BOOST,
	ADDITIONAL_STORAGE,
	HEAT_TRANSFER_RATE,
}

var id : String = ""
var display_name : String = ""
var description : String = ""

var base_cost : BigNumber = BigNumber.from_float(0.0)
var cost_multiplier : float = 2.1

var target : target_type = target_type.GLOBAL
var building_type : BuildingDefinition.type = BuildingDefinition.type.NONE
var stat : stat_type = stat_type.HEAT_PRODUCTION
var multiplier : float = 1.0

var requires : String = ""

var current_level : int = 0
var max_level : int = -1
