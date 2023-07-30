extends PanelContainer

var player: SongPlayer = null

@onready var title: Label = $VBoxContainer/HBoxContainer/Title
@onready var bpm: Label = $VBoxContainer/HBoxContainer/HBoxContainer/BPM
@onready var beat_length: Label = $VBoxContainer/HBoxContainer/HBoxContainer/BeatLength

@onready var time: Label = $VBoxContainer/HBoxContainer2/VBoxContainer/TimeDisplay/TimeSeconds
@onready var note_a_index: Label = $VBoxContainer/HBoxContainer2/VBoxContainer/NoteDisplayA/NoteIndex
@onready var note_b_index: Label = $VBoxContainer/HBoxContainer2/VBoxContainer/NoteDisplayB/NoteIndex
@onready var note_a_type: Label = $VBoxContainer/HBoxContainer2/VBoxContainer/NoteDisplayA/NoteType
@onready var note_b_type: Label = $VBoxContainer/HBoxContainer2/VBoxContainer/NoteDisplayB/NoteType

var active := false

func initialize(player: SongPlayer):
	self.player = player
	title.text = player.song.data.title
	bpm.text = "BPM: %s" % [player.song.data.bpm]
	beat_length.text = "Beat Length: %s" % [player.song.data.basic_note]
	time.text = "00:00.000"

func _process(delta):
	if not player or not active:
		return
	
	var time_seconds := player.song.get_playback_position()
	var minutes := int(floor(time_seconds / 60.0))
	var seconds := int(floor(time_seconds - float(minutes) * 60.0))
	var millis := int(1000.0 * (time_seconds - (float(minutes) * 60.0 + float(seconds))))
	
	time.text = "%02d:%02d.%03d" % [minutes, seconds, millis]
	
	var actions_a: Actions = player.song.actions[Song.Action.A]
	var actions_b: Actions = player.song.actions[Song.Action.B]
	
	note_a_index.text = str(actions_a.current_action)
	note_a_type.text = str(actions_a.get_current_action())
	note_b_index.text = str(actions_b.current_action)
	note_b_type.text = str(actions_b.get_current_action())

func activate():
	active = true
	visible = true

func deactivate():
	active = false
	visible = false

func _on_play_pressed():
	if not active:
		return
	
	player.toggle_pause()

func _on_back_pressed():
	if not active:
		return
	
	player.song.decrement_beat()

func _on_forward_pressed():
	if not active:
		return
	
	player.song.increment_beat()
