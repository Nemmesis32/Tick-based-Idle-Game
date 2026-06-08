extends RefCounted

class_name BuildingDatabase

static func create_wind_turbine() -> BuildingDefinition:

	return BuildingDefinition.new(
		"Wind Turbine",
		1,

		0.0,    # heat production
		0.0,    # max heat
		0.0,    # heat transfer rate

		0.0,    # water production
		0.0,    # max water
		0.0,    # water transfer rate

		0.15,   # energy production
		0.0,    # energy processing

		0.0,    # research production

		10      # lifespan
	)
	
static func create_micro_reactor() -> BuildingDefinition:

	return BuildingDefinition.new(
		"Micro Reactor",
		10,

		5.0,    # heat production
		5.0,    # max heat
		0.0,    # heat transfer rate

		0.0,    # water production
		0.0,    # max water
		0.0,    # water transfer rate

		0.0,    # energy production
		0.0,    # energy processing

		0.0,    # research production

		999999  # lifespan
	)

static func create_water_pump() -> BuildingDefinition:

	return BuildingDefinition.new(
		"Water Pump",
		25,

		0.0,    # heat production
		10.0,   # max heat
		0.0,    # heat transfer rate

		5.0,    # water production
		50.0,   # max water
		5.0,    # water transfer rate

		0.0,    # energy production
		0.0,    # energy processing

		0.0,    # research production

		999999  # lifespan
	)

static func create_basic_generator() -> BuildingDefinition:

	return BuildingDefinition.new(
		"Basic Generator",
		50,

		0.0,    # heat production
		20.0,   # max heat
		0.0,    # heat transfer rate

		0.0,    # water production
		50.0,   # max water
		0.0,    # water transfer rate

		0.0,    # energy production
		5.0,    # energy processing

		0.0,    # research production

		999999  # lifespan
	)
