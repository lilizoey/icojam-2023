class_name Song extends AudioStreamPlayer

enum Action {
	A,B
}

signal note(action: Action, beat_fraction: Fraction)
signal rest(action: Action, beat_fraction: Fraction)
signal incremented(action: Action, last_sign: Sign, new_sign: Sign, last_index: int, new_index: int)
signal lost_note(action: Action, note: Note, index: int)

@export var offset: float = 0.0

@export_file() var file: String

var actions := {}

func _ready():
	var file_access := FileAccess.open(file, FileAccess.READ)
	var content := file_access.get_as_text(true)
	var data := Parser.parse(content)
	actions[Action.A] = Actions.new(data.bpm, data.basic_note, data.a.data)
	actions[Action.B] = Actions.new(data.bpm, data.basic_note, data.b.data)

func _process(delta):
	if not playing:
		return
	
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
				note.emit(action, current.fraction())
			if current is Rest:
				rest.emit(action, current.fraction())
		
		incremented.emit(
			action, 
			current, 
			current_actions.get_current_action(), 
			current_index, 
			current_actions.get_current_index()
		)
		var new_last = current_actions.get_last_note()
		if last and last != new_last:
			lost_note.emit(action, last, last_index)

func reset():
	stop()
	seek(0.0)
	for action in Action:
		actions[Action[action]].reset()

func get_current_time() -> float:
	var current_time := get_playback_position()
	current_time -= offset
	return current_time

func hit(action: Action, ignore_indices: Array = []) -> Actions.Hit:
	var current_actions: Actions = actions[action]
	return current_actions.get_hit(get_current_time(), ignore_indices)
	
