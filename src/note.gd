extends Node3D

func _process(delta):
	position.z += delta * 8
	if position.z > 10:
		queue_free()
