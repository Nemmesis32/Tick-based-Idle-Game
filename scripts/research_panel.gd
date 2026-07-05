extends Control

signal back_pressed

@onready var back_button = $MarginContainer/VBoxContainer/HBoxContainer/BackButton
@onready var rp_label = $MarginContainer/VBoxContainer/RPLabel
@onready var grid_wirtschaft = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/Grid_Wirtschaft
@onready var grid_produktion = $"MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/GridW&I"
@onready var grid_technologie = $"MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/GridT&M"

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	grid_wirtschaft.columns = 2
	grid_produktion.columns = 2
	grid_technologie.columns = 2

func setup(research: Array, research_points: BigNumber, credits: BigNumber, on_purchase: Callable) -> void:
	rp_label.text = "Forschungspunkte: " + research_points.to_display_string()
	for child in grid_wirtschaft.get_children():
		child.queue_free()
	for child in grid_produktion.get_children():
		child.queue_free()
	for child in grid_technologie.get_children():
		child.queue_free()

	var wirtschaft_ids = [
		"research_center_bought", "home_office", "small_office", "medium_office",
		"large_office", "huge_office", "bank", "advanced_research_center",
		"super_research_center", "chromatic_1", "chromatic_2", "chromatic_3",
		"chromatic_4", "chromatic_5"
	]
	var produktion_ids = [
		"batteries", "generator_1", "generator_2", "generator_3", "generator_4",
		"generator_5", "isolation", "heat_exchanger", "heat_sink", "boiler_house",
		"heat_inlet", "heat_outlet", "water_pump", "water_pipe", "groundwater_pump",
		"circulator"
	]
	var reaktor_order = [
		"balduranium_cell", "balduranium_cell_manager",
		"curium_cell", "curium_cell_manager",
		"protactium_cell", "protactium_cell_manager",
		"thorium_cell", "thorium_cell_manager",
		"fusion_cell", "fusion_cell_manager",
		"thermonuclear_cell", "thermonuclear_cell_manager",
		"nuclear_cell", "nuclear_cell_manager",
		"gas_burner", "gas_burner_manager",
		"coal_burner", "coal_burner_manager",
		"solar_cell", "solar_cell_manager",
		"wind_turbine", "wind_turbine_manager",
	]

	for item in research:
		var is_visible = _can_see(item, research)
		if not is_visible:
			continue
		if item.id in wirtschaft_ids:
			_add_research_entry(item, grid_wirtschaft, research_points, credits, on_purchase)
		elif item.id in produktion_ids:
			_add_research_entry(item, grid_produktion, research_points, credits, on_purchase)

	for id in reaktor_order:
		for item in research:
			if item.id == id:
				if _can_see(item, research):
					_add_research_entry(item, grid_technologie, research_points, credits, on_purchase)
				break



var reaktor_order = [
	"balduranium_cell", "balduranium_cell_manager",
	"curium_cell", "curium_cell_manager",
	"protactium_cell", "protactium_cell_manager",
	"thorium_cell", "thorium_cell_manager",
	"fusion_cell", "fusion_cell_manager",
	"thermonuclear_cell", "thermonuclear_cell_manager",
	"nuclear_cell", "nuclear_cell_manager",
	"gas_burner", "gas_burner_manager",
	"coal_burner", "coal_burner_manager",
	"solar_cell", "solar_cell_manager",
	"wind_turbine", "wind_turbine_manager",
]



func _add_research_entry(item: ResearchDefinition, grid: GridContainer, research_points: BigNumber, credits: BigNumber, on_purchase: Callable) -> void:
	var container = PanelContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var vbox = VBoxContainer.new()
	container.add_child(vbox)
	var name_label = Label.new()
	name_label.text = item.display_name
	vbox.add_child(name_label)
	var cost_label = Label.new()
	if item.cost.is_zero():
		cost_label.text = "Kostenlos"
	elif item.cost_in_credits:
		cost_label.text = "Kosten: " + item.cost.to_display_string() + " Credits"
	else:
		cost_label.text = "Kosten: " + item.cost.to_display_string() + " RP"
	vbox.add_child(cost_label)
	var buy_btn = Button.new()
	if item.is_purchased:
		buy_btn.text = "✓ Erforscht"
		buy_btn.disabled = true
	elif item.cost_in_credits and credits.is_less_than(item.cost):
		buy_btn.text = "Zu wenig Credits"
		buy_btn.disabled = true
	elif not item.cost_in_credits and research_points.is_less_than(item.cost) and not item.cost.is_zero():
		buy_btn.text = "Zu wenig RP"
		buy_btn.disabled = true
	else:
		buy_btn.text = "Erforschen"
		buy_btn.pressed.connect(on_purchase.bind(item))
	vbox.add_child(buy_btn)
	grid.add_child(container)

func _can_see(item: ResearchDefinition, all_research: Array) -> bool:
	if item.requires.is_empty():
		return true
	for req_id in item.requires:
		var found = false
		for other in all_research:
			if other.id == req_id and other.is_purchased:
				found = true
				break
		if not found:
			return false
	return true

func update_rp(research_points: BigNumber) -> void:
	rp_label.text = "Forschungspunkte: " + research_points.to_display_string()

func _on_back_pressed() -> void:
	emit_signal("back_pressed")
