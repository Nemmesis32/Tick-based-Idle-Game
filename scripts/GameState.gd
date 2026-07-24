extends Node
 
var credits : BigNumber = BigNumber.from_float(2000000000000.0)
var research_points : BigNumber = BigNumber.from_float(0.0)
var research : Array[ResearchDefinition] = []
 
var ticks_per_second : int = 1
var is_paused : bool = false
var is_fast : bool = false
var bonus_ticks : int = 5000
var bonus_ticks_running : bool = false
var auto_rebuild_enabled : bool = true
 
 
func _ready() -> void:
	research = ResearchDatabase.get_all_research()
 
 
func is_researched(research_id: String) -> bool:
	for item in research:
		if item.id == research_id and item.is_purchased:
			return true
	return false
 
 
func purchase_research(item: ResearchDefinition) -> bool:
	if item.is_purchased:
		return false
	if item.cost_in_credits:
		if credits.is_less_than(item.cost):
			return false
		credits = credits.subtract(item.cost)
	else:
		if not item.cost.is_zero() and research_points.is_less_than(item.cost):
			return false
		research_points = research_points.subtract(item.cost)
	item.is_purchased = true
	if item.id in ["chromatic_1", "chromatic_2", "chromatic_3", "chromatic_4", "chromatic_5"]:
		ticks_per_second += 1
	return true
 
 
func add_research_points(amount: BigNumber) -> void:
	research_points = research_points.add(amount)
 
