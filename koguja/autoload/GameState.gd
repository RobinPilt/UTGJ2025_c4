# res://autoload/GameState.gd
extends Node

signal flow_changed(state_name: int, payload: Dictionary)

enum FlowState { MAIN_MENU, DATING_APP, MINIGAME, WEDDING, RESULTS, GRAVEYARD}

var state: int = FlowState.MAIN_MENU

func goto(new_state: int, payload: Dictionary = {}) -> void:
	state = new_state
	emit_signal("flow_changed", state, payload)
	ScreenRouter.show_state(state, payload)


func _ready() -> void:
	print("[GameState] Ready.")
	# Connect GameState's own signal to a local method on GameState itself
	self.connect("flow_changed", Callable(self, "_on_flow_changed"))

func _on_flow_changed(state: int, payload: Dictionary) -> void:
	print("[GameState] flow_changed -> ", state, ", payload = ", payload)
