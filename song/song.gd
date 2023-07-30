class_name Song extends AudioStreamPlayer

enum Action {
	A,B
}

signal note(action: Action, index: int, beat_fraction: Fraction)
signal rest(action: Action, index: int,beat_fraction: Fraction)
signal incremented(action: Action, last_sign: Sign, new_sign: Sign, last_index: int, new_index: int)
signal lost_note(action: Action, note: Note, index: int)

@export var offset: float = 0.0

@export_file() var file: String

var data: Parser.SongData = null
var actions := {}

var do_seek := false
var seek_to := 0.0

func _ready():
	var file_access := FileAccess.open(file, FileAccess.READ)
	var content := file_access.get_as_text(true)
	var data := Parser.parse(content)
	actions[Action.A] = Actions.new(data.bpm, data.basic_note, data.a.data)
	actions[Action.B] = Actions.new(data.bpm, data.basic_note, data.b.data)
	self.data = data 

func _process(delta):
	if not playing:
		return
	
	if playing and not stream_paused and do_seek:
		seek(seek_to)
		do_seek = false
	
	var current_time := get_current_time()
	if current_time < 0:
		return
	
	for action in Action:
		process_action(Action[action], current_time)

func process_action(action: Action, current_time: float):
	var current_actions: Actions = actions[action]
	
	while not current_actions.time_before_current_end(current_time):
		var last = current_actions.get_last_note()
		var last_index = current_actions.get_last_note_index()
		
		current_actions.increment_action()
		var current := current_actions.get_current_action()
		var current_index := current_actions.get_current_index()
		if current:
			if current is Note:
				note.emit(action, current_index, current.fraction())
			if current is Rest:
				rest.emit(action, current_index, current.fraction())
		
		incremented.emit(
			action, 
			current, 
			current_actions.get_current_action(), 
			current_index, 
			current_actions.get_current_index()
		)
		var new_last = current_actions.get_last_note()
		if new_last != last:
			lost_note.emit(action, last, last_index)
	
	var last_start := current_actions.last_note_start_seconds()
	var max_deviation := Constants.max_deviation(data.bpm)
	if last_start >= 0.0 and abs(current_time - last_start) > max_deviation:
		lost_note.emit(action, current_actions.get_last_note(), current_actions.get_last_note_index())

func reset():
	stop()
	seek(0.0)
	for action in Action:
		actions[Action[action]].reset()

func get_current_time() -> float:
	var current_time := get_playback_position()
	current_time += AudioServer.get_time_since_last_mix()
	current_time -= AudioServer.get_output_latency()
	current_time -= offset
	return current_time

func hit(action: Action, ignore_indices: Array = []) -> Actions.Hit:
	var current_actions: Actions = actions[action]
	return current_actions.get_hit(get_current_time(), ignore_indices)

func decrement_beat():
	var start_a: float = actions[Action.A].last_action_start()
	var start_b: float = actions[Action.B].last_action_start()
	
	seek_to = 0.0
	
	if start_a == start_b:
		seek_to = offset + start_a + 0.0001
		actions[Action.A].decrement_broken()
		actions[Action.B].decrement_broken()
	elif start_a > start_b:
		seek_to = offset + start_a + 0.0001
		actions[Action.A].decrement_broken()
	else:
		seek_to = offset + start_b + 0.0001
		actions[Action.B].decrement_broken()
	
	if playing and not stream_paused:
		seek(seek_to)
	else:
		do_seek = true
	
	for action in Action:
		process_action(Action[action], seek_to)

func increment_beat():
	var end_a = actions[Action.A].current_action_end()
	var end_b = actions[Action.B].current_action_end()
	
	if end_a == null or end_b == null:
		return
	
	seek_to = 0.0
	
	if end_a < end_b:
		seek_to = offset + end_a + 0.0001
	else:
		seek_to = offset + end_b + 0.0001
	
	if playing and not stream_paused:
		seek(seek_to)
	else:
		do_seek = true
	
	for action in Action:
		process_action(Action[action], seek_to)
