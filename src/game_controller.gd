extends CanvasLayer

@export_file("*.ini")
var song_ini_path := ""
@export_file("*.chart")
var song_chart_path := ""
@export var cover_image: Texture2D

@onready var song_name_label: Label = %Song
@onready var artist_label: Label = %Artist
@onready var album_label: Label = %Album
@onready var album_control: TextureRect = %AlbumControl

@onready var note_world: Node3D = %NoteWorld

var song_len_sec: float = 0.0
var tick_count: int = 0
var song_chart: Dictionary
var game_mode: String = "HardSingle"
var timings: Array

var secs_passed: float = 0.0

var bpm: float = 120.0
var resolution: int = 192

var bpm_start_tick: int = 0
var bpm_start_time: float = 0.0

var song_start_time: float = 0.0

func _ready():
	var config: ConfigFile
	config = Parser.parse_ini(song_ini_path)

	album_control.texture = cover_image
	song_name_label.text = config.get_value("Song", "name")
	artist_label.text = config.get_value("Song", "artist")
	album_label.text = config.get_value("Song", "album")
	
	song_len_sec = config.get_value("Song", "song_length").to_int() / 1000.0
	print(song_len_sec)
	
	song_chart = Parser.parse_chart_to_dict(song_chart_path)
	print(song_chart["Song"]["Name"])
	
	timings = song_chart[game_mode]
	timings.reverse()

	song_start_time = Time.get_ticks_msec() / 1000.0
	set_next_note_to_spawn()

@warning_ignore("unused_parameter")
func _physics_process(delta):
	pass

# ticks = (delta_seconds / (60 / {beats / minute}) * resolution) + ticks_bpm
func ticks_to_secs(ticks: int) -> float:
# {
#    float secondsPerBeat = 60 / currentBPM;
#    float deltaTicks = ticks - bpmStartTick;
#    float deltaBeats = deltaTicks / resolution;
#    float deltaSeconds = deltaBeats * secondsPerBeat;
#    return deltaSeconds + bpmStartTime;
# }
	var sec_per_beat: float = 60 / bpm
	var delta_ticks: float = ticks - bpm_start_tick
	var delta_beats: float = delta_ticks / resolution
	var delta_seconds: float = delta_beats * sec_per_beat

	return delta_seconds + bpm_start_time

# seconds = ({60 / {beats / minute}} * {delta_ticks / resolution}) + seconds_bpm
func secs_to_ticks(secs: float) -> int:
# {
# 	float secondsPerBeat = 60 / currentBPM;
# 	float deltaSeconds = seconds - bpmStartTime;
# 	float deltaBeats = deltaSeconds / secondsPerBeat;
# 	float deltaTicks = deltaBeats * resolution;
# 	return deltaTicks + bpmStartTick;
# }
	var sec_per_beat: float = 60 / bpm
	var delta_seconds: float = secs - bpm_start_time
	var delta_beats = delta_seconds / sec_per_beat
	var delta_ticks = delta_beats * resolution
	return delta_ticks + bpm_start_tick

func set_next_note_to_spawn():
	if timings.is_empty():
		return
	var curr_timing: Array = timings.back()
	if !curr_timing:
		return
	var note_time = ticks_to_secs(curr_timing[0])
	print("Next: ", curr_timing[0], " ticks or ", note_time, " secs.")
	
	var wait_time = note_time - ((Time.get_ticks_msec() / 1000.0) - song_start_time)
	
	if wait_time > 0:
		print("Waiting: ", wait_time)
		%SpawnTimer.wait_time = wait_time
		%SpawnTimer.start()
		return

func _on_spawn_timer_timeout():
	var curr_timing: Array = timings.back()
	var note_time := ticks_to_secs(curr_timing[0])
	var curr_diff_time := ((Time.get_ticks_msec() / 1000.0) - song_start_time)
	var wait_time := note_time - curr_diff_time
	
	while wait_time < 0.017:
		var note: Array = curr_timing[1]
		print(curr_timing[0], " : ", note[1])
		
		if note[0] == "N":
			note_world.spawn_note(note[1])
		
		timings.pop_back()
		if timings.is_empty():
			break
		curr_timing = timings.back()
		note_time = ticks_to_secs(curr_timing[0])
		wait_time = note_time - curr_diff_time
	
	set_next_note_to_spawn()
