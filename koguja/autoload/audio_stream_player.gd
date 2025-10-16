extends AudioStreamPlayer

var mainTheme = load("res://assets/audio/Main-theme (2).wav")
var weddingTheme = load("res://assets/audio/wedding-theme-maybe.wav")
var intenseTheme = load("res://assets/audio/intense-theme.wav")

func crossfade_to(new_stream: AudioStream, duration := 1.0):
	var active = $"." if $".".playing else $PlayerB
	var next = $PlayerB if active == $"." else $"."
	
	var current_track_time = active.get_playback_position()

	next.stream = new_stream
	next.volume_db = -10
	next.play(current_track_time)  # Start at same position

	var tween = create_tween()
	tween.tween_property(active, "volume_db", -10, duration)
	tween.tween_property(next, "volume_db", 0, duration)
	tween.tween_callback(Callable(active, "stop"))

func _ChangeTrack(trackType: String) -> void:
	var targetTrack: Object = _getTargetTrack(trackType)
	print_debug("attempted track change")
	crossfade_to(targetTrack)

func _getTargetTrack(trackType: String):
	if trackType == "main":
		return mainTheme
	elif trackType == "wedding":
		return weddingTheme
	else:
		return intenseTheme
