extends Control

var selected_building : BuildingDefinition

var reactor_grid = []

var grid_width = 4
var grid_height = 4


var auto_sellers = 0
var auto_seller_cost = 25
var auto_seller_speed = 5

var stored_energy = 0
var max_storage = 100

var credits = 100 

var reactor_upgrade_level = 0 
var storage_upgrade_level = 0 
var seller_upgrade_level = 0 

var reactor_upgrade_cost = 100 
var storage_upgrade_cost = 75
var seller_upgrade_cost = 125

var wind_definition : BuildingDefinition
var reactor_definition : BuildingDefinition
var water_definition : BuildingDefinition
var generator_definition : BuildingDefinition



@onready var energy_label = $"MarginContainer/Main-VBoxContainer/resources/EnergyLabel"
@onready var credits_label = $"MarginContainer/Main-VBoxContainer/resources/Credits"
@onready var reactor_label = $"MarginContainer/Main-VBoxContainer/production/reactor"
@onready var auto_seller_label = $"MarginContainer/Main-VBoxContainer/autoseller/AutoSellerLabel"
@onready var reactor_grid_container = $"MarginContainer/Main-VBoxContainer/ReactorGrid"

func _ready():

	reactor_grid_container.columns = grid_width
	
	create_grid_data()
	build_grid()
	
	wind_definition = BuildingDatabase.create_wind_turbine()

	reactor_definition = BuildingDatabase.create_micro_reactor()

	water_definition = BuildingDatabase.create_water_pump()

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

func refresh_grid_visuals():

	var buttons = reactor_grid_container.get_children()

	for i in range(reactor_grid.size()):

		var button = buttons[i]
		var building = reactor_grid[i]

		if building == null:

			button.text = "[ ]"
			continue

		match building.definition.name:

			"Wind Turbine":
				button.text = "[WT]"

			"Micro Reactor":
				button.text = "[R]"

			"Water Pump":
				button.text = "[W]"

			"Basic Generator":
				button.text = "[G]"


func _on_grid_button_input(
	event: InputEvent,
	button: Button
) -> void:

	var index = button.get_meta("grid_index")

	handle_grid_click(event, index, button)



func _on_sell_energy_pressed() -> void:
	credits += stored_energy
	stored_energy = 0
	update_ui()


func _on_tick_timer_timeout() -> void:

	# Energieproduktion berechnen
	var produced_energy = get_total_energy_production()
	# Verkaufskapazität berechnen
	var selling_capacity = auto_sellers * auto_seller_speed
	# Direkt verkaufte Energie
	var directly_sold = min(produced_energy, selling_capacity)
	# Credits durch Direktverkauf
	credits += directly_sold
	# Übrig gebliebene Energie
	var remaining_energy = produced_energy - directly_sold
	# Freien Speicher berechnen
	var available_storage = max_storage - stored_energy
	# Tatsächlich speicherbare Energie
	var accepted_energy = min(remaining_energy, available_storage)
	# Energie speichern
	stored_energy += accepted_energy
	# Gebäude altern und entfernen 
	for i in range(reactor_grid.size()):
		var building = reactor_grid[i]
		if building == null:
			continue
		building.age += 1
		if building.age >= building.definition.lifespan:
			print(building.definition.name, " expired")
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


func place_building(index: int, button: Button) -> void:
	
	if reactor_grid[index] != null:
		return

	if credits < selected_building.cost:
		return

	credits -= selected_building.cost

	var building = Building.new(selected_building)

	reactor_grid[index] = building

	refresh_grid_visuals()
	update_ui()


func handle_grid_click(
	event: InputEvent,
	index: int,
	button: Button
) -> void:

	if event is InputEventMouseButton:

		if event.pressed:

			if event.button_index == MOUSE_BUTTON_LEFT:
				place_building(index, button)

			elif event.button_index == MOUSE_BUTTON_RIGHT:
				remove_building(index, button)


func remove_building(index: int, button: Button) -> void:

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



func _on_button_pressed() -> void:
	if stored_energy < max_storage:
		stored_energy += 1
	update_ui()


func _on_buy_auto_seller_pressed() -> void:
	if credits >= auto_seller_cost:
		credits -= auto_seller_cost
		auto_sellers += 1
		update_ui()

#func _on_reactor_upgrade_pressed() -> void:
#	if credits >= reactor_upgrade_cost:
#		credits -= reactor_upgrade_cost
#		reactor_upgrade_level += 1
#		reactor_production += 1
#		
#		reactor_upgrade_cost += 100
#		
#		update_ui()

#func _on_storage_upgrade_pressed() -> void:
#	if credits >= storage_upgrade_cost:
#		credits -= storage_upgrade_cost
#		storage_upgrade_level += 1
#		max_storage += 50
#		
#		storage_upgrade_cost += 75
#		
#		update_ui()

#func _on_seller_upgrade_pressed() -> void:
#	if credits >= seller_upgrade_cost:
#		credits -= seller_upgrade_cost
#		seller_upgrade_level += 1 
#		auto_seller_speed += 5 
#		
#		seller_upgrade_cost += 75
		
#		update_ui()



func update_ui():
	energy_label.text = "Stored Energy: " + str(stored_energy)
	credits_label.text = "Credits: " + str(credits)
	reactor_label.text = "Energy/Tick: " + str(get_total_energy_production())
	auto_seller_label.text = "Autosellers:" + str(auto_sellers)
