class_name Sign extends Resource

enum Value {
	Whole,
	Half,
	Quarter,
	Eight,
	Sixteenth,
}

@export var numerator: int = 1
@export var denominator: int = 4

func _init(fraction: Fraction = Fraction.zero()):
	self.numerator = fraction.numerator
	self.denominator = fraction.denominator

static func whole_time(beat_value: Value, bpm: int) -> float:
	var whole_time: float = 60.0 / bpm
	
	match beat_value:
		Value.Half:
			whole_time *= 2.0
		Value.Quarter:
			whole_time *= 4.0
		Value.Eight:
			whole_time *= 8.0
		Value.Sixteenth:
			whole_time *= 16.0
	
	return whole_time

static func value_to_fraction(beat_value: Value) -> Fraction:
	match beat_value:
		Value.Whole:
			return Fraction.one()
		Value.Half:
			return Fraction.new(1,2)
		Value.Quarter:
			return Fraction.new(1,4)
		Value.Eight:
			return Fraction.new(1,8)
		Value.Sixteenth:
			return Fraction.new(1,16)
	
	push_error(beat_value, " is not a valid beat value")
	return Fraction.zero()

func end_time(start_time: float, beat_value: Value, bpm: int) -> float:
	var whole_time := whole_time(beat_value, bpm)
	
	var note_length := float(numerator) * whole_time / float(denominator)
	
	return start_time + note_length

func fraction() -> Fraction:
	return Fraction.new(numerator, denominator)

func set_fraction(fraction: Fraction):
	self.numerator = fraction.numerator
	self.denominator = fraction.denominator
