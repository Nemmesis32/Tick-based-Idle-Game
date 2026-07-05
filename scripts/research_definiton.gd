class_name ResearchDefinition
extends Resource


@export var id: String = ""
@export var display_name: String = ""
var cost: BigNumber = BigNumber.from_float(0.0)
var cost_in_credits: bool = false
@export var requires: Array = []
@export var is_purchased: bool = false
