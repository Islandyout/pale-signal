class_name AudioDirector
extends Node

# Procedural, zero-asset audio bed for the production reboot. This is deliberately
# isolated from gameplay state: it observes the live controllers and input state
# and never drives mechanics, saves, tutorial completion, or progression.

const MIX_RATE := 11025.0
const BUFFER_LENGTH := 0.35
const SIGNAL_AUDIBLE_RANGE := 96.0

var _ambient_player: AudioStreamPlayer
var _engine_player: AudioStreamPlayer
var _sensor_player: AudioStreamPlayer
var _reconstruction_player: AudioStreamPlayer
var _signal_player: AudioStreamPlayer
var _footstep_player: AudioStreamPlayer
var _ambient_playback: AudioStreamGeneratorPlayback
var _engine_playback: AudioStreamGeneratorPlayback
var _sensor_playback: AudioStreamGeneratorPlayback
var _reconstruction_playback: AudioStreamGeneratorPlayback
var _signal_playback: AudioStreamGeneratorPlayback
var _footstep_playback: AudioStreamGeneratorPlayback
var _ambient_phase_a := 0.0
var _ambient_phase_b := 0.0
var _engine_phase := 0.0
var _sensor_phase := 0.0
var _sensor_mod_phase := 0.0
var _reconstruction_phase := 0.0
var _reconstruction_mod_phase := 0.0
var _signal_phase_a := 0.0
var _signal_phase_b := 0.0
var _signal_pulse_phase := 0.0
var _footstep_phase := 0.0
var _footstep_stride_phase := 0.0
var _reconstruction_error := 1.0
var _reconstruction_active := false
var _reconstruction_lock_ready := false
var _ship: ShipController
var _eva: EVAController
var _archaeology: ArchaeologySystem
var _campaign_world: CampaignWorld

func _ready() -> void:
	_ambient_player = _make_generator_player("AmbientBed", -24.0)
	_engine_player = _make_generator_player("ShipEngine", -18.0)
	_sensor_player = _make_generator_player("FieldScanner", -20.0)
	_reconstruction_player = _make_generator_player("ReconstructionGuide", -18.0)
	_signal_player = _make_generator_player("PaleSignalMotif", -17.0)
	_footstep_player = _make_generator_player("EVAFootsteps", -15.0)
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
		"ReconstructionGuide": _reconstruction_playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
		"PaleSignalMotif": _signal_playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
		"EVAFootsteps": _footstep_playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	return player

func _bind_world() -> void:
	var ship_candidate := get_tree().root.find_child("Ship", true, false)
	if ship_candidate is ShipController:
		_ship = ship_candidate as ShipController
	var eva_candidate := get_tree().root.find_child("EVA", true, false)
	if eva_candidate is EVAController:
		_eva = eva_candidate as EVAController
	var world_candidate := get_tree().root.find_child("CampaignWorld", true, false)
	if world_candidate is CampaignWorld:
		_campaign_world = world_candidate as CampaignWorld
	if _archaeology == null or not is_instance_valid(_archaeology):
		_archaeology = _find_archaeology(get_tree().root)
		if _archaeology != null:
			var state_callback := Callable(self, "_on_reconstruction_state")
			if not _archaeology.reconstruction_state.is_connected(state_callback):
				_archaeology.reconstruction_state.connect(state_callback)

func _find_archaeology(node: Node) -> ArchaeologySystem:
	if node is ArchaeologySystem:
		return node as ArchaeologySystem
	for child in node.get_children():
		var found := _find_archaeology(child)
		if found != null:
			return found
	return null

func _on_reconstruction_state(stage: String, alignment: float, target: float, lock_ready: bool) -> void:
	# A pre-scan emits reconstruction_state before reconstruction actually begins.
	# Keep the guide silent until ArchaeologySystem owns an active reconstruction.
	var reconstruction_running := _archaeology != null and is_instance_valid(_archaeology) and _archaeology.active
	_reconstruction_active = reconstruction_running and stage != "RESET" and stage != "RECONSTRUCTION LOCKED"
	_reconstruction_error = clampf(absf(target - alignment), 0.0, 1.0)
	_reconstruction_lock_ready = reconstruction_running and lock_ready
	if stage == "RECONSTRUCTION LOCKED":
		_reconstruction_active = false
		_reconstruction_lock_ready = false

func _process(_delta: float) -> void:
	if _ship == null or not is_instance_valid(_ship) or _eva == null or not is_instance_valid(_eva) or _archaeology == null or not is_instance_valid(_archaeology) or _campaign_world == null or not is_instance_valid(_campaign_world):
		_bind_world()
	_fill_ambient()
	_fill_engine()
	_fill_sensor()
	_fill_reconstruction()
	_fill_signal()
	_fill_footsteps()

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

