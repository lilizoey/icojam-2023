class_name Rest extends Sign

func _to_string():
	if numerator != 1:
		return "%d/%d rest" % [numerator, denominator]
	
	match denominator:
		1:
			return "whole rest"
		2:
			return "half rest"
		4:
			return "quarter rest"
		8:
			return "eight rest"
		16:
			return "sixteenth rest"
	
	return "%d/%d rest" % [numerator, denominator]
