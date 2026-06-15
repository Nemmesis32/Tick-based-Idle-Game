extends Control

const DIRECTIONS = [
	Vector2i(0, -1), # oben
	Vector2i(1, 0),  # rechts
	Vector2i(0, 1),  # unten
	Vector2i(-1, 0)  # links
]

var selected_building : BuildingDefinition

var reactor_grid = []

var grid_width = 4
var grid_height = 4


var stored_energy = 0
var max_storage = 100

var credits = 1000000 


var wind_definition : BuildingDefinition
var reactor_definition : BuildingDefinition
var water_definition : BuildingDefinition
var pipe_definition : BuildingDefinition
var heat_pipe_definition : BuildingDefinition
var generator_definition : BuildingDefinition


@onready var energy_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/EnergyPerTickLabel"
@onready var credits_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/Credits"
@onready var stored_bar = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/StoreBar"
@onready var stored_label = $"MarginContainer/RootVbox/HeaderRow/StatsBox/VBoxContainer/StoredLabel"
@onready var reactor_grid_container = $"MarginContainer/RootVbox/MainArea/GridPanel/ReactorGrid"


func _ready():

	reactor_grid_container.columns = grid_width
	
	create_grid_data()
	build_grid()
	
	wind_definition = BuildingDatabase.create_wind_turbine()
	reactor_definition = BuildingDatabase.create_solar_cell()
	water_definition = BuildingDatabase.create_water_pump()
	pipe_definition = BuildingDatabase.create_water_pipe()
	heat_pipe_definition = BuildingDatabase.create_heat_pipe()
	generator_definition = BuildingDatabase.create_basic_generator()
	selected_building = wind_definition
	update_ui()



func create_grid_data():
	reactor_grid.clear()
	for i in range(grid_width * grid_height):
		reactor_grid.append(null)

func build_grid():
	for child in reactor_grid_container.get_children():
		child.queue_free()
	for i in range(grid_width * grid_height):
		var button = Button.new()
		button.text = "[ ]"
		button.custom_minimum_size = Vector2(64, 64)
		button.set_meta("grid_index", i)
		button.gui_input.connect(_on_grid_button_input.bind(button))
		reactor_grid_container.add_child(button)


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
		neighbors.append(
			coords_to_index(
				check_pos.x,
				check_pos.y
			)
		)
	return neighbors


func process_heat():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.heat_production <= 0:
			continue

		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []

		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.heat_production > 0:
				continue
			valid_neighbors.append(neighbor_index)
		if valid_neighbors.is_empty():
			building.current_heat += building.definition.heat_production
			continue
		var heat_share = (
			building.definition.heat_production
			/ valid_neighbors.size()
		)
		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			neighbor.current_heat += heat_share

			print(
				building.definition.display_name,
				" -> ",
				neighbor.definition.display_name,
				" : ",
				heat_share,
				" Heat"
			)

			print(
				neighbor.definition.display_name,
				" current_heat = ",
				neighbor.current_heat
			)

func process_overheat():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.max_heat <= 0:
			continue
		if building.current_heat >= building.definition.max_heat:
			print("Überhitzung bei Index", i, "-", building.definition.display_name)
			reactor_grid[i] = null 

func process_water():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		# Nur Gebäude die Wasser produzieren oder weiterleiten
		if building.definition.water_production <= 0 and building.definition.water_transfer_rate <= 0:
			continue
		if building.definition.building_type == BuildingDefinition.type.WATER_PIPE:
			continue
		# Erst produzieren
		if building.definition.water_production > 0:
			building.current_water = min(
				building.current_water + building.definition.water_production,
				building.definition.max_water
			)
		# Nichts zum Verteilen
		if building.current_water <= 0:
			continue
		# Valide Nachbarn sammeln
		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			# Nur Nachbarn die Wasser speichern können
			if neighbor.definition.max_water <= 0:
				continue
			# Keine Produzenten
			if neighbor.definition.water_production > 0:
				continue
			# Nur aufnehmen wenn noch Platz
			if neighbor.current_water >= neighbor.definition.max_water:
				continue
			valid_neighbors.append(neighbor_index)
		if valid_neighbors.is_empty():
			continue
		# Wie viel kann insgesamt übertragen werden?
		var total_transfer = min(
			building.definition.max_water * building.definition.water_transfer_rate,
			building.current_water
			)
		var water_share = total_transfer / valid_neighbors.size()
		# Wasser übertragen
		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			var actual_share = min(
				water_share,
				neighbor.definition.max_water - neighbor.current_water
			)
			neighbor.current_water += actual_share
			building.current_water -= actual_share

func process_heat_pipes():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.heat_transfer_rate <= 0:
			continue
		if building.current_heat <= 0:
			continue
		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.max_heat <= 0:
				continue
			if neighbor.definition.heat_production > 0:
				continue
			if neighbor.current_heat >= building.current_heat:
				continue
			valid_neighbors.append(neighbor_index)
		if valid_neighbors.is_empty():
			continue
		var transfer_amount = (
			building.definition.max_heat
			* building.definition.heat_transfer_rate
		)
		transfer_amount = min(
			transfer_amount,
			building.current_heat
		)
		var heat_share = (
			transfer_amount
			/ valid_neighbors.size()
		)
		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			neighbor.current_heat = min(
				neighbor.current_heat + heat_share,
				neighbor.definition.max_heat
				)
		building.current_heat -= transfer_amount

