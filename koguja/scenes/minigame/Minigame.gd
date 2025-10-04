# res://scripts/minigame/Minigame.gd
extends Node2D

@onready var back_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/BackButton"
@onready var win_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/DebugWinButton"
@onready var lose_btn: Button = $"HUD/MarginContainer/VBoxContainer/HBoxContainer/DebugLoseButton"

func _ready() -> void:
    # Connect buttons to simple navigation
    back_btn.pressed.connect(func() -> void:
        GameState.goto(GameState.FlowState.DATING_APP)
    )

    win_btn.pressed.connect(func() -> void:
        GameState.goto(GameState.FlowState.WEDDING)
    )

    lose_btn.pressed.connect(func() -> void:
        GameState.goto(GameState.FlowState.GRAVEYARD)
    )
