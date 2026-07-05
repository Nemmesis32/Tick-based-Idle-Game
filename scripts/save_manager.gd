extends Node

const SAVE_PATH = "user://savegame.json"

func save(
	credits: BigNumber,
	research_points: BigNumber,
	research: Array,
	reactor_grid: Array,
	upgrades: Array,
	bonus_ticks: int
) -> void:
	var data = {}
	data["version"] = 1
	data["credits"] = {"m": credits.mantissa, "e": credits.exponent}
	data["research_points"] = {"m": research_points.mantissa, "e": research_points.exponent}
	data["bonus_ticks"] = bonus_ticks
	data["timestamp"] = Time.get_unix_time_from_system()
	var purchased = []
	for item in research:
		if item.is_purchased:
			purchased.append(item.id)
	data["research_purchased"] = purchased
	var upgrade_data = []
	for upgrade in upgrades:
		upgrade_data.append({
			"id": upgrade.id,
			"level": upgrade.current_level
		})
	data["upgrades"] = upgrade_data
	var grid_data = []
	for building in reactor_grid:
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
	data["grid"] = grid_data
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
