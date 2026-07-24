extends RefCounted
class_name MapState

enum TileType {GRASS, WATER, SHORE, MOUNTAIN}

const DIRECTIONS = [
	Vector2i(0, -1), # oben
	Vector2i(1, 0),  # rechts
	Vector2i(0, 1),  # unten
	Vector2i(-1, 0)  # links
]

var id : String = ""
var display_name : String = ""
var terrain_id : String = "main"

var grid_width : int = 24
var grid_height : int = 13

var reactor_grid : Array = []
var grid_terrain : Array = []

var stored_energy : BigNumber = BigNumber.from_float(0.0)
var max_storage : BigNumber = BigNumber.from_float(100.0)

var is_unlocked : bool = true
var unlock_cost : BigNumber = BigNumber.from_float(0.0)

var last_total_production : BigNumber = BigNumber.from_float(0.0)
var last_research_production : BigNumber = BigNumber.from_float(0.0)

var tick_events : Array[String] = []

var upgrades : Array[UpgradeDefinition] = []


func _init(p_id: String, p_display_name: String, p_grid_width: int = 24, p_grid_height: int = 13, p_terrain_id: String = "main") -> void:
	id = p_id
	display_name = p_display_name
	grid_width = p_grid_width
	grid_height = p_grid_height
	terrain_id = p_terrain_id
	upgrades = UpgradeDatabase.get_all_upgrades()
	create_grid_data()


func create_grid_data() -> void:
	reactor_grid.clear()
	grid_terrain.clear()
	for i in range(grid_width * grid_height):
		reactor_grid.append(null)
		grid_terrain.append(TileType.WATER)
	apply_map_terrain()


func apply_map_terrain() -> void:
	for i in range(grid_terrain.size()):
		grid_terrain[i] = TileType.WATER

	var layout = MapTerrainDatabase.get_layout(terrain_id)
	for y in range(min(layout.size(), grid_height)):
		var row : String = layout[y]
		for x in range(min(row.length(), grid_width)):
			match row[x]:
				"G":
					grid_terrain[coords_to_index(x, y)] = TileType.GRASS
				"S":
					grid_terrain[coords_to_index(x, y)] = TileType.SHORE
				"M":
					grid_terrain[coords_to_index(x, y)] = TileType.MOUNTAIN


func index_to_coords(index: int) -> Vector2i:
	var x = index % grid_width
	@warning_ignore("integer_division")
	var y = int(index / grid_width)
	return Vector2i(x, y)


func coords_to_index(x: int, y: int) -> int:
	return y * grid_width + x


func get_neighbor_indices(index: int) -> Array[int]:
	var neighbors : Array[int] = []
	var pos = index_to_coords(index)
	for dir in DIRECTIONS:
		var check_pos = pos + dir
		if check_pos.x < 0:
			continue
		if check_pos.y < 0:
			continue
		if check_pos.x >= grid_width:
			continue
		if check_pos.y >= grid_height:
			continue
		neighbors.append(coords_to_index(check_pos.x, check_pos.y))
	return neighbors


func process_heat() -> void:
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.is_ghost:
			continue
		if building.definition.heat_production.is_zero():
			continue
		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.tags.has("heat_producer"):
				continue
			if neighbor.definition.tags.has("heat_immune"):
				continue
			valid_neighbors.append(neighbor_index)
		if valid_neighbors.is_empty():
			building.current_heat = building.current_heat.add(building.definition.heat_production)
			continue
		var upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.HEAT_PRODUCTION
		)
		var upgraded_production = building.definition.heat_production.multiply_float(upgrade_mult)
		var boost = get_boost_for_building(i, "booster", "heat_boost")
		var final_production = upgraded_production.multiply_float(1.0 + boost)
		var heat_share = final_production.divide_float(valid_neighbors.size())
		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			neighbor.current_heat = neighbor.current_heat.add(heat_share)


func process_overheat() -> void:
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.max_heat.is_zero():
			continue
		if building.current_heat.is_greater_or_equal(building.definition.max_heat):
			print("Überhitzung bei Index ", i, " - ", building.definition.display_name)
			tick_events.append(building.definition.display_name + " ist überhitzt!")
			reactor_grid[i] = null


