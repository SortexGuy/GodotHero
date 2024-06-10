extends Node3D

@export var note_scene : PackedScene = preload("res://src/note.tscn")
var spawn_points : Array[Node3D] = []

func _ready():
	var sp := %SpawnPoints.get_children()
	for p in sp:
		spawn_points.append(p as Node3D)

func spawn_note(note_type : int):
	if note_type < 0 or note_type >= spawn_points.size():
		return
		assert(false, "Note invalid")
	var note_spawn_point = spawn_points[note_type].global_transform.origin
	var note := note_scene.instantiate() as Node3D
	add_child(note)
	note.global_transform.origin = note_spawn_point

func _on_spawn_timer_timeout():
	return
	var pos := (spawn_points.pick_random() as Node3D).global_transform.origin
	var note := note_scene.instantiate() as Node3D
	add_child(note)
	note.global_transform.origin = pos
