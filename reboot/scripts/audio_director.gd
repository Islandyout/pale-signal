class_name AudioDirector
extends Node

# Procedural, zero-asset audio bed for the production reboot. This is deliberately
# isolated from gameplay state: it observes the live controllers and input state
# and never drives mechanics, saves, tutorial completion, or progression.

const MIX_RATE := 11025.0
const BUFFER_LENGTH := 0.35

var _ambient_player: AudioStreamPlayer
var _engine_player: AudioStreamPlayer
var _sensor_player: AudioStreamPlayer
var _ambient_playback: AudioStreamGeneratorPlayback
var _engine_playback: AudioStreamGeneratorPlayback
var _sensor_playback: AudioStreamGeneratorPlayback
var _ambient_phase_a := 0.0
var _ambient_phase_b := 0.0
var _engine_phase := 0.0
var _sensor_phase := 0.0
var _sensor_mod_phase := 0.0
var _ship: ShipController
var _eva: EVAController

func _ready() -> void:
	_ambient_player = _make_generator_player("AmbientBed", -24.0)
	_engine_player = _make_generator_player("ShipEngine", -18.0)
	_sensor_player = _make_generator_player("FieldScanner", -20.0)
	call_deferred("_bind_world")

func _make_generator_player(node_name: String, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = MIX_RATE
	generator.buffer_length = BUFFER_LENGTH
	player.stream = generator
	player.volume_db = volume_db
	add_child(player)
	player.play()
	match node_name:
		"AmbientBed": _ambient_playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
		"ShipEngine": _engine_playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
		"FieldScanner": _sensor_playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	return player

func _bind_world() -> void:
	var ship_candidate := get_tree().root.find_child("Ship", true, false)
	if ship_candidate is ShipController:
		_ship = ship_candidate as ShipController
	var eva_candidate := get_tree().root.find_child("EVA", true, false)
	if eva_candidate is EVAController:
		_eva = eva_candidate as EVAController

func _process(_delta: float) -> void:
	if _ship == null or not is_instance_valid(_ship) or _eva == null or not is_instance_valid(_eva):
		_bind_world()
	_fill_ambient()
	_fill_engine()
	_fill_sensor()

func _fill_ambient() -> void:
	if _ambient_playback == null: return
	var frames := _ambient_playback.get_frames_available()
	var step_a := 46.0 / MIX_RATE
	var step_b := 69.0 / MIX_RATE
	for _i in range(frames):
		var slow_mod := 0.72 + 0.28 * sin(_ambient_phase_b * TAU * 0.125)
		var sample := (sin(_ambient_phase_a * TAU) * 0.16 + sin(_ambient_phase_b * TAU) * 0.08) * slow_mod
		_ambient_playback.push_frame(Vector2(sample, sample * 0.96))
		_ambient_phase_a = fposmod(_ambient_phase_a + step_a, 1.0)
		_ambient_phase_b = fposmod(_ambient_phase_b + step_b, 1.0)

func _fill_engine() -> void:
	if _engine_playback == null: return
	var throttle := 0.0
	var speed := 0.0
	var active := false
	if _ship != null and is_instance_valid(_ship):
		throttle = clampf(_ship.throttle, 0.0, 1.0)
		speed = _ship.velocity.length()
		active = _ship.enabled
	var intensity := clampf(throttle * 0.82 + minf(speed / 95.0, 1.0) * 0.18, 0.0, 1.0) if active else 0.0
	var frequency := 58.0 + intensity * 92.0
	var step := frequency / MIX_RATE
	var frames := _engine_playback.get_frames_available()
	for _i in range(frames):
		var fundamental := sin(_engine_phase * TAU)
		var harmonic := sin(_engine_phase * TAU * 2.0) * 0.34
		var sample := (fundamental + harmonic) * 0.12 * intensity
		_engine_playback.push_frame(Vector2(sample * 0.97, sample))
		_engine_phase = fposmod(_engine_phase + step, 1.0)

func _fill_sensor() -> void:
	if _sensor_playback == null: return
	var active := false
	if _eva != null and is_instance_valid(_eva):
		active = _eva.enabled and Input.is_action_pressed("scan")
	var frames := _sensor_playback.get_frames_available()
	var carrier_step := 612.0 / MIX_RATE
	var mod_step := 7.5 / MIX_RATE
	for _i in range(frames):
		var gate := 0.62 + 0.38 * sin(_sensor_mod_phase * TAU)
		var carrier := sin(_sensor_phase * TAU)
		var overtone := sin(_sensor_phase * TAU * 1.5) * 0.22
		var sample := (carrier + overtone) * gate * 0.055 if active else 0.0
		_sensor_playback.push_frame(Vector2(sample, sample))
		_sensor_phase = fposmod(_sensor_phase + carrier_step, 1.0)
		_sensor_mod_phase = fposmod(_sensor_mod_phase + mod_step, 1.0)