func process_water() -> void:
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.water_production.is_zero() and building.definition.water_transfer_rate <= 0:
			continue
		if building.definition.tags.has("water_transfer"):
			continue
		if not building.definition.water_production.is_zero():
			building.current_water = building.current_water.add(building.definition.water_production).min_with(building.definition.max_water)
		if building.current_water.is_zero():
			continue
		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.max_water.is_zero():
				continue
			if neighbor.definition.tags.has("water_producer"):
				continue
			if neighbor.current_water.is_greater_or_equal(neighbor.definition.max_water):
				continue
			valid_neighbors.append(neighbor_index)
		if valid_neighbors.is_empty():
			continue
		var total_transfer = building.definition.max_water.multiply_float(building.definition.water_transfer_rate).min_with(building.current_water)
		var water_share = total_transfer.divide_float(valid_neighbors.size())
		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			var room_left = neighbor.definition.max_water.subtract(neighbor.current_water)
			var actual_share = water_share.min_with(room_left)
			neighbor.current_water = neighbor.current_water.add(actual_share)
			building.current_water = building.current_water.subtract(actual_share)


func process_heat_pipes() -> void:
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.heat_transfer_rate <= 0:
			continue
		if building.current_heat.is_zero():
			continue

		var effective_transfer = min(
			building.definition.heat_transfer_rate + get_upgrade_additive(
				UpgradeDefinition.target_type.BUILDING_TYPE,
				building.definition.building_type,
				UpgradeDefinition.stat_type.HEAT_TRANSFER_RATE
			), 1.0
		)

		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.max_heat.is_zero():
				continue
			if neighbor.definition.tags.has("heat_producer"):
				continue
			if neighbor.current_heat.is_greater_or_equal(building.current_heat):
				continue
			valid_neighbors.append(neighbor_index)

		if valid_neighbors.is_empty():
			continue

		var transfer_amount = building.definition.max_heat.multiply_float(effective_transfer).min_with(building.current_heat)
		var heat_share = transfer_amount.divide_float(valid_neighbors.size())

		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			neighbor.current_heat = neighbor.current_heat.add(heat_share).min_with(neighbor.definition.max_heat)

		building.current_heat = building.current_heat.subtract(transfer_amount)


func process_water_pipes() -> void:
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.water_transfer_rate <= 0:
			continue
		if not building.definition.tags.has("water_transfer"):
			continue
		if building.current_water.is_zero():
			continue

		var effective_transfer = min(
			building.definition.water_transfer_rate + get_upgrade_additive(
				UpgradeDefinition.target_type.BUILDING_TYPE,
				building.definition.building_type,
				UpgradeDefinition.stat_type.WATER_TRANSFER_RATE
			), 1.0
		)

		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.max_water.is_zero():
				continue
			if neighbor.definition.tags.has("water_producer"):
				continue
			if neighbor.current_water.is_greater_or_equal(neighbor.definition.max_water):
				continue
			valid_neighbors.append(neighbor_index)

		if valid_neighbors.is_empty():
			continue

		var transfer_amount = building.definition.max_water.multiply_float(effective_transfer).min_with(building.current_water)
		var water_share = transfer_amount.divide_float(valid_neighbors.size())

		var actually_transferred = BigNumber.from_float(0.0)
		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			var room_left = neighbor.definition.max_water.subtract(neighbor.current_water)
			var actual_share = water_share.min_with(room_left)
			neighbor.current_water = neighbor.current_water.add(actual_share)
			actually_transferred = actually_transferred.add(actual_share)
		building.current_water = building.current_water.subtract(actually_transferred)


func process_generators() -> BigNumber:
	var generated = BigNumber.from_float(0.0)
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.energy_processing.is_zero():
			continue
		var processing_upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.ENERGY_PROCESSING
		)
		var max_heat_upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.MAX_HEAT
		)
		var max_water_upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.MAX_WATER
		)
		var processing_capacity = building.definition.energy_processing.multiply_float(processing_upgrade_mult)
		var effective_max_heat = building.definition.max_heat.multiply_float(max_heat_upgrade_mult)
		var effective_max_water = building.definition.max_water.multiply_float(max_water_upgrade_mult)
		var water_boost = get_boost_for_building(i, "booster", "water_boost")
		effective_max_water = effective_max_water.multiply_float(1.0 + water_boost)
		while (
			building.current_heat.is_greater_than(processing_capacity)
			and not building.definition.water_consumption.is_zero()
			and building.current_water.is_greater_or_equal(building.definition.water_consumption)
		):
			building.current_water = building.current_water.subtract(building.definition.water_consumption)
			processing_capacity = processing_capacity.add(building.definition.water_boost_amount)
		var processable = building.current_heat.min_with(processing_capacity).min_with(effective_max_heat)
		building.current_heat = building.current_heat.subtract(processable)
		generated = generated.add(processable)
	return generated


