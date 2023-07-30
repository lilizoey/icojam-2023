class_name Constants extends Object

enum FullAccuracy {
	EarlyMiss,
	EarlyOk,
	EarlyGood,
	Perfect,
	LateGood,
	LateOk,
	LateMiss,
}

enum EarlyLate {
	Early,
	Late,
}

enum Accuracy {
	Perfect,
	Good,
	Ok,
	Miss,
}

static func accuracy_from_full(full: FullAccuracy) -> Accuracy:
	match full:
		FullAccuracy.EarlyMiss:
			return Accuracy.Miss
		FullAccuracy.EarlyOk:
			return Accuracy.Ok
		FullAccuracy.EarlyGood:
			return Accuracy.Good
		FullAccuracy.Perfect:
			return Accuracy.Perfect
		FullAccuracy.LateGood:
			return Accuracy.Good
		FullAccuracy.LateOk:
			return Accuracy.Ok
		FullAccuracy.LateMiss:
			return Accuracy.Miss
	
	push_error(full, " is not a valid accuracy")
	return Accuracy.Miss

static func accuracy_to_full(accuracy: Accuracy, early_late: EarlyLate) -> FullAccuracy:
	match [accuracy, early_late]:
		[Accuracy.Miss, EarlyLate.Early]:
			return FullAccuracy.EarlyMiss
		[Accuracy.Ok, EarlyLate.Early]:
			return FullAccuracy.EarlyOk
		[Accuracy.Good, EarlyLate.Early]:
			return FullAccuracy.EarlyGood
		[Accuracy.Perfect, EarlyLate.Early]:
			return FullAccuracy.Perfect
		[Accuracy.Perfect, EarlyLate.Late]:
			return FullAccuracy.Perfect
		[Accuracy.Good, EarlyLate.Late]:
			return FullAccuracy.LateGood
		[Accuracy.Ok, EarlyLate.Late]:
			return FullAccuracy.LateOk
		[Accuracy.Miss, EarlyLate.Late]:
			return FullAccuracy.LateMiss
	
	push_error(accuracy, ", ", early_late, " is not a valid accuracy")
	return FullAccuracy.LateMiss

const ACCURACY_BASE := {
	Accuracy.Perfect: 0.080,
	Accuracy.Good: 0.140,
	Accuracy.Ok: 0.200,
	Accuracy.Miss: 0.350,
}

const ACCURACY_MUL := {
	Accuracy.Perfect: 0.2,
	Accuracy.Good: 0.2,
	Accuracy.Ok: 0.2,
	Accuracy.Miss: 0.0,
}

const ACCURACY_BASE_BPM: int = 80

static func hit_range(accuracy: Accuracy, bpm: int) -> float:
	var diff: int = max(bpm - ACCURACY_BASE_BPM, 0)
	var r = ACCURACY_BASE[accuracy] - (float(diff) / 1000.0) * ACCURACY_MUL[accuracy] 
	return r

static func get_hit(hit_time: float, target_time: float, bpm: int):
	var diff: float = abs(hit_time - target_time)
	var accuracy = null
	
	for acc in Accuracy:
		var hit_range := hit_range(Accuracy[acc], bpm)
		if diff < hit_range:
			accuracy = Accuracy[acc]
			break
	
	if accuracy == null:
		return null
	
	var early_late: EarlyLate
	
	if hit_time < target_time:
		early_late = EarlyLate.Early
	else:
		early_late = EarlyLate.Late
	
	return accuracy_to_full(accuracy, early_late)

static func max_deviation(bpm: int) -> float:
	var dev: float = 0.0
	
	for acc in Accuracy:
		var hit_range := hit_range(Accuracy[acc], bpm)
		if dev < hit_range:
			dev = hit_range
	
	return dev
