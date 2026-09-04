extends Node

# Persists meaningful physical runtime transitions after the main scene and
# optional runtime restore have settled. Progression remains owned by the
# canonical game root + SaveSystem path; this layer only requests checkpoints.

var _root: Node
var _last_mode := ""
var _armed := false
var _checkpoint_pending := false

func _ready() -> void:
	call_deferred("_arm")

func _arm() -> void:
	_root = get_tree().root.get_node_or_null("PaleSignalReboot")
	if _root == null:
		return
	_last_mode = str(_root.get("mode"))
	_connect_physical_milestones()
	_armed = true

func _connect_physical_milestones() -> void:
	var ship := _root.get_node_or_null("Ship")
	if ship != null:
		if ship.has_signal("launched"):
			ship.connect("launched", func(): _queue_checkpoint())
		if ship.has_signal("crossed_atmosphere"):
			ship.connect("crossed_atmosphere", func(): _queue_checkpoint())
		if ship.has_signal("touchdown"):
			ship.connect("touchdown", func(_vertical_speed, _lateral_speed, _safe): _queue_checkpoint())
	var world := _root.get_node_or_null("CampaignWorld")
	if world != null and world.has_signal("world_changed"):
		world.connect("world_changed", func(_world_name): _queue_checkpoint())

func _process(_delta: float) -> void:
	if not _armed or _root == null or not is_instance_valid(_root):
		return
	var current_mode := str(_root.get("mode"))
	if current_mode == _last_mode:
		return
	_last_mode = current_mode
	_queue_checkpoint()

func _queue_checkpoint() -> void:
	if _checkpoint_pending:
		return
	_checkpoint_pending = true
	call_deferred("_flush_checkpoint")

func _flush_checkpoint() -> void:
	_checkpoint_pending = false
	if _root != null and is_instance_valid(_root) and _root.has_method("_save_game"):
		_root.call_deferred("_save_game")