func process_heat_sink() -> void:
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if not building.definition.tags.has("heat_sink"):
			continue
		if building.current_heat.is_zero():
			continue
		var dissipated = building.current_heat.multiply_float(building.definition.energy_loss)
		building.current_heat = building.current_heat.subtract(dissipated)


func process_research() -> BigNumber:
	var generated = BigNumber.from_float(0.0)
	for building in reactor_grid:
		if building == null:
			continue
		if not building.definition.tags.has("research_producer"):
			continue
		generated = generated.add(building.definition.research_production)
	return generated


func get_boost_for_building(index: int, boost_tag: String, boost_field: String) -> float:
	var total_boost := 0.0
	var neighbors = get_neighbor_indices(index)
	for neighbor_index in neighbors:
		var neighbor = reactor_grid[neighbor_index]
		if neighbor == null:
			continue
		if not neighbor.definition.tags.has("booster"):
			continue
		match boost_field:
			"heat_boost":
				if neighbor.definition.heat_boost > 0:
					var upgrade_mult = get_upgrade_multiplier(
						UpgradeDefinition.target_type.BUILDING_TYPE,
						neighbor.definition.building_type,
						UpgradeDefinition.stat_type.HEAT_BOOST
					)
					var upgrade_add = get_upgrade_additive(
						UpgradeDefinition.target_type.BUILDING_TYPE,
						neighbor.definition.building_type,
						UpgradeDefinition.stat_type.HEAT_BOOST
					)
					total_boost += (neighbor.definition.heat_boost + upgrade_add) * upgrade_mult
			"water_boost":
				if neighbor.definition.water_boost > 0:
					var upgrade_mult = get_upgrade_multiplier(
						UpgradeDefinition.target_type.BUILDING_TYPE,
						neighbor.definition.building_type,
						UpgradeDefinition.stat_type.WATER_BOOST
					)
					total_boost += neighbor.definition.water_boost * upgrade_mult
			"sell_amount_boost":
				if neighbor.definition.sell_amount_boost > 0:
					var upgrade_mult = get_upgrade_multiplier(
						UpgradeDefinition.target_type.BUILDING_TYPE,
						neighbor.definition.building_type,
						UpgradeDefinition.stat_type.SELL_AMOUNT_BOOST
					)
					total_boost += neighbor.definition.sell_amount_boost * upgrade_mult
	return total_boost


func get_effective_max_storage() -> BigNumber:
	var total = max_storage
	var upgrade_mult = get_upgrade_multiplier(
		UpgradeDefinition.target_type.GLOBAL,
		BuildingDefinition.type.NONE,
		UpgradeDefinition.stat_type.ADDITIONAL_STORAGE
	)
	total = total.multiply_float(upgrade_mult)
	for building in reactor_grid:
		if building == null:
			continue
		if building.definition.additional_storage <= 0:
			continue
		total = total.add(BigNumber.from_float(building.definition.additional_storage * 100.0))
	return total


func get_effective_lifespan(building: Building) -> int:
	if building.definition.lifespan == -1:
		return -1
	var mult = get_upgrade_multiplier(
		UpgradeDefinition.target_type.BUILDING_TYPE,
		building.definition.building_type,
		UpgradeDefinition.stat_type.LIFESPAN
	)
	return int(float(building.definition.lifespan) * mult)


func get_total_energy_production() -> BigNumber:
	var total = BigNumber.from_float(0.0)
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.is_ghost:
			continue
		if building.definition.energy_production.is_zero():
			continue
		var upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.ENERGY_PRODUCTION,
			building.definition.tags
		)
		total = total.add(building.definition.energy_production.multiply_float(upgrade_mult))
	return total


func get_total_sell_capacity() -> BigNumber:
	var total = BigNumber.from_float(0.0)
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if not building.definition.tags.has("energy_seller"):
			continue
		var upgrade_mult = get_upgrade_multiplier(
			UpgradeDefinition.target_type.BUILDING_TYPE,
			building.definition.building_type,
			UpgradeDefinition.stat_type.SELL_AMOUNT,
			building.definition.tags
		)
		var upgraded_sell = building.definition.sell_amount.multiply_float(upgrade_mult)
		var boost = get_boost_for_building(i, "booster", "sell_amount_boost")
		var effective_sell = upgraded_sell.multiply_float(1.0 + boost)
		total = total.add(effective_sell)
	return total


