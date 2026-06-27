extends RefCounted

class_name BigNumber

var mantissa : float = 0.0
var exponent : int = 0

const SUFFIXES = [
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No",
	"Dc", "UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "OcDc", "NoDc",
	"Vg"
]

static func from_notation(m: float, e: int) -> BigNumber:
	var result = BigNumber.new()
	result.mantissa = m
	result.exponent = e
	result._normalize()
	return result


func _init(m: float = 0.0, e: int = 0):
	mantissa = m
	exponent = e
	_normalize()


func _normalize() -> void:
	if mantissa == 0.0:
		exponent = 0
		return

	var negative = mantissa < 0
	if negative:
		mantissa = -mantissa

	while mantissa >= 10.0:
		mantissa /= 10.0
		exponent += 1
	while mantissa < 1.0 and mantissa != 0.0:
		mantissa *= 10.0
		exponent -= 1

	if negative:
		mantissa = -mantissa


static func from_float(value: float) -> BigNumber:
	var result = BigNumber.new()
	result.mantissa = value
	result.exponent = 0
	result._normalize()
	return result


func to_float() -> float:
	# Nur sicher für kleine Exponenten! Für UI-Zwecke meiden.
	return mantissa * pow(10.0, exponent)


func add(other: BigNumber) -> BigNumber:
	var result = BigNumber.new()

	if exponent == other.exponent:
		result.mantissa = mantissa + other.mantissa
		result.exponent = exponent
		result._normalize()
		return result

	var bigger = self if exponent > other.exponent else other
	var smaller = other if exponent > other.exponent else self

	var diff = bigger.exponent - smaller.exponent
	if diff > 15:
		result.mantissa = bigger.mantissa
		result.exponent = bigger.exponent
		result._normalize()
		return result

	var adjusted_small = smaller.mantissa / pow(10.0, diff)
	result.mantissa = bigger.mantissa + adjusted_small
	result.exponent = bigger.exponent
	result._normalize()
	return result


func subtract(other: BigNumber) -> BigNumber:
	var negated = BigNumber.new()
	negated.mantissa = -other.mantissa
	negated.exponent = other.exponent
	return add(negated)


func multiply(other: BigNumber) -> BigNumber:
	var result = BigNumber.new()
	result.mantissa = mantissa * other.mantissa
	result.exponent = exponent + other.exponent
	result._normalize()
	return result


func multiply_float(factor: float) -> BigNumber:
	var result = BigNumber.new()
	result.mantissa = mantissa * factor
	result.exponent = exponent
	result._normalize()
	return result


func divide(other: BigNumber) -> BigNumber:
	var result = BigNumber.new()
	if other.mantissa == 0.0:
		push_error("BigNumber: Division durch Null")
		result.mantissa = 0.0
		result.exponent = 0
		return result
	result.mantissa = mantissa / other.mantissa
	result.exponent = exponent - other.exponent
	result._normalize()
	return result


func divide_float(divisor: float) -> BigNumber:
	var result = BigNumber.new()
	result.mantissa = mantissa / divisor
	result.exponent = exponent
	result._normalize()
	return result


func compare(other: BigNumber) -> int:
	# Nullcheck zuerst
	if mantissa == 0.0 and other.mantissa == 0.0:
		return 0
	if mantissa == 0.0:
		return -1
	if other.mantissa == 0.0:
		return 1
	# Dann Exponent vergleichen
	if exponent != other.exponent:
		return -1 if exponent < other.exponent else 1
	if mantissa == other.mantissa:
		return 0
	return -1 if mantissa < other.mantissa else 1


func is_greater_than(other: BigNumber) -> bool:
	return compare(other) > 0


func is_less_than(other: BigNumber) -> bool:
	return compare(other) < 0


func is_greater_or_equal(other: BigNumber) -> bool:
	return compare(other) >= 0


func is_less_or_equal(other: BigNumber) -> bool:
	return compare(other) <= 0


func is_equal(other: BigNumber) -> bool:
	return compare(other) == 0


func is_zero() -> bool:
	return mantissa == 0.0


func min_with(other: BigNumber) -> BigNumber:
	return self if is_less_or_equal(other) else other


func max_with(other: BigNumber) -> BigNumber:
	return self if is_greater_or_equal(other) else other


func to_display_string() -> String:
	if mantissa == 0.0:
		return "0"

	if exponent < 3:
		var value = mantissa * pow(10.0, exponent)
		# Auch für kleine Zahlen: nur nötige Nachkommastellen
		if int(value) == value:
			return "%d" % int(value)
		elif int(value * 10) == value * 10:
			return "%.1f" % value
		else:
			return "%.2f" % value

	@warning_ignore("integer_division")
	var suffix_index = exponent / 3
	var remainder = exponent % 3

	if suffix_index >= SUFFIXES.size():
		return "%.2fe%d" % [mantissa, exponent]

	var display_value = mantissa * pow(10.0, remainder)
	var suffix = SUFFIXES[suffix_index]

	# Intelligente Nachkommastellen
	if int(display_value) == display_value:
		return "%d%s" % [int(display_value), suffix]
	elif int(display_value * 10) == display_value * 10:
		return "%.1f%s" % [display_value, suffix]
	else:
		return "%.2f%s" % [display_value, suffix]
		