func process_water_pipes():
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.water_transfer_rate <= 0:
			continue
		if building.definition.building_type != BuildingDefinition.type.WATER_PIPE:
			continue
		if building.current_water <= 0:
			continue
		var neighbors = get_neighbor_indices(i)
		var valid_neighbors = []
		for neighbor_index in neighbors:
			var neighbor = reactor_grid[neighbor_index]
			if neighbor == null:
				continue
			if neighbor.definition.max_water <= 0:
				continue
			if neighbor.definition.water_production > 0:
				continue
			if neighbor.current_water >= neighbor.definition.max_water:
				continue
			valid_neighbors.append(neighbor_index)
		if valid_neighbors.is_empty():
			continue
		var transfer_amount = (
			building.definition.max_water
			* building.definition.water_transfer_rate
		)
		transfer_amount = min(
			transfer_amount,
			building.current_water
		)
		var water_share = (
			transfer_amount
			/ valid_neighbors.size()
		)
		var actually_transferred = 0.0
		for neighbor_index in valid_neighbors:
			var neighbor = reactor_grid[neighbor_index]
			var actual_share = min(
				water_share,
				neighbor.definition.max_water - neighbor.current_water
			)
			neighbor.current_water += actual_share
			actually_transferred += actual_share
			print(
				building.definition.display_name,
				" -> ",
				neighbor.definition.display_name,
				" : ",
				water_share,
				" Water"
			)
			print(
				neighbor.definition.display_name,
				" current_water = ",
				neighbor.current_water
			)
		building.current_water -= actually_transferred


func process_generators() -> float:
	var generated := 0.0
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		if building.definition.energy_processing <= 0:
			continue
		# Basis-Verarbeitung
		var processing_capacity = (building.definition.energy_processing)
		# Wasser erhöht die Verarbeitung solange:
		# - noch mehr Heat vorhanden ist
		# - noch Wasser vorhanden ist
		while (building.current_heat > processing_capacity and building.current_water >= building.definition.water_consumption):
			building.current_water -= (building.definition.water_consumption)
			processing_capacity += (building.definition.water_boost_amount)
		# Heat verarbeiten
		var processable = min(building.current_heat, processing_capacity)
		building.current_heat -= processable
		generated += processable
	return generated


func refresh_grid_visuals():
	var buttons = reactor_grid_container.get_children()

	for i in range(reactor_grid.size()):

		var button = buttons[i]
		var building = reactor_grid[i]

		if building == null:
			button.text = "[ ]"
			continue
		match building.definition.building_type:
			BuildingDefinition.type.WIND_TURBINE:
				button.text = "[WT]"
			BuildingDefinition.type.SOLAR_CELL:
				button.text = "[R]"
			BuildingDefinition.type.WATER_PUMP:
				button.text = "[W]"
			BuildingDefinition.type.BASIC_GENERATOR:
				button.text = "[G]"
			BuildingDefinition.type.WATER_PIPE:
				button.text = "[wP]"
			BuildingDefinition.type.HEAT_PIPE:
				button.text = "[hP]"

func _on_grid_button_input(
	event: InputEvent,
	button: Button
) -> void:
	var index = button.get_meta("grid_index")
	handle_grid_click(event, index)


func _on_sell_energy_pressed() -> void:
	credits += stored_energy
	stored_energy = 0
	update_ui()


func _on_tick_timer_timeout() -> void:

	# Produktion
	process_heat()
	process_water()
	# Pipes (transport)
	process_heat_pipes()
	process_water_pipes()
	# Umwandlung
	var generated = process_generators()
	# Konsequenzen 
	process_overheat()
	# Energieproduktion berechnen
	var produced_energy = get_total_energy_production() + generated
	# Energie speichern
	stored_energy += min(produced_energy, max_storage - stored_energy)
	# Gebäude altern und entfernen 
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		building.age += 1
		if building.definition.lifespan == -1:
			continue
		if building.age >= building.definition.lifespan:
			print(building.definition.display_name, " expired")
			reactor_grid[i] = null
	refresh_grid_visuals()
	update_ui()


func get_total_energy_production() -> float:
	var total := 0.0
	for building in reactor_grid:
		if building == null:
			continue
		total += building.definition.energy_production
	return total


func place_building(index: int) -> void:
	if reactor_grid[index] != null:
		return
	if credits < selected_building.cost:
		return
	credits -= selected_building.cost
	var building = Building.new(selected_building)
	reactor_grid[index] = building
	print(get_neighbor_indices(index))
	refresh_grid_visuals()
	update_ui()


func handle_grid_click(
	event: InputEvent,
	index: int,
) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				place_building(index,)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				remove_building(index)


func remove_building(index: int) -> void:
	if reactor_grid[index] == null:
		return
	reactor_grid[index] = null
	refresh_grid_visuals()
	update_ui()

func _on_wind_select_pressed() -> void:
	selected_building = wind_definition

func _on_reactor_select_pressed() -> void:
	selected_building = reactor_definition

func _on_water_select_pressed() -> void:
	selected_building = water_definition
	
func _on_water_pipe_select_pressed() -> void:
	selected_building = pipe_definition

func _on_generator_select_pressed() -> void:
	selected_building = generator_definition

func _on_heat_pipe_select_pressed() -> void:
	selected_building = heat_pipe_definition



func update_ui():
	credits_label.text = "Credits: " + str(credits)
	energy_label.text = "Energy/Tick: " + str(get_total_energy_production())
	stored_label.text = "Stored: " + str(stored_energy) + " / " + str(max_storage)
	stored_bar.value = (float(stored_energy) / float(max_storage)) * 100
