class_name Note extends Sign

func _to_string():
	if numerator != 1:
		return "%d/%d note" % [numerator, denominator]
	
	match denominator:
		1:
			return "whole note"
		2:
			return "half note"
		4:
			return "quarter note"
		8:
			return "eight note"
		16:
			return "sixteenth note"
	
	return "%d/%d note" % [numerator, denominator]
