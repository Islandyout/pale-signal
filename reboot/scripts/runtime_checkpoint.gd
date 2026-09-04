extends Node

# Persists controller-mode transitions after the main scene and optional runtime
# restore have settled. This keeps later first-hour boarding/disembark state from
# depending on tutorial lesson saves while leaving progression ownership in the
# canonical game root + SaveSystem path.

var _root: Node
var _last_mode := ""
var _armed := false

func _ready() -> void:
	call_deferred("_arm")

func _arm() -> void:
	_root = get_tree().root.get_node_or_null("PaleSignalReboot")
	if _root == null:
		return
	_last_mode = str(_root.get("mode"))
	_armed = true

func _process(_delta: float) -> void:
	if not _armed or _root == null or not is_instance_valid(_root):
		return
	var current_mode := str(_root.get("mode"))
	if current_mode == _last_mode:
		return
	_last_mode = current_mode
	if _root.has_method("_save_game"):
		_root.call_deferred("_save_game")
