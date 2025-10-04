extends Node2D

@onready var back_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/BackButton"
@onready var win_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/DebugWinButton"
@onready var lose_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/DebugLoseButton"
@onready var hearts_label: Label = $"HUD/MarginContainer/VBoxContainer/HeartsLabel"

const DIFFICULTY_HEARTS = {
	"easy": 10,
	"normal": 15,
	"hard": 20
}

var npc_data: Dictionary = {}
var hearts_collected: int = 0
var required_hearts: int = 10  # Default fallback

func bootstrap(payload: Dictionary) -> void:
	npc_data = payload.get("npc", {}) as Dictionary
	var difficulty_id: String = npc_data.get("difficulty_id", "easy")
	required_hearts = DIFFICULTY_HEARTS.get(difficulty_id, 10)
	hearts_collected = 0
	update_heart_ui()
	print("Minigame bootstrap received NPC:", npc_data)
	print("Difficulty ID:", difficulty_id, "→ Required Hearts:", required_hearts)

func _ready() -> void:
	back_btn.pressed.connect(func() -> void:
		GameState.goto(GameState.FlowState.DATING_APP)
	)

	win_btn.pressed.connect(func() -> void:
		GameState.goto(GameState.FlowState.WEDDING, {
			"npc": npc_data,
			"full_name": "Robin"  # Replace with RunData later
		})
	)

	lose_btn.pressed.connect(func() -> void:
		GameState.goto(GameState.FlowState.GRAVEYARD, {
			"full_name": "Robin"  # Replace with RunData later
		})
	)

func on_heart_collected(value: int = 1) -> void:
	hearts_collected += value
	update_heart_ui()

	if hearts_collected >= required_hearts:
		GameState.goto(GameState.FlowState.WEDDING, {
			"npc": npc_data,
			"full_name": "Robin"  # Replace with RunData later
		})

func update_heart_ui() -> void:
	hearts_label.text = "Hearts: %d / %d" % [hearts_collected, required_hearts]
