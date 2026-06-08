extends Control

const EMPTY = 0
const REACTOR = 1
const WATER = 2

var selected_building = REACTOR

var reactor_grid = []

var grid_width = 3
var grid_height = 3


var reactor_cost = 10 
var reactor_production = 1

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


@onready var energy_label = $"MarginContainer/Main-VBoxContainer/resources/EnergyLabel"
@onready var credits_label = $"MarginContainer/Main-VBoxContainer/resources/Credits"
@onready var reactor_label = $"MarginContainer/Main-VBoxContainer/production/reactor"
@onready var auto_seller_label = $"MarginContainer/Main-VBoxContainer/autoseller/AutoSellerLabel"
@onready var reactor_grid_container = $"MarginContainer/Main-VBoxContainer/ReactorGrid"

func _ready():

	reactor_grid_container.columns = grid_width

	create_grid_data()
	build_grid()

	update_ui()

func create_grid_data():

	reactor_grid.clear()

	for i in range(grid_width * grid_height):
		reactor_grid.append(EMPTY)

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
	var produced_energy = count_reactors() * reactor_production
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
	update_ui()


func count_reactors() -> int:

	var count = 0

	for cell in reactor_grid:
		if cell == REACTOR:
			count += 1

	return count


func place_building(index: int, button: Button) -> void:
	if reactor_grid[index] != EMPTY:
		return

	match selected_building:

		REACTOR:
			if credits >= reactor_cost:

				credits -= reactor_cost
				reactor_grid[index] = REACTOR
				button.text = "[R]"

		WATER:
			reactor_grid[index] = WATER
			button.text = "[W]"

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

	if reactor_grid[index] == EMPTY:
		return

	reactor_grid[index] = EMPTY

	button.text = "[ ]"

	update_ui()
	
	

func _on_reactor_select_pressed() -> void:
	selected_building = REACTOR

func _on_water_select_pressed() -> void:
	selected_building = WATER


#func _on_windmill_pressed() -> void:
#	if credits >= reactor_cost:
#		credits -= reactor_cost
#		reactors += 1 
#		
#		update_ui()


func _on_button_pressed() -> void:
	if stored_energy < max_storage:
		stored_energy += 1
	update_ui()


func _on_buy_auto_seller_pressed() -> void:
	if credits >= auto_seller_cost:
		credits -= auto_seller_cost
		auto_sellers += 1
		update_ui()

func _on_reactor_upgrade_pressed() -> void:
	if credits >= reactor_upgrade_cost:
		credits -= reactor_upgrade_cost
		reactor_upgrade_level += 1
		reactor_production += 1
		
		reactor_upgrade_cost += 100
		
		update_ui()

func _on_storage_upgrade_pressed() -> void:
	if credits >= storage_upgrade_cost:
		credits -= storage_upgrade_cost
		storage_upgrade_level += 1
		max_storage += 50
		
		storage_upgrade_cost += 75
		
		update_ui()

func _on_seller_upgrade_pressed() -> void:
	if credits >= seller_upgrade_cost:
		credits -= seller_upgrade_cost
		seller_upgrade_level += 1 
		auto_seller_speed += 5 
		
		seller_upgrade_cost += 75
		
		update_ui()



func update_ui():
	energy_label.text = "Stored Energy: " + str(stored_energy)
	credits_label.text = "Credits: " + str(credits)
	reactor_label.text = "Mini Reactors: " + str(count_reactors())
	auto_seller_label.text = "Autosellers:" + str(auto_sellers)
