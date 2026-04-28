# BeatClock.gd
# Autoload this node (Project > Project Settings > Autoload) as "BeatClock"
# It owns the BPM timeline and fires signals that any node can listen to.

extends Node

signal beat_fired(beat_number: int)
signal bar_fired(bar_number: int)   # every 4 beats

@export var bpm: float = 120.0
@export var beats_per_bar: int = 4
@export var autostart: bool = true

var is_running: bool = false
var beat_number: int = 0
var bar_number: int = 0

var _beat_accumulator: float = 0.0

func _ready() -> void:
	if autostart:
		start()

func start() -> void:
	is_running = true
	_beat_accumulator = 0.0
	beat_number = 0
	bar_number = 0

func stop() -> void:
	is_running = false

func set_bpm(new_bpm: float) -> void:
	bpm = new_bpm

## How far (0.0–1.0) we are between the last beat and the next one.
func beat_progress() -> float:
	return _beat_accumulator / beat_interval()

## Seconds between beats at current BPM.
func beat_interval() -> float:
	return 60.0 / bpm

func _process(delta: float) -> void:
	if not is_running:
		return

	_beat_accumulator += delta
	var interval := beat_interval()

	while _beat_accumulator >= interval:
		_beat_accumulator -= interval
		beat_number += 1
		emit_signal("beat_fired", beat_number)
		if beat_number % beats_per_bar == 0:
			bar_number += 1
			emit_signal("bar_fired", bar_number)
