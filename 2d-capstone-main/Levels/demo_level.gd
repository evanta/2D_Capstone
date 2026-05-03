extends Node2D

@export var corrupt_areas: Array[Area2D] = []

func finishcheck():
	for areas in corrupt_areas:
		if areas.defeated == false:
			return(false)
	return(true)
