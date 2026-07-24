extends Node

const SAVE_PATH = "user://savegame.json"

func save() -> void:
	var data = {}
	data["version"] = 2
	data["credits"] = {"m": GameState.credits.mantissa, "e": GameState.credits.exponent}
	data["research_points"] = {"m": GameState.research_points.mantissa, "e": GameState.research_points.exponent}
	data["bonus_ticks"] = GameState.bonus_ticks
	data["ticks_per_second"] = GameState.ticks_per_second
	data["timestamp"] = Time.get_unix_time_from_system()

	var purchased = []
	for item in GameState.research:
		if item.is_purchased:
			purchased.append(item.id)
	data["research_purchased"] = purchased

	var maps_data = []
	for map in MapManager.maps:
		var upgrade_data = []
		for upgrade in map.upgrades:
			upgrade_data.append({"id": upgrade.id, "level": upgrade.current_level})
		var grid_data = []
		for building in map.reactor_grid:
			if building == null:
				grid_data.append(null)
			else:
				grid_data.append({
					"type": building.definition.building_type,
					"age": building.age,
					"is_ghost": building.is_ghost,
					"current_heat": {"m": building.current_heat.mantissa, "e": building.current_heat.exponent},
					"current_water": {"m": building.current_water.mantissa, "e": building.current_water.exponent}
				})
		maps_data.append({
			"id": map.id,
			"display_name": map.display_name,
			"grid_width": map.grid_width,
			"grid_height": map.grid_height,
			"stored_energy": {"m": map.stored_energy.mantissa, "e": map.stored_energy.exponent},
			"max_storage": {"m": map.max_storage.mantissa, "e": map.max_storage.exponent},
			"upgrades": upgrade_data,
			"grid": grid_data,
			"is_unlocked": map.is_unlocked,
			"unlock_cost": {"m": map.unlock_cost.mantissa, "e": map.unlock_cost.exponent},
		})
	data["maps"] = maps_data
	data["active_map_index"] = MapManager.active_map_index
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var result = JSON.parse_string(content)
	if result == null:
		return {}
	return result
