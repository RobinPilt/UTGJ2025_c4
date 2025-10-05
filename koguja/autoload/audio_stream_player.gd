extends AudioStreamPlayer

var mainTheme = "res://assets/audio/Main-theme (2).wav"
var weddingTheme = "res://assets/audio/wedding-theme-maybe.wav"
var intenseTheme = "res://assets/audio/intense-theme.wav"

func _ready():
	$".".play()

func _ChangeTrack(trackType: String) -> void:
	#gets current track time
	var current_track_time = $".".get_playback_position()
	var targetTrack: String = _getTargetTrack(trackType)
	
	# Stop the current track
	$".".stop()
	# Assign the new stream if needed
	$".".stream = targetTrack

	# Start the new track at the same position
	$".".play(current_track_time)

func _getTargetTrack(trackType: String):
	if trackType == "main":
		return mainTheme
	elif trackType == "wedding":
		return weddingTheme
	else:
		return intenseTheme
