class_name Fraction extends RefCounted

var numerator: int = 1
var denominator: int = 1

static func gcd(a: int, b: int) -> int:
	while b != 0:
		var t := b
		b = a % b
		a = t
	return a

func _init(numerator: int, denominator: int):
	if denominator == 0:
		push_error("denominator can't be zero")
		return
	
	self.numerator = numerator
	self.denominator = denominator
	
	var divisor := gcd(numerator, denominator)

	if divisor > 1:
		self.numerator /= divisor
		self.denominator /= divisor
	
	if self.denominator < 0:
		self.numerator = -self.numerator
		self.denominator = -self.denominator
	

static func from_int(i: int) -> Fraction:
	return Fraction.new(i, 1)

static func zero() -> Fraction:
	return Fraction.new(0, 1)

static func one() -> Fraction:
	return Fraction.new(1, 1)

func add(other: Fraction) -> Fraction:
	if denominator == other.denominator:
		return Fraction.new(numerator + other.numerator, denominator)
	
	return Fraction.new(
		numerator * other.denominator + other.numerator * denominator, 
		denominator * other.denominator
	)

func negate() -> Fraction:
	return Fraction.new(-self.numerator, self.denominator)

func sub(other: Fraction) -> Fraction:
	return self.add(other.negate())

func multiply(other: Fraction) -> Fraction:
	return Fraction.new(
		self.numerator * other.numerator,
		self.denominator * other.denominator
	)

func inverse() -> Fraction:
	return Fraction.new(
		self.denominator,
		self.numerator
	)

func divide(other: Fraction) -> Fraction:
	return self.multiply(other.inverse())

func to_float() -> float:
	return float(numerator) / float(denominator)
