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

var song_len_sec: float = 0.0

func _ready():
	var config: ConfigFile
	config = Parser.parse_ini(song_ini_path)

	album_control.texture = cover_image
	song_name_label.text = config.get_value("Song", "name")
	artist_label.text = config.get_value("Song", "artist")
	album_label.text = config.get_value("Song", "album")

	song_len_sec = config.get_value("Song", "song_length").to_int() / 1000.0
	print(song_len_sec)
	
	var song_chart = Parser.parse_chart(song_chart_path)
	print(song_chart.get_value("Song", "Name"))