func get_upgrade_multiplier(
	target: UpgradeDefinition.target_type,
	building_type: BuildingDefinition.type,
	stat: UpgradeDefinition.stat_type,
	tags: Array = []
) -> float:
	var total := 1.0
	for upgrade in upgrades:
		if upgrade.current_level == 0:
			continue
		if upgrade.stat != stat:
			continue
		match upgrade.target:
			UpgradeDefinition.target_type.GLOBAL:
				if target != UpgradeDefinition.target_type.GLOBAL:
					continue
			UpgradeDefinition.target_type.BUILDING_TYPE:
				if target != UpgradeDefinition.target_type.BUILDING_TYPE:
					continue
				if upgrade.building_type != building_type:
					continue
			UpgradeDefinition.target_type.TAG:
				if not tags.has(upgrade.target_tag):
					continue
		total += upgrade.multiplier * upgrade.current_level
	return total


func get_upgrade_additive(
	target: UpgradeDefinition.target_type,
	building_type: BuildingDefinition.type,
	stat: UpgradeDefinition.stat_type
) -> float:
	var total := 0.0
	for upgrade in upgrades:
		if upgrade.current_level == 0:
			continue
		if upgrade.mode != UpgradeDefinition.upgrade_mode.ADDITIVE:
			continue
		if upgrade.target != target:
			continue
		if upgrade.target == UpgradeDefinition.target_type.BUILDING_TYPE:
			if upgrade.building_type != building_type:
				continue
		if upgrade.stat != stat:
			continue
		total += upgrade.multiplier * upgrade.current_level
	return total


func get_effective_building_stats(def: BuildingDefinition) -> Dictionary:
	var stats := {}

	if def.lifespan != -1:
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.LIFESPAN)
		stats["lifespan"] = int(float(def.lifespan) * mult)

	if not def.heat_production.is_zero():
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.HEAT_PRODUCTION)
		stats["heat_production"] = def.heat_production.multiply_float(mult)

	if not def.max_heat.is_zero():
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.MAX_HEAT)
		stats["max_heat"] = def.max_heat.multiply_float(mult)

	if def.heat_transfer_rate > 0.0:
		var add = get_upgrade_additive(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.HEAT_TRANSFER_RATE)
		stats["heat_transfer_rate"] = min(def.heat_transfer_rate + add, 1.0)

	if not def.water_production.is_zero():
		# Hinweis: WATER_PRODUCTION wird in process_water() aktuell nicht mit Upgrades multipliziert - Basiswert
		stats["water_production"] = def.water_production

	if not def.max_water.is_zero():
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.MAX_WATER)
		stats["max_water"] = def.max_water.multiply_float(mult)

	if def.water_transfer_rate > 0.0:
		if def.tags.has("water_transfer"):
			var add = get_upgrade_additive(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.WATER_TRANSFER_RATE)
			stats["water_transfer_rate"] = min(def.water_transfer_rate + add, 1.0)
		else:
			stats["water_transfer_rate"] = def.water_transfer_rate

	if not def.water_consumption.is_zero():
		stats["water_consumption"] = def.water_consumption

	if not def.water_boost_amount.is_zero():
		stats["water_boost_amount"] = def.water_boost_amount

	if not def.energy_production.is_zero():
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.ENERGY_PRODUCTION, def.tags)
		stats["energy_production"] = def.energy_production.multiply_float(mult)

	if not def.energy_processing.is_zero():
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.ENERGY_PROCESSING)
		stats["energy_processing"] = def.energy_processing.multiply_float(mult)

	if def.energy_loss > 0.0:
		stats["energy_loss"] = def.energy_loss

	if not def.research_production.is_zero():
		# Hinweis: RESEARCH_PRODUCTION wird in process_research() aktuell nicht mit Upgrades multipliziert - Basiswert
		stats["research_production"] = def.research_production

	if not def.sell_amount.is_zero():
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.SELL_AMOUNT, def.tags)
		stats["sell_amount"] = def.sell_amount.multiply_float(mult)

	if def.heat_boost > 0.0:
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.HEAT_BOOST)
		var add = get_upgrade_additive(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.HEAT_BOOST)
		stats["heat_boost"] = (def.heat_boost + add) * mult

	if def.water_boost > 0.0:
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.WATER_BOOST)
		stats["water_boost"] = def.water_boost * mult

	if def.sell_amount_boost > 0.0:
		var mult = get_upgrade_multiplier(UpgradeDefinition.target_type.BUILDING_TYPE, def.building_type, UpgradeDefinition.stat_type.SELL_AMOUNT_BOOST)
		stats["sell_amount_boost"] = def.sell_amount_boost * mult

	if def.additional_storage > 0.0:
		stats["additional_storage"] = def.additional_storage

	return stats


