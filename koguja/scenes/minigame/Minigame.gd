extends Node2D

@onready var back_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/BackButton"
@onready var win_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/DebugWinButton"
@onready var lose_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/DebugLoseButton"

var npc_data: Dictionary = {}

func bootstrap(payload: Dictionary) -> void:
    npc_data = payload.get("npc", {}) as Dictionary
    print("Minigame bootstrap received NPC:", npc_data)

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
	