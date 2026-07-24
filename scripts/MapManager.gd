extends Node

var maps : Array[MapState] = []
var active_map_index : int = 0


func add_map(p_id: String, p_display_name: String, p_grid_width: int = 24, p_grid_height: int = 13, p_terrain_id: String = "main") -> MapState:
	var map = MapState.new(p_id, p_display_name, p_grid_width, p_grid_height, p_terrain_id)
	maps.append(map)
	return map


func get_active_map() -> MapState:
	if maps.is_empty():
		return null
	return maps[active_map_index]


func get_map_by_id(p_id: String) -> MapState:
	for map in maps:
		if map.id == p_id:
			return map
	return null


func set_active_map_by_id(p_id: String) -> bool:
	for i in range(maps.size()):
		if maps[i].id == p_id:
			active_map_index = i
			return true
	return false


func tick_all() -> Dictionary:
	var results := {}
	for map in maps:
		if not map.is_unlocked:
			continue
		results[map.id] = map.run_tick()
	return results
