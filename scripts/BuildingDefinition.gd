extends RefCounted
class_name BuildingDefinition

enum type {
	NONE,
	SOLAR_CELL,
	COAL_BURNER,
	GAS_BURNER,
	NUCLEAR_CELL,
	THERMONUCLEAR_CELL,
	FUSION_CELL,
	THORIUM_CELL,
	PROTACTIUM_CELL,
	CURIUM_CELL,
	BALDRANIUM_CELL,
	WIND_TURBINE,
	BASIC_GENERATOR,
	GENERATOR2,
	GENERATOR3,
	GENERATOR4,
	GENERATOR5,
	WATER_PUMP,
	G_WATER_PUMP,
	WATER_PIPE,
	HEAT_PIPE,
	HEAT_SINK,
	HEAT_INLET,
	HEAT_OUTLET,
	HOME_OFFICE,
	SMALL_OFFICE,
	MEDIUM_OFFICE,
	LARGE_OFFICE,
	HUGE_OFFICE,
	BOILER_HOUSE,
	RESEARCH_CENTER,
	ADVANCED_RESEARCH_CENTER,
	SUPER_RESEARCH_CENTER,
	ISOLATION,
	CIRCULATOR,
	BATTERY,
	BANK,
}

var tags : Array = []
var building_type : type = type.NONE
var display_name : String = ""
var cost : BigNumber = BigNumber.from_float(0.0)

# Heat
var heat_production : BigNumber = BigNumber.from_float(0.0)
var max_heat : BigNumber = BigNumber.from_float(0.0)
var heat_transfer_rate : float = 0.0

# Water
var water_production : BigNumber = BigNumber.from_float(0.0)
var max_water : BigNumber = BigNumber.from_float(0.0)
var water_transfer_rate : float = 0.0
var water_consumption : BigNumber = BigNumber.from_float(0.0)
var water_boost_amount : BigNumber = BigNumber.from_float(0.0)

# Energy
var energy_production : BigNumber = BigNumber.from_float(0.0)
var energy_processing : BigNumber = BigNumber.from_float(0.0)
var energy_loss : float = 0.0

# Research
var research_production : BigNumber = BigNumber.from_float(0.0)

# Selling
var sell_amount : BigNumber = BigNumber.from_float(0.0)

# Boost
var water_boost : float = 0.0
var heat_boost : float = 0.0
var sell_amount_boost : float = 0.0
var additional_storage : float = 0.0

# Lifetime
var lifespan : int = -1
