extends Node2D

@export var corrupt_areas: Array[Area2D] = []


func finishcheck() -> bool:
	for area in corrupt_areas:
		if area == null:
			continue
		if not area.defeated:
			return false
	return true