func _fill_reconstruction() -> void:
	if _reconstruction_playback == null: return
	var frames := _reconstruction_playback.get_frames_available()
	var proximity := clampf(1.0 - (_reconstruction_error / 0.30), 0.0, 1.0)
	var frequency := 245.0 + proximity * 355.0
	var pulse_rate := 2.0 + proximity * 6.0
	if _reconstruction_lock_ready:
		frequency = 880.0
		pulse_rate = 11.0
	var carrier_step := frequency / MIX_RATE
	var mod_step := pulse_rate / MIX_RATE
	for _i in range(frames):
		var pulse := 0.5 + 0.5 * sin(_reconstruction_mod_phase * TAU)
		var gate := 1.0 if _reconstruction_lock_ready else (0.25 + 0.75 * pulse)
		var carrier := sin(_reconstruction_phase * TAU)
		var overtone := sin(_reconstruction_phase * TAU * 2.0) * 0.18
		var intensity := (0.028 + proximity * 0.035) if _reconstruction_active else 0.0
		var sample := (carrier + overtone) * gate * intensity
		_reconstruction_playback.push_frame(Vector2(sample * 0.96, sample))
		_reconstruction_phase = fposmod(_reconstruction_phase + carrier_step, 1.0)
		_reconstruction_mod_phase = fposmod(_reconstruction_mod_phase + mod_step, 1.0)

func _fill_footsteps() -> void:
	if _footstep_playback == null: return
	var speed := 0.0
	var grounded := false
	var active := false
	if _eva != null and is_instance_valid(_eva):
		speed = Vector2(_eva.velocity.x, _eva.velocity.z).length()
		grounded = _eva.is_on_floor()
		active = _eva.enabled and _eva.movement_enabled and grounded and speed > 0.35
	var speed_ratio := clampf(speed / maxf(_eva.walk_speed if _eva != null and is_instance_valid(_eva) else 5.2, 0.1), 0.0, 1.0)
	var stride_rate := lerpf(1.45, 2.25, speed_ratio)
	var frames := _footstep_playback.get_frames_available()
	var body_step := 118.0 / MIX_RATE
	var stride_step := stride_rate / MIX_RATE
	for _i in range(frames):
		var stride_wave := 0.5 + 0.5 * sin(_footstep_stride_phase * TAU)
		# A narrow envelope makes each contact read as a boot impact instead of a tone.
		var impact := pow(stride_wave, 18.0) if active else 0.0
		var body := sin(_footstep_phase * TAU)
		var grit := sin(_footstep_phase * TAU * 2.73) * 0.22
		var intensity := impact * (0.035 + speed_ratio * 0.035)
		var sample := (body + grit) * intensity
		_footstep_playback.push_frame(Vector2(sample, sample * 0.94))
		_footstep_phase = fposmod(_footstep_phase + body_step, 1.0)
		_footstep_stride_phase = fposmod(_footstep_stride_phase + stride_step, 1.0)

func _signal_proximity() -> float:
	# The motif is diegetic guidance, not a waypoint: only unresolved fragment
	# anchors influence it, and the game remains fully playable with audio muted.
	if _campaign_world == null or not is_instance_valid(_campaign_world):
		return 0.0
	var actor: Node3D = null
	if _eva != null and is_instance_valid(_eva) and _eva.enabled:
		actor = _eva
	elif _ship != null and is_instance_valid(_ship) and _ship.enabled:
		actor = _ship
	if actor == null:
		return 0.0
	var nearest := INF
	for site_id in _campaign_world.sites:
		if not str(site_id).begins_with("fragment|"):
			continue
		var site := _campaign_world.sites[site_id] as Interactable
		if site == null or not is_instance_valid(site) or not site.visible or site.completed:
			continue
		nearest = minf(nearest, actor.global_position.distance_to(site.global_position))
	if nearest == INF:
		return 0.0
	return clampf(1.0 - nearest / SIGNAL_AUDIBLE_RANGE, 0.0, 1.0)

func _fill_signal() -> void:
	if _signal_playback == null: return
	var proximity := _signal_proximity()
	var fragment_count := 0
	if _campaign_world != null and is_instance_valid(_campaign_world) and _campaign_world.campaign != null:
		fragment_count = _campaign_world.campaign.fragment_count()
	# The second first-hour encounter evolves the same motif rather than replacing
	# it: slightly faster pulses and a detuned second carrier imply the signal is
	# becoming structured as contradictory evidence accumulates.
	var escalation := clampf(float(fragment_count) / 2.0, 0.0, 1.0)
	var carrier_a := 173.0 + escalation * 19.0
	var carrier_b := 281.0 + escalation * 37.0
	var pulse_rate := 0.72 + proximity * 1.9 + escalation * 0.55
	var step_a := carrier_a / MIX_RATE
	var step_b := carrier_b / MIX_RATE
	var pulse_step := pulse_rate / MIX_RATE
	var frames := _signal_playback.get_frames_available()
	for _i in range(frames):
		var pulse_wave := 0.5 + 0.5 * sin(_signal_pulse_phase * TAU)
		var gate := pow(pulse_wave, 3.0)
		var primary := sin(_signal_phase_a * TAU)
		var secondary := sin(_signal_phase_b * TAU) * (0.30 + escalation * 0.16)
		var intensity := proximity * proximity * (0.032 + escalation * 0.018)
		var sample := (primary + secondary) * gate * intensity
		_signal_playback.push_frame(Vector2(sample * 0.91, sample))
		_signal_phase_a = fposmod(_signal_phase_a + step_a, 1.0)
		_signal_phase_b = fposmod(_signal_phase_b + step_b, 1.0)
		_signal_pulse_phase = fposmod(_signal_pulse_phase + pulse_step, 1.0)