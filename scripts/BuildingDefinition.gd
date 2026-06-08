extends RefCounted

class_name BuildingDefinition

var name : String
var cost : int

# Heat
var heat_production : float
var max_heat : float
var heat_transfer_rate : float

# Water
var water_production : float
var max_water : float
var water_transfer_rate : float

# Energy
var energy_production : float
var energy_processing : float

# Research
var research_production : float

# Lifetime
var lifespan : int


func _init(
	p_name : String,
	p_cost : int,

	# Heat
	p_heat_production : float,
	p_max_heat : float,
	p_heat_transfer_rate : float,

	# Water
	p_water_production : float,
	p_max_water : float,
	p_water_transfer_rate : float,

	# Energy
	p_energy_production : float,
	p_energy_processing : float,

	# Research
	p_research_production : float,

	# Lifetime
	p_lifespan : int
):

	name = p_name
	cost = p_cost

	heat_production = p_heat_production
	max_heat = p_max_heat
	heat_transfer_rate = p_heat_transfer_rate

	water_production = p_water_production
	max_water = p_max_water
	water_transfer_rate = p_water_transfer_rate

	energy_production = p_energy_production
	energy_processing = p_energy_processing

	research_production = p_research_production

	lifespan = p_lifespan
