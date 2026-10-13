extends TileMapLayer

@onready var track1 = $AlmaMater
@onready var track2 = $FightSong
@onready var quiz_track = $QuizMusic

var last_played_track: AudioStreamPlayer
var active_track: AudioStreamPlayer
var game_started: bool = false

func _ready() -> void:
	track1.finished.connect(_play_track_2)
	track2.finished.connect(_play_track_1)
	
	# NOTE: It's best to call start_music() from a UI button press 
	# to guarantee the browser allows audio playback!
	start_music()

func start_music() -> void:
	if game_started: return
	game_started = true
	
	if randf() > 0.5:
		track1.play()
		last_played_track = track1
	else:
		track2.play()
		last_played_track = track2

# Call this when a Quiz starts
func _on_quiz_started() -> void:
	if active_track != quiz_track:
		if last_played_track and last_played_track.playing:
			# Pause instead of stopping; this preserves the position automatically
			last_played_track.stream_paused = true
		
		quiz_track.play()
		active_track = quiz_track

# Call this when the Quiz is closed
func _on_quiz_finished() -> void:
	quiz_track.stop()
	active_track = null
	
	if last_played_track:
		# Unpause it, no need to pass a resume_position float
		last_played_track.stream_paused = false

func _play_track_1():
	print("Track 2 finished, switching to Track 1")
	track1.stream_paused = false
	track1.play()
	last_played_track = track1

func _play_track_2():
	print("Track 1 finished, switching to Track 2")
	track2.stream_paused = false
	track2.play()
	last_played_track = track2
