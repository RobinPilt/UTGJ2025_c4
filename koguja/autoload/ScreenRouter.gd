# res://autoload/ScreenRouter.gd
extends Node

var screen_root: Node
var transition: CanvasLayer

func setup(_root: Node, _transition: CanvasLayer = null) -> void:
	screen_root = _root
	transition = _transition

func show_state(state_name: int, payload: Dictionary = {}) -> void:
	if not is_instance_valid(screen_root):
		push_warning("ScreenRouter: screen_root not set; call setup() first.")
		return

	# Clear old screen
	for c in screen_root.get_children():
		c.queue_free()

	# Load target scene or show a placeholder
	var scene := _scene_for(state_name)
	var inst: Node = scene.instantiate() if scene else _make_placeholder(state_name)
	screen_root.add_child(inst)

	# Pass payload to new screen, if it supports bootstrap()
	if inst.has_method("bootstrap"):
		inst.call("bootstrap", payload)

func _scene_for(state_name: int) -> PackedScene:
	match state_name:
		GameState.FlowState.MAIN_MENU:
			return _maybe("res://scenes/ui/MainMenu.tscn")
		GameState.FlowState.DATING_APP:
			return _maybe("res://scenes/ui/DatingApp.tscn")
		GameState.FlowState.MINIGAME:
			return _maybe("res://scenes/minigame/Minigame.tscn")
		GameState.FlowState.WEDDING:
			return _maybe("res://scenes/ui/Wedding.tscn")
		GameState.FlowState.RESULTS:
			return _maybe("res://scenes/ui/Results.tscn")       
		GameState.FlowState.GRAVEYARD:                                 
			return _maybe("res://scenes/ui/Graveyard.tscn")
		_:
			return null

func _maybe(path: String) -> PackedScene:
	return load(path) if ResourceLoader.exists(path) else null

func _make_placeholder(state_name: int) -> Control:
	var c := Control.new()
	c.name = "Placeholder"
	c.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.12, 0.14, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.add_child(bg)

	var label := Label.new()
	label.text = "Placeholder for state: %s" % [state_name]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.add_child(label)

	return c
