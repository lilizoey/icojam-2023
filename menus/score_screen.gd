extends PanelContainer

const ACCURACY_PERCENT := {
	Constants.Accuracy.Perfect: 100.0,
	Constants.Accuracy.Good: 66.7,
	Constants.Accuracy.Ok: 33.3,
	Constants.Accuracy.Miss: 0.0,
}

@onready var perfect: Label = $HBoxContainer/VBoxContainer/Perfect/Total
@onready var good: Label = $HBoxContainer/VBoxContainer/Good/Total
@onready var ok: Label = $HBoxContainer/VBoxContainer/Ok/Total
@onready var miss: Label = $HBoxContainer/VBoxContainer/Miss/Total
@onready var total: Label = $HBoxContainer/VBoxContainer/TotalHits/Total
@onready var total_percent: Label = $HBoxContainer/VBoxContainer/TotalHits/Percent

func display(hit_data: Dictionary):
	var score_display := {
		Constants.Accuracy.Perfect: 0,
		Constants.Accuracy.Good: 0,
		Constants.Accuracy.Ok: 0,
		Constants.Accuracy.Miss: 0,
		"total_hits": 0,
		"total": 0,
		"percent_accumulated": 0.0
	}
	
	for data in hit_data.values():
		calculate_display(data.values(), score_display)
	
	perfect.text = str(score_display[Constants.Accuracy.Perfect])
	good.text = str(score_display[Constants.Accuracy.Good])
	ok.text = str(score_display[Constants.Accuracy.Ok])
	miss.text = str(score_display[Constants.Accuracy.Miss])
	total.text = "%d/%d" % [score_display.total_hits, score_display.total]
	total_percent.text = "%02.2f%%" % [score_display.percent_accumulated / float(score_display.total)]
	visible = true

func calculate_display(hit_data: Array[Actions.Hit], display: Dictionary):
	for data in hit_data:
		display.total += 1
		
		var acc
		if data:
			acc = data.accuracy
		else:
			acc = Constants.Accuracy.Miss
		
		display[acc] += 1
		display.percent_accumulated += ACCURACY_PERCENT[acc]
		if acc != Constants.Accuracy.Miss:
			display.total_hits += 1
	