func get_upgrade_by_id(id: String) -> UpgradeDefinition:
	for upgrade in upgrades:
		if upgrade.id == id:
			return upgrade
	return null


func get_upgrade_cost(upgrade: UpgradeDefinition) -> BigNumber:
	var exponent = upgrade.current_level
	var multiplier = pow(upgrade.cost_multiplier, exponent)
	return upgrade.base_cost.multiply_float(multiplier)


func can_purchase_upgrade(upgrade: UpgradeDefinition) -> bool:
	if upgrade.requires != "":
		var required = get_upgrade_by_id(upgrade.requires)
		if required == null or required.current_level == 0:
			return false
	if GameState.credits.is_less_than(get_upgrade_cost(upgrade)):
		return false
	return true


func purchase_upgrade(upgrade: UpgradeDefinition) -> void:
	if not can_purchase_upgrade(upgrade):
		return
	var cost = get_upgrade_cost(upgrade)
	GameState.credits = GameState.credits.subtract(cost)
	upgrade.current_level += 1


func sell_upgrade(upgrade: UpgradeDefinition) -> void:
	if upgrade.current_level == 0:
		return
	var exponent = upgrade.current_level - 1
	var refund = upgrade.base_cost.multiply_float(pow(upgrade.cost_multiplier, exponent) * 0.5)
	GameState.credits = GameState.credits.add(refund)
	upgrade.current_level -= 1


func place_building(index: int, def: BuildingDefinition) -> bool:
	if reactor_grid[index] != null and not reactor_grid[index].is_ghost:
		return false
	if GameState.credits.is_less_than(def.cost):
		return false
	var terrain = grid_terrain[index]
	if def.requires_shore:
		if terrain != TileType.SHORE:
			return false
	else:
		if terrain != TileType.GRASS and terrain != TileType.SHORE:
			return false
	GameState.credits = GameState.credits.subtract(def.cost)
	reactor_grid[index] = Building.new(def)
	return true


func remove_building(index: int) -> bool:
	if reactor_grid[index] == null:
		return false
	reactor_grid[index] = null
	return true


func run_tick() -> Dictionary:
	tick_events = []
	process_heat()
	process_water()
	process_heat_pipes()
	process_water_pipes()
	process_heat_sink()
	var research_generated = process_research()
	GameState.add_research_points(research_generated)
	var generated = process_generators()
	process_overheat()

	var total_production = get_total_energy_production().add(generated)
	var effective_storage = get_effective_max_storage()
	var sell_capacity = get_total_sell_capacity()
	var sold_from_production = total_production.min_with(sell_capacity)
	GameState.credits = GameState.credits.add(sold_from_production)
	var remaining_energy = total_production.subtract(sold_from_production)
	var room_left = effective_storage.subtract(stored_energy)
	stored_energy = stored_energy.add(remaining_energy.min_with(room_left))
	var remaining_capacity = sell_capacity.subtract(sold_from_production)
	if remaining_capacity.is_greater_than(BigNumber.from_float(0.0)):
		var sold_from_storage = stored_energy.min_with(remaining_capacity)
		GameState.credits = GameState.credits.add(sold_from_storage)
		stored_energy = stored_energy.subtract(sold_from_storage)

	_process_building_lifespans()

	last_total_production = total_production
	last_research_production = research_generated

	return {
		"total_production": total_production,
		"effective_storage": effective_storage,
		"events": tick_events,
	}


func _process_building_lifespans() -> void:
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.lifespan == -1:
			continue
		building.age += 1
		if building.age >= get_effective_lifespan(building):
			if not building.is_ghost:
				building.is_ghost = true
				tick_events.append(building.definition.display_name + " ist ausgelaufen")
			elif GameState.auto_rebuild_enabled and building.definition.manager_research_id != "" and GameState.is_researched(building.definition.manager_research_id):
				if not GameState.credits.is_less_than(building.definition.cost):
					GameState.credits = GameState.credits.subtract(building.definition.cost)
					building.age = 0
					building.is_ghost = false
					tick_events.append(building.definition.display_name + " automatisch neu gebaut")
