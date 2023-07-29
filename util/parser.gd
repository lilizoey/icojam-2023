class_name Parser extends Object

static func parse(contents: String) -> SongData:
	var lines := contents.split("\n")
	var metadata := {}
	
	var section_a := 0
	var section_b := 0
	
	for i in range(0, lines.size()):
		if lines[i].begins_with("A:"):
			section_a = i
		if lines[i].begins_with("B:"):
			section_b = i
	
	var bpm = int(lines[0])
	var basic_note = lines[1]
	
	var data_a: Array[String] = []
	for i in range(section_a + 1, section_b):
		var line := lines[i]
		if line.strip_edges().begins_with("#"):
			continue
		line = line.replace("|", " ")
		data_a.append_array(line.split(" ")) 
	
	var data_b: Array[String] = []
	for i in range(section_b + 1, lines.size()):
		var line := lines[i]
		if line.strip_edges().begins_with("#"):
			continue
		line = line.replace("|", " ")
		data_b.append_array(line.split(" ")) 
		
		
	var data_track_a: DataTrack = DataTrack.new(basic_note, data_a)
	var data_track_b: DataTrack = DataTrack.new(basic_note, data_b)
	
	return SongData.new(bpm, data_track_a.basic_note, data_track_a, data_track_b)

class DataTrack:
	var basic_note: Fraction
	var data: Array[Sign]
	
	func _init(basic_note: String, data: Array[String]):
		var basic = basic_note.split("/")
		self.basic_note = Fraction.new(int(basic[0]), int(basic[1]))
		
		var data_arr: Array[Sign] = []
		
		for sign_text in data:
			var trimmed := sign_text.strip_edges()
			if trimmed.is_empty():
				continue
			
			var sign: Sign
			
			if trimmed.begins_with("N"):
				sign = Note.new(self.basic_note)
			if trimmed.begins_with("R"):
				sign = Rest.new(self.basic_note)
			
			if trimmed.length() == 1:
				data_arr.append(sign)
				continue
			
			var split := trimmed.split("/")
			if split.size() == 1:
				var fraction := Fraction.from_int(int(split[0].substr(1)))
				sign.set_fraction(sign.fraction().multiply(fraction))
				data_arr.append(sign)
				continue
			
			var denominator := int(split[1])
			
			var numerator = split[0].substr(1)
			
			if numerator.is_empty():
				var fraction := Fraction.new(1, denominator)
				sign.set_fraction(sign.fraction().multiply(fraction))
				data_arr.append(sign)
				continue
			else:
				numerator = int(numerator)
				var fraction := Fraction.new(numerator, denominator)
				sign.set_fraction(fraction)
				data_arr.append(sign)
				continue
			
			print("error parsing ", sign_text)
		
		self.data = data_arr

class SongData:
	var bpm: int
	var basic_note: Fraction
	var a: DataTrack
	var b: DataTrack
	
	func _init(bpm: int, basic_note: Fraction, a: DataTrack, b: DataTrack):
		self.bpm = bpm
		self.basic_note = basic_note
		self.a = a
		self.b = b
