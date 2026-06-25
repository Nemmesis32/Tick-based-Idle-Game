extends RefCounted
class_name UpgradeDatabase

static func get_all_upgrades() -> Array[UpgradeDefinition]:
	return [
		create_isolation_boost_1(),
		create_coal_heat_1(),
		create_global_storage_1(),
	]

static func create_isolation_boost_1() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "isolation_boost_1"
	def.display_name = "Isolation Efficiency"
	def.description = "Boosts Heat Production from Neighbors by 5% per Level"
	def.base_cost = BigNumber.from_float(2500.0)
	def.cost_multiplier = 2.1
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.ISOLATION
	def.stat = UpgradeDefinition.stat_type.HEAT_BOOST
	def.multiplier = 0.05
	def.requires = ""
	return def


static func create_coal_heat_1() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.display_name = "Coal Efficiency"
	def.id = "coal_heat_1"
	def.description = "Increases Heat Production of all Coal Burners by 25% per Level"
	def.base_cost = BigNumber.from_float(5000.0)
	def.cost_multiplier = 2.1
	def.target = UpgradeDefinition.target_type.BUILDING_TYPE
	def.building_type = BuildingDefinition.type.COAL_BURNER
	def.stat = UpgradeDefinition.stat_type.HEAT_PRODUCTION
	def.multiplier = 0.25
	def.requires = ""
	return def

static func create_global_storage_1() -> UpgradeDefinition:
	var def = UpgradeDefinition.new()
	def.id = "global_storage_1"
	def.display_name = "Storage Expansion"
	def.description = "Increases Max Storage by 25% per Level"
	def.base_cost = BigNumber.from_float(10000.0)
	def.cost_multiplier = 2.1
	def.target = UpgradeDefinition.target_type.GLOBAL
	def.stat = UpgradeDefinition.stat_type.ADDITIONAL_STORAGE
	def.multiplier = 0.25
	def.requires = ""
	return def
