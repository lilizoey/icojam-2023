class_name Actions extends RefCounted

var bpm: int = 0
var beat_length: Fraction = Fraction.one()
var actions: Array[Sign] = []

var current_action: int = 0
var time_passed: Fraction = Fraction.zero()
var last_note: int = -1
var next_note: int = -1

func _init(bpm: int, beat_length: Fraction, actions: Array[Sign]):
	self.bpm = bpm
	self.beat_length = beat_length
	self.actions = actions
	reset()

func reset():
	current_action = 0
	time_passed = Fraction.zero()
	if not actions.is_empty():
		if actions[0] is Note:
			last_note = 0
	
	for i in range(1, actions.size()):
		if actions[i] is Note:
			next_note = i
			break

func whole_length_seconds() -> float:
	return beat_length_seconds() / beat_length.to_float()

func value_length_seconds(note_value: Fraction) -> float:
	return whole_length_seconds() * note_value.to_float()

func beat_length_seconds() -> float:
	return 60.0 / float(bpm)

func get_current_action() -> Sign:
	if current_action < actions.size():
		return actions[current_action]
	else:
		return null

func get_current_index() -> int:
	return current_action

func increment_action():
	var action := get_current_action()
	
	if not action:
		return
	
	time_passed = time_passed.add(action.fraction())
	current_action += 1
	
	action = get_current_action()
	if action and action is Note:
		last_note = current_action
	
	if next_note <= current_action:
		next_note = -1
		for i in range(current_action + 1, actions.size()):
			if actions[i] is Note:
				next_note = i
				break

func current_action_start() -> float:
	return time_passed.to_float() * whole_length_seconds()

func last_action_start() -> float:
	if current_action > 0:
		return time_passed.to_float() * whole_length_seconds() - actions[current_action - 1].fraction().to_float() * whole_length_seconds()
	else:
		return current_action_start()

func decrement_broken():
	if current_action > 0:
		time_passed = time_passed.sub(actions[current_action - 1].fraction())
		current_action -= 1

func has_reached_end() -> bool:
	return current_action >= actions.size()

func current_action_end():
	var action := get_current_action()
	
	if not action:
		return null
	
	return current_action_start() + action.fraction().to_float() * whole_length_seconds()

func get_last_note() -> Note:
	if last_note == -1:
		return null
	else:
		return actions[last_note]

func get_last_note_index() -> int:
	return last_note

func get_next_note() -> Note:
	if next_note == -1:
		return null
	else:
		return actions[next_note]

func get_next_note_index() -> int:
	return next_note

func remove_last_note():
	last_note = -1

func remove_next_note():
	var prev_next := next_note
	next_note = -1
	for i in range(prev_next + 1, actions.size()):
		if actions[i] is Note:
			next_note = i

func last_note_start() -> Fraction:
	if last_note == -1:
		return Fraction.from_int(-1)
	
	var current := time_passed
	var i := current_action - 1
	
	while i > last_note:
		current = current.sub(actions[i].fraction())
		i -= 1
	
	return current

func last_note_start_seconds() -> float:
	return last_note_start().to_float() * whole_length_seconds()

func next_note_start() -> Fraction:
	if next_note == -1:
		return Fraction.from_int(-1)
	
	var current := time_passed
	var i := current_action
	
	while i < next_note:
		current = current.add(actions[i].fraction())
		i += 1
	
	return current

class Hit:
	var index: int = -1
	var note: Note = null
	var accuracy: Constants.FullAccuracy
	var exact_deviation: float = 0.0
	
	func _init(
		index: int = -1, 
		note: Note = null, 
		accuracy: Constants.FullAccuracy = Constants.FullAccuracy.LateMiss,
		exact_deviation: float = 0.0
		):
		self.index = index
		self.note = note
		self.accuracy = accuracy
		self.exact_deviation = exact_deviation
	
	func is_hit() -> bool:
		return index != -1
	
	func _to_string():
		return "Hit(%d, %s, %s, %f)" % [self.index, self.note, self.accuracy, self.exact_deviation]

func get_hit(hit_time: float, ignore_indices: Array = []) -> Hit:
	var max_deviation := Constants.max_deviation(bpm)
	var last := get_last_within(max_deviation, hit_time, ignore_indices)
	var next := get_next_within(max_deviation, hit_time, ignore_indices)
	
	if not last and not next:
		return Hit.new()
	
	var last_diff
	var next_diff
	
	if last:
		last_diff = abs(last.start_time_seconds - hit_time)
	
	if next:
		next_diff = abs(next.start_time_seconds - hit_time)
	
	var hit_index = -1
	var note = null
	var accuracy = Constants.FullAccuracy.LateMiss
	var exact_deviation = 0.0
	
	if last and (not next or last_diff <= next_diff):
		var hit = Constants.get_hit(hit_time, last.start_time_seconds, bpm)
		if hit:
			hit_index = last.index
			note = last.action
			accuracy = hit
			exact_deviation = last_diff
	if next and (not last or next_diff < last_diff):
		var hit = Constants.get_hit(hit_time, next.start_time_seconds, bpm)
		if hit:
			hit_index = next.index
			note = next.action
			accuracy = hit
			exact_deviation = -next_diff
	
	return Hit.new(hit_index, note, accuracy, exact_deviation)

func time_before_current_end(time: float) -> bool:
	var current_end = current_action_end()
	
	if not current_end:
		return true
	
	return time <= current_end

func get_last_within(within: float, hit_time: float, ignore_indices: Array = []) -> Dictionary:
	var max_deviation := Constants.max_deviation(bpm)
	var time := time_passed
	
	for i in range(current_action, 0, -1):
		var action := get_current_action()
		
		if i in ignore_indices:
			if action:
				time = time.sub(action.fraction())
			continue
		
		var dict = get_within(within, hit_time, i, time)
		if dict == null:
			return {}
		if dict.action is Note:
			return dict
		if action:
			time = time.sub(action.fraction())
	
	return {}

func get_next_within(within: float, hit_time: float, ignore_indices: Array = []) -> Dictionary:
	var time := time_passed
	if get_current_action():
		time = time.add(get_current_action().fraction())
	
	for i in range(current_action + 1, actions.size()):
		var action := get_current_action()
		
		if i in ignore_indices:
			time = time.add(action.fraction())
			continue
		
		var dict = get_within(within, hit_time, i, time)
		if dict == null:
			return {}
		if dict.action is Note:
			return dict
		
		time = time.add(action.fraction())
	
	return {}

func get_within(within: float, hit_time: float, index: int, index_time: Fraction):
	var index_seconds := index_time.to_float() * whole_length_seconds()
	if abs(index_seconds - hit_time) <= within:
		var action = null
		if index < actions.size():
			action = actions[index]
		return {
			"index": index,
			"action": action,
			"start_time": index_time,
			"start_time_seconds": index_seconds,
			"abs_diff_seconds": abs(index_seconds - hit_time),
		}
	else:
		return null
