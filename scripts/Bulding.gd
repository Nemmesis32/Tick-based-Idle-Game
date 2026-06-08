extends RefCounted

class_name Building

var definition : BuildingDefinition

var current_heat := 0.0
var current_water := 0.0

var age := 0


func _init(p_definition : BuildingDefinition):

	definition = p_definition
