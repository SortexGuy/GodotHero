extends Node3D

@export var note_scene : PackedScene = preload("res://src/note.tscn")
var spawn_points : Array[Node3D] = []

func _ready():
	var sp := %SpawnPoints.get_children()
	for p in sp:
		spawn_points.append(p as Node3D)

func _on_spawn_timer_timeout():
	var pos := (spawn_points.pick_random() as Node3D).global_transform.origin
	var note := note_scene.instantiate() as Node3D
	add_child(note)
	note.global_transform.origin = pos
