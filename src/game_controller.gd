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
var song_chart: ConfigFile
var game_mode: String = "MediumSingle"
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
	
	song_chart = Parser.parse_chart(song_chart_path)
	print(song_chart.get_value("Song", "Name"))

	timings = song_chart.get_value(game_mode, "Data")
	timings.reverse()

	song_start_time = Time.get_ticks_msec() / 1000.0
	pass

func _physics_process(delta):
	#float noteTime = TicksToSeconds(note.tick);  // Convert tick to time
	#float waitTime = noteTime - (Time.time - songStartTime);  // Calculate how long to wait
	#if (waitTime > 0) {
		#yield return new WaitForSeconds(waitTime);  // Wait for the right time to spawn the note
	#}
	#SpawnNote(note);  // Spawn the note
	#var note_time = ticks_to_secs()
	#
	#
	#await get_tree().create_timer(wait_time)	
	
	#var curr_timing: Array = timings.back()
	# print(curr_timing, " : ", tick_count)
	#if tick_count >= curr_timing[0].to_int():
		#var note = curr_timing[1]
		#print(curr_timing[0], note)
		#timings.pop_back()
	#
	#var wait_time := 0.0
	#await get_tree().create_timer(wait_time)
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
